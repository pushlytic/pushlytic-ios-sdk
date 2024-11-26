//
//  APIClient.swift
//  Pushlytic
//
//  Copyright © 2024 Pushlytic.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation
import GRPC
import NIO
import NIOConcurrencyHelpers
import NIOHPACK
import SwiftProtobuf
import UIKit

/// A client for handling real-time message streaming over gRPC
///
/// `APIClient` manages:
/// - Bi-directional streaming connections
/// - Message handling and acknowledgment
/// - Connection state management
/// - Automatic reconnection
/// - Heartbeat monitoring
/// - Custom event handling
///
/// Thread Safety:
/// - All methods are thread-safe
/// - Callbacks are always delivered on the main thread
/// - Internal state is protected by synchronization primitives
final class APIClient: APIClientProtocol {

    // MARK: - Private Properties
    
    private let TAG = "Pushlytic"
    private let client: Pb_StreamlinkNIOClient
    private let group: EventLoopGroup
    private let sessionID: String
    private let processingQueue: DispatchQueue
    private let lock = NSLock()
    private let logger: PushlyticLogger?

    private var lastHeartbeatTime: Date?
    private var heartbeatManager: HeartbeatManager?
    private var call: BidirectionalStreamingCall<Pb_MessageRequest, Pb_MessageResponse>?
    private var reconnectionTask: DispatchWorkItem?
    
    // MARK: - Connection State
    
    /// The API key used for authentication
    private let apiKey: String
    
    /// The current user identifier
    private(set) var userID: String?
    
    /// Tags associated with the current session
    private(set) var tags: [String]?
    
    /// Indicates whether the client is currently connected
    private(set) var isConnected: Bool = false {
        didSet {
            if !isConnected {
                connectionInProgress = false
            }
        }
    }
    
    /// Indicates whether a connection attempt is in progress
    private(set) var connectionInProgress: Bool = false
    
    // MARK: - Initialization
    
    /// Initializes a new APIClient instance with an API key.
    /// - Parameter apiKey: A valid API key for authenticating the client
    /// - Note: The client does not connect automatically. Use `openMessageStream` to establish a connection.
    init(apiKey: String, logger: PushlyticLogger?) {
        self.apiKey = apiKey
        self.logger = logger

        group = MultiThreadedEventLoopGroup(numberOfThreads: APIConstants.eventLoopThreads)
        
        var configuration = ClientConnection.Configuration.default(
            target: .hostAndPort(APIConstants.serverHost, APIConstants.serverPort),
            eventLoopGroup: group
        )

        let channel = ClientConnection(configuration: configuration)
        self.client = Pb_StreamlinkNIOClient(channel: channel)
        self.processingQueue = DispatchQueue(label: "com.pushlytic.processingQueue", qos: .userInitiated)
        self.sessionID = UUID().uuidString
    }
    
    // MARK: - Connection Management
    
