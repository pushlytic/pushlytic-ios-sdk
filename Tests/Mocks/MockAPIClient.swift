//
//  MockAPIClient.swift
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
//

import Foundation
@testable import Pushlytic

class MockAPIClient: APIClientProtocol {
    // Connection state
    private(set) var isConnected: Bool = false
    private(set) var isMessageStreamOpened = false
    private(set) var wasManuallyDisconnected = false
    
    // Configuration tracking
    private(set) var configuredApiKey: String?
    
    // User management tracking
    private(set) var lastRegisteredUserID: String?
    private(set) var lastRegisteredTags: [String]?
    
    // Event tracking
    private(set) var lastCustomEventName: String?
    private(set) var lastCustomEventMetadata: [String: Any]?
    
    // Metadata tracking
    private(set) var lastMetadataOperation: MetadataOperationType?
    private(set) var lastMetadataUpdate: [String: Any]?
    
    // Stream state handler
    private(set) var lastStateChangeHandler: ((MessageStreamState) -> Void)?
    
    func openMessageStream(onStateChange: @escaping (MessageStreamState) -> Void) {
        isMessageStreamOpened = true
        lastStateChangeHandler = onStateChange
    }
    
    func registerUserID(_ newUserID: String) {
        lastRegisteredUserID = newUserID
    }
    
    func registerTags(_ tags: [String]) {
        lastRegisteredTags = tags
    }
    
    func sendCustomEvent(name: String, metadata: [String: Any]) {
        lastCustomEventName = name
        lastCustomEventMetadata = metadata
    }
    
    func updateMetadata(_ operation: MetadataOperationType, metadata: [String: Any]?) {
        lastMetadataOperation = operation
        lastMetadataUpdate = metadata
    }
    
    func endConnection(wasManuallyDisconnected: Bool) {
        self.wasManuallyDisconnected = wasManuallyDisconnected
        isConnected = false
        isMessageStreamOpened = false
    }
    
    // Test helper methods
    func simulateConnectionState(_ state: MessageStreamState) {
        switch state {
        case .connected:
            isConnected = true
        case .disconnected:
            isConnected = false
        default:
            break
        }
        lastStateChangeHandler?(state)
    }
    
    func simulateMessageReceived(_ message: String) {
        lastStateChangeHandler?(.messageReceived(message))
    }
    
    func simulateHeartbeatReceived(_ status: String) {
        lastStateChangeHandler?(.heartbeatReceived(status))
    }
    
    func simulateConnectionError(_ error: Error) {
        lastStateChangeHandler?(.connectionError(error))
    }
    
    func reset() {
        isConnected = false
        isMessageStreamOpened = false
        wasManuallyDisconnected = false
        configuredApiKey = nil
        lastRegisteredUserID = nil
        lastRegisteredTags = nil
        lastCustomEventName = nil
        lastCustomEventMetadata = nil
        lastMetadataOperation = nil
        lastMetadataUpdate = nil
        lastStateChangeHandler = nil
    }
}
