//
//  Pushlytic.swift
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
import UIKit

/// Pushlytic provides a thread-safe, configurable SDK for real-time mobile messaging and analytics.
///
/// This class serves as the primary interface for integrating real-time messaging capabilities
/// into iOS applications. It provides features such as:
/// - Real-time message streaming
/// - User identification and tracking
/// - Custom event analytics
/// - Metadata management
/// - Connection state management
///
/// # Thread Safety
/// All public methods are thread-safe and can be called from any thread.
/// Callbacks are always delivered on the main thread for UI safety.
///
/// # Example Usage
/// ```swift
/// // Configure the SDK
/// let config = Pushlytic.Configuration(apiKey: "your-api-key")
/// Pushlytic.configure(with: config)
///
/// // Set up delegate
/// Pushlytic.setDelegate(self)
///
/// // Start streaming
/// Pushlytic.openStream()
/// ```
public final class Pushlytic {
    
    // MARK: - Private Properties
    
    /// Thread-safe queue for synchronizing access to shared resources
    private static let queue = DispatchQueue(label: "com.pushlytic.sdk", qos: .userInitiated, attributes: .concurrent)
    
    /// JSON decoder instance for message parsing
    private static let decoder = JSONDecoder()
    
    /// API client instance for handling network communications
    private static var client: APIClientProtocol?
    
    /// Manages application lifecycle events
    private static var lifecycleManager: LifecycleManager?
    
    /// Delegate for receiving SDK events and status updates
    private static var delegate: PushlyticDelegate?
    
    /// Initialization state of the SDK
    private static var isInitialized = false {
        didSet {
            if !isInitialized {
                clearStoredState()
            }
        }
    }
    
    /// Tracks whether the connection was manually disconnected
    private static var isManuallyDisconnected = false
    
    /// Persistent storage of configuration
    private static var storedApiKey: String?
    
    // MARK: - State Management
    
    /// Thread-safe storage of user state
    private static var storedUserID: String?
    private static var storedTags: [String]?
    private static var storedMetadata: [String: Any]?
    
    // MARK: - Public Properties
    
    /// Indicates whether the SDK is currently connected to the streaming service
    public static var isConnected: Bool {
        return queue.sync { client?.isConnected ?? false }
    }
    
    /// Indicates whether the SDK should automatically reconnect
    /// Returns true if the connection was manually disconnected by the user
    internal static var shouldAutoReconnect: Bool {
        return queue.sync { !isManuallyDisconnected }
    }
    
    // MARK: - Configuration
    
    /// Configuration object for initializing the SDK
    public struct Configuration {
        /// API key for authentication
        public let apiKey: String
        
        /// Initializes a new configuration
        /// - Parameter apiKey: Valid API key obtained from the dashboard
        public init(apiKey: String) {
            self.apiKey = apiKey
        }
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    /// Configures the SDK with the provided configuration
    /// - Parameter configuration: Configuration object containing necessary credentials
    /// - Thread Safety: This method is thread-safe and can be called from any thread
    public static func configure(with configuration: Configuration) {
        queue.async(flags: .barrier) {
            cleanup()
            
            storedApiKey = configuration.apiKey
            if initializeClient(with: storedApiKey) {
                initializeLifecycleManager()
                isInitialized = true
            } else {
                notifyDelegateOnMain(.error(.notConfigured))
            }
        }
    }
    
    /// Initializes the client with the provided API key
    /// - Parameter apiKey: The API key to use for authentication
    /// - Returns: Bool indicating whether initialization was successful
    @discardableResult
    private static func initializeClient(with apiKey: String?) -> Bool {
        
        let logger: PushlyticLogger? = if #available(iOS 14.0, *) {
            DefaultLogger()
        } else {
            nil
        }
        
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            #if DEBUG
            logger?.logError(tag: "[Pushlytic]", message: "Invalid or missing API key", error: nil)
            #endif
            return false
        }
        