    /// Opens a bi-directional message stream
    /// - Parameter onStateChange: Callback for stream state changes, always called on main thread
    /// - Thread Safety: This method is thread-safe and can be called from any thread
    func openMessageStream(onStateChange: @escaping (MessageStreamState) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        
        guard !isConnected, !connectionInProgress else { return }
        
        connectionInProgress = true
        let callOptions = createCallOptions()
        
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.call = self.client.messageStream(callOptions: callOptions) { [weak self] message in
                self?.handleIncomingMessage(message, onStateChange: onStateChange)
            }
            
            self.setupStreamCompletion(onStateChange: onStateChange)
            self.sendOpenConnectionMessage()
            self.startHeartbeatMonitoring(onStateChange: onStateChange)
        }
    }
    
    // MARK: - Private Connection Helpers
    
    private func createCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        
        callOptions.customMetadata.add(name: "authorization", value: "Bearer \(apiKey)")
        callOptions.customMetadata.add(name: "Client-Type", value: "iOS")
        callOptions.customMetadata.add(name: "X-Ios-Bundle-Identifier", value: APIConstants.bundleIdentifier)
        
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            callOptions.customMetadata.add(name: "Device-ID", value: uuid)
        }
        
        return callOptions
    }
    
    private func handleIncomingMessage(_ message: Pb_MessageResponse, onStateChange: @escaping (MessageStreamState) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch message.data {
            case .messages(let messages):
                self.handleIncomingMessages(messages, onStateChange: onStateChange)
            case .controlMessage(let controlMessage):
                self.handleControlMessage(controlMessage)
            case .heartbeat(let heartbeat):
                self.handleHeartbeat(heartbeat, onStateChange: onStateChange)
            case .connectionAcknowledgement:
                self.handleConnectionAcknowledgement(onStateChange: onStateChange)
            default:
                logWarning("Unknown message type received.")
            }
        }
    }
    
    private func handleIncomingMessages(_ messages: Pb_Messages, onStateChange: @escaping (MessageStreamState) -> Void) {
        for message in messages.message {
            acknowledgeMessage(traceID: message.traceID)
            onStateChange(.messageReceived(message.content))
        }
    }
    
    private func handleControlMessage(_ controlMessage: Pb_ControlMessage) {
        if controlMessage.command == .close {
            logWarning("Control message received: close command.")
            endConnection()
        }
    }
    
    private func handleHeartbeat(_ heartbeat: Pb_Heartbeat, onStateChange: @escaping (MessageStreamState) -> Void) {
        handleHeartbeatReceived()
    }
    
    private func handleConnectionAcknowledgement(onStateChange: @escaping (MessageStreamState) -> Void) {
        lock.lock()
        isConnected = true
        connectionInProgress = false
        reconnectionTask = nil
        lock.unlock()
        
        onStateChange(.connected)
    }
    
    private func setupStreamCompletion(onStateChange: @escaping (MessageStreamState) -> Void) {
        call?.status.whenComplete { [weak self] status in
            guard let self = self else { return }
            self.handleStreamCompletion(status: status, onStateChange: onStateChange)
        }
    }
    
    private func sendOpenConnectionMessage() {
        let openConnectionMessage = Pb_MessageRequest.with {
            $0.userID = userID ?? ""
            $0.tags = tags ?? []
            $0.sessionID = sessionID
            $0.controlMessage = Pb_ControlMessage.with {
                $0.command = .open
            }
        }
        
        _ = call?.sendMessage(openConnectionMessage)
    }
    
    private func handleStreamCompletion(status: Result<GRPCStatus, Error>, onStateChange: @escaping (MessageStreamState) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.lock.lock()
            self.isConnected = false
            self.connectionInProgress = false
            self.lock.unlock()
            
            switch status {
            case .success:
                onStateChange(.disconnected)
            case .failure(let error):
                logError("Stream completed with error: \(error.localizedDescription)", error)
                onStateChange(.connectionError(error))
            }
            
            if Pushlytic.shouldAutoReconnect {
                self.scheduleReconnection(onStateChange: onStateChange)
            }
        }
    }
    
    private func scheduleReconnection(onStateChange: @escaping (MessageStreamState) -> Void) {
        reconnectionTask?.cancel()
        
        reconnectionTask = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.openMessageStream(onStateChange: onStateChange)
        }
        
        processingQueue.asyncAfter(deadline: .now() + APIConstants.reconnectionDelay, execute: reconnectionTask!)
    }
    
    // MARK: - Message Handling
    
    /// Registers a user identifier with the streaming service
    /// - Parameter newUserID: The user identifier to register
    /// - Thread Safety: This method is thread-safe and can be called from any thread
    func registerUserID(_ newUserID: String) {
        lock.lock()
        self.userID = newUserID
        guard isConnected else {
            lock.unlock()
            return
        }
        lock.unlock()
        
        let registerClientIDMessage = Pb_MessageRequest.with {
            $0.sessionID = sessionID
            $0.userID = newUserID
        }
        
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            _ = self.call?.sendMessage(registerClientIDMessage)
        }
    }
    
    /// Registers tags for the current session
    /// - Parameter tags: Array of tags to register
    /// - Thread Safety: This method is thread-safe and can be called from any thread
    func registerTags(_ tags: [String]) {
        let tagsCopy = tags // Create a copy
        lock.lock()
        self.tags = tagsCopy
        let isCurrentlyConnected = isConnected
        lock.unlock()
        
        guard isCurrentlyConnected else { return }
        
        let registerTagsMessage = Pb_MessageRequest.with {
            $0.sessionID = sessionID
            $0.tags = tagsCopy
        }
        
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            _ = self.call?.sendMessage(registerTagsMessage)
        }
    }
    
    private func acknowledgeMessage(traceID: String) {
        let ack = Pb_MessageAcknowledgement.with {
            $0.traceID = traceID
        }
        let ackMessage = Pb_MessageRequest.with {
            $0.sessionID = sessionID
            $0.messageAcknowledgement = [ack]
        }
        
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            _ = self.call?.sendMessage(ackMessage)
        }
    }
    
    /// Ends the current connection
    /// - Parameter wasManuallyDisconnected: Indicates if the disconnection was user-initiated
    /// - Thread Safety: This method is thread-safe and can be called from any thread
    func endConnection(wasManuallyDisconnected: Bool = false) {
        reconnectionTask?.cancel()
        stopHeartbeatMonitoring()
        
        if !wasManuallyDisconnected {
            let closeConnectionMessage = Pb_MessageRequest.with {
                $0.userID = userID ?? ""
                $0.tags = tags ?? []
                $0.sessionID = sessionID
                $0.controlMessage = Pb_ControlMessage.with {
                    $0.command = .close
                }
            }
            _ = call?.sendMessage(closeConnectionMessage)
            _ = call?.sendEnd()
        } else {
            call = nil
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.lock.lock()
            self.isConnected = false
            self.lock.unlock()
        }
    }
    
    // MARK: - Event Handling
    
    /// Sends a custom event through the streaming service
    /// - Parameters:
    ///   - name: Name of the custom event
    ///   - metadata: Additional data associated with the event
    /// - Thread Safety: This method is thread-safe and can be called from any thread
    func sendCustomEvent(name: String, metadata: [String: Any]) {
        lock.lock()
        guard isConnected else {
            lock.unlock()
            return
        }
        lock.unlock()
        
        let metadataData = try? JSONSerialization.data(withJSONObject: metadata, options: [])
        let metadataString = metadataData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        
        let customEvent = Pb_CustomEvent.with {
            $0.name = name
            $0.metadata = metadataString
        }
        
        let customEventMessage = Pb_MessageRequest.with {
            $0.sessionID = sessionID
            $0.customEvent = customEvent
        }
        
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            _ = self.call?.sendMessage(customEventMessage)
        }
    }
    
    /// Updates or clears metadata for the current session
    /// - Parameters:
    ///   - operation: Type of metadata operation to perform
    ///   - metadata: Metadata to update (required for update operation, ignored for clear)
    /// - Thread Safety: This method is thread-safe and can be called from any thread
    func updateMetadata(_ operation: MetadataOperationType, metadata: [String: Any]?) {
        lock.lock()
        guard isConnected else {
            lock.unlock()
            return
        }
        lock.unlock()
        
        var metadataString = ""
        if let metadata = metadata {
            let metadataData = try? JSONSerialization.data(withJSONObject: metadata, options: [])
            metadataString = metadataData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        }
        
        let metadataMessage = Pb_MessageRequest.with {
            $0.sessionID = sessionID
            $0.metadataOperation = operation.protoValue
            if operation == .update {
                $0.metadata = metadataString
            }
        }
        
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            _ = self.call?.sendMessage(metadataMessage)
        }
    }
    
    // MARK: - Heartbeat Management
    
    private func handleHeartbeatReceived() {
        lock.lock()
        lastHeartbeatTime = Date()
        lock.unlock()
    }
    
    private func startHeartbeatMonitoring(onStateChange: @escaping (MessageStreamState) -> Void) {
        lock.lock()
        heartbeatManager = HeartbeatManager { [weak self] in
            self?.checkHeartbeatTimeout(onStateChange: onStateChange)
        }
        lock.unlock()
        
        heartbeatManager?.startMonitoring(interval: APIConstants.heartbeatInterval)
    }
    
    private func stopHeartbeatMonitoring() {
        lock.lock()
        heartbeatManager?.stopMonitoring()
        heartbeatManager = nil
        lock.unlock()
    }
    
    private func checkHeartbeatTimeout(onStateChange: @escaping (MessageStreamState) -> Void) {
        lock.lock()
        let lastHeartbeat = lastHeartbeatTime
        lock.unlock()
        
        if let lastHeartbeat = lastHeartbeat, Date().timeIntervalSince(lastHeartbeat) > APIConstants.heartbeatTimeout {
            onStateChange(.timeout)
        }
    }
    
    // MARK: - Cleanup
    
    /// Performs a graceful shutdown of the client
    /// - Note: This method is automatically called during deinitialization
    private func shutdown() {
        reconnectionTask?.cancel()
        reconnectionTask = nil
        
        lock.lock()
        heartbeatManager = nil
        lock.unlock()
        
        if let activeCall = call {
            // Send end message and ensure proper cleanup
            activeCall.sendEnd().whenComplete { [weak self] _ in
                activeCall.cancel(promise: nil)
                self?.call = nil
            }
            
            activeCall.status.whenComplete { [weak self] _ in
                self?.shutdownEventLoopGroup()
            }
        } else {
            shutdownEventLoopGroup()
        }
    }

    /// Gracefully shuts down the event loop group
    private func shutdownEventLoopGroup() {
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                try self.group.syncShutdownGracefully()
            } catch {
                #if DEBUG
                self.logError("Error during EventLoopGroup shutdown: \(error.localizedDescription)", error)
                #endif
            }
        }
    }
    
    deinit {
        shutdown()
    }

    // MARK: - Logging Helpers

    private func logError(_ message: String, _ error: Error? = nil) {
        #if DEBUG
        logger?.logError(tag: TAG, message: message, error: error)
        #endif
    }
    
    private func logWarning(_ message: String) {
        #if DEBUG
        logger?.logWarning(tag: TAG, message: message)
        #endif
    }
    
    private func logInfo(_ message: String) {
        #if DEBUG
        logger?.logInfo(tag: TAG, message: message)
        #endif
    }
}