        client = APIClient(apiKey: apiKey, logger: logger)
        return true
    }
    
    private static func initializeLifecycleManager() {
        lifecycleManager = LifecycleManager()
    }
    
    // MARK: - Connection Management
    
    /// Opens a connection to the message streaming service
    /// - Parameters:
    ///   - metadata: Optional metadata to include in the initial connection
    /// - Thread Safety: This method is thread-safe and can be called from any thread
    public static func openStream(metadata: [String: Any]? = nil) {
        queue.async(flags: .barrier) {
            guard isInitialized, storedApiKey != nil else {
                notifyDelegateOnMain(.error(.notConfigured))
                return
            }
            
            if client == nil {
                initializeClient(with: storedApiKey)
            }
            
            initializeLifecycleManager()
            
            isManuallyDisconnected = false
            if let metadata = metadata {
                storedMetadata = metadata
            }
            startMessageStream(metadata: storedMetadata)
        }
    }

    /// Ends the current streaming connection with Pushlytic
    /// - Parameter clearState: Controls whether connection data is preserved.
    ///   The connection automatically closes when the app backgrounds, but you can
    ///   control whether the connection data (user ID, metadata, tags) is:
    ///   - true: Completely cleared, requiring fresh setup on next connection. Prevents reconnection
    ///     on foregrounding
    ///   - false: Preserved for automatic reconnection when the app foregrounds,
    ///     resuming with previous settings intact
    /// - Thread Safety: This method is thread-safe and can be called from any thread
    public static func endStream(clearState: Bool = false) {
        queue.async(flags: .barrier) {
            if clearState {
                isManuallyDisconnected = true
                
                lifecycleManager?.cleanup()
                lifecycleManager = nil
                
                cleanup()
                clearStoredState()
            }
            
            client?.endConnection(wasManuallyDisconnected: clearState)
            notifyDelegateOnMain(.disconnected)
        }
    }
    
    private static func cleanup() {
        lifecycleManager?.cleanup()
        lifecycleManager = nil
        client?.endConnection(wasManuallyDisconnected: false)
        
        if isManuallyDisconnected {
            client = nil
        }
    }
    
    private static func clearStoredState() {
        storedUserID = nil
        storedTags = nil
        storedMetadata = nil
    }
    
    // MARK: - Delegate Management
    
    /// Sets the delegate to receive SDK events and status updates
    /// - Parameter delegate: Object conforming to PushlyticDelegate
    /// - Thread Safety: This method is thread-safe and can be called from any thread
    public static func setDelegate(_ delegate: PushlyticDelegate?) {
        queue.async(flags: .barrier) {
            self.delegate = delegate
        }
    }
    
    // MARK: - User Management
    
    /// Registers a user identifier with the service
    /// - Parameter userID: Unique identifier for the user
    /// - Thread Safety: This method is thread-safe and can be called from any thread
    public static func registerUserID(_ userID: String) {
        queue.async(flags: .barrier) {
            storedUserID = userID
            client?.registerUserID(userID)
        }
    }
    
    /// Registers tags associated with the current user
    /// - Parameter tags: Array of string tags
    /// - Thread Safety: This method is thread-safe and can be called from any thread
    public static func registerTags(_ tags: [String]) {
        queue.async(flags: .barrier) {
            storedTags = tags
            client?.registerTags(tags)
        }
    }
    
    // MARK: - Analytics
    
    /// Sends a custom event to the analytics service
    /// - Parameters:
    ///   - name: Name of the custom event
    ///   - metadata: Additional data associated with the event
    /// - Thread Safety: This method is thread-safe and can be called from any thread
    public static func sendCustomEvent(name: String, metadata: [String: Any]) {
        queue.async(flags: .barrier) {
            guard isInitialized else { return }
            client?.sendCustomEvent(name: name, metadata: metadata)
        }
    }
    
    /// Updates metadata associated with the current user
    /// - Parameter metadata: Dictionary of metadata key-value pairs
    /// - Thread Safety: This method is thread-safe and can be called from any thread
    public static func setMetadata(_ metadata: [String: Any]) {
        queue.async(flags: .barrier) {
            storedMetadata = metadata
            client?.updateMetadata(.update, metadata: metadata)
        }
    }
    
    /// Clears all metadata associated with the current user
    /// - Thread Safety: This method is thread-safe and can be called from any thread
    public static func clearMetadata() {
        queue.async(flags: .barrier) {
            storedMetadata = nil
            client?.updateMetadata(.clear, metadata: nil)
        }
    }
    
    // MARK: - Message Handling
    
    /// Decodes and processes a received JSON message string into a specified type.
    ///
    /// This method provides a type-safe way to handle incoming messages by attempting to decode
    /// them into a specified `Codable` type. The completion handler is always called on the main thread
    /// for UI safety.
    ///
    /// - Parameters:
    ///   - jsonString: The JSON string to decode
    ///   - type: The type to decode the JSON into, must conform to `Codable`
    ///   - completion: A closure called with the decoded message on success
    ///   - errorHandler: Optional closure called if decoding fails
    /// - Thread Safety: This method is thread-safe and can be called from any thread
    ///
    /// # Example Usage
    /// ```swift
    /// struct CustomMessage: Codable {
    ///     let id: String
    ///     let content: String
    /// }
    ///
    /// Pushlytic.handleMessage(jsonString) { (message: CustomMessage) in
    ///     print("Received message: \(message)")
    /// } errorHandler: { error in
    ///     print("Failed to decode message: \(error)")
    /// }
    /// ```
    public static func parseMessage<T: Codable>(
        _ jsonString: String,
        as type: T.Type = T.self,
        completion: @escaping (T) -> Void,
        errorHandler: ((Error) -> Void)? = nil
    ) {
        queue.async {
            guard let data = jsonString.data(using: .utf8) else {
                DispatchQueue.main.async {
                    errorHandler?(PushlyticError.invalidMessageFormat)
                }
                return
            }
            
            do {
                let message = try decoder.decode(type, from: data)
                DispatchQueue.main.async {
                    completion(message)
                }
            } catch {
                DispatchQueue.main.async {
                    errorHandler?(error)
                }
            }
        }
    }
    
    // MARK: - Internal Methods
    
    private static func startMessageStream(metadata: [String: Any]? = nil) {
        guard isInitialized else {
            notifyDelegateOnMain(.error(.notConfigured))
            return
        }
        
        client?.openMessageStream(metadata: metadata) { state in
            switch state {
            case .connected:
                queue.async(flags: .barrier) {
                    reapplyStoredState()
                    notifyDelegateOnMain(.connected)
                }
            case .messageReceived(let message):
                notifyDelegateOnMain { $0.pushlytic(didReceiveMessage: message) }
            case .connectionError(let error):
                notifyDelegateOnMain(.error(error as? PushlyticError ?? .notAuthorized))
            case .disconnected:
                notifyDelegateOnMain(.disconnected)
            case .timeout:
                notifyDelegateOnMain(.timeout)
            }
        }
    }
    
    internal static func handleAppForegrounded() {
        queue.async(flags: .barrier) {
            if !isManuallyDisconnected {
                startMessageStream()
            }
        }
    }
    
    private static func reapplyStoredState() {
        storedUserID.flatMap { client?.registerUserID($0) }
        storedTags.flatMap { client?.registerTags($0) }
        storedMetadata.flatMap { client?.updateMetadata(.update, metadata: $0) }
    }
    
    // MARK: - Helper Methods
    
    private static func notifyDelegateOnMain(_ status: ConnectionStatus) {
        DispatchQueue.main.async {
            delegate?.pushlytic(didChangeConnectionStatus: status)
        }
    }
    
    private static func notifyDelegateOnMain(_ block: @escaping (PushlyticDelegate) -> Void) {
        DispatchQueue.main.async {
            delegate.map(block)
        }
    }

    // MARK: - Test Helper Methods
    
    /// Injects a mock client for testing purposes.
    ///
    /// This method is intended to be used only during unit testing to allow injection
    /// of a mock `APIClientProtocol` implementation for validating SDK behavior.
    ///
    /// - Parameter mockClient: The mock client to inject.
    /// - Note: This method is accessible only within the test target.
    internal static func injectClientForTesting(_ mockClient: APIClientProtocol) {
        queue.async(flags: .barrier) {
            client = mockClient
        }
    }
}
