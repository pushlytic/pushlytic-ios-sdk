//
//  APIClientProtocol.swift
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

/// Protocol for server communication in the Pushlytic SDK.
///
/// `APIClientProtocol` defines the behavior for managing server interactions,
/// such as opening a message stream, registering user-specific data, sending events,
/// and handling metadata.
///
/// This protocol is implemented by the `APIClient` class and serves as the foundation
/// for all server communication within the SDK.
///
/// # Thread Safety
/// All methods are expected to be thread-safe and can be called from any thread.
protocol APIClientProtocol: AnyObject {
    
    /// Indicates whether the client is currently connected to the message stream.
    ///
    /// - Returns: `true` if the client is connected, `false` otherwise.
    var isConnected: Bool { get }
    
    /// Opens a bi-directional message stream with the server.
    ///
    /// - Parameter onStateChange: A closure invoked whenever the message stream state changes.
    /// - Note: This method establishes a persistent connection to the server and handles
    ///   incoming messages or connection events.
    func openMessageStream(onStateChange: @escaping (MessageStreamState) -> Void)
    
    /// Registers a user identifier with the server.
    ///
    /// - Parameter newUserID: The unique identifier of the user to associate with the session.
    /// - Note: This allows the server to associate messages or analytics with a specific user.
    func registerUserID(_ newUserID: String)
    
    /// Registers tags to associate with the current session.
    ///
    /// - Parameter tags: An array of tags (e.g., feature flags, user segments) to register.
    /// - Note: Tags can be used for server-side personalization or filtering.
    func registerTags(_ tags: [String])
    
    /// Sends a custom event to the server for analytics or tracking purposes.
    ///
    /// - Parameters:
    ///   - name: The name of the event (e.g., "ButtonClicked").
    ///   - metadata: Additional metadata to send with the event, as a key-value dictionary.
    /// - Note: Metadata can include details such as timestamps, user actions, or session data.
    func sendCustomEvent(name: String, metadata: [String: Any])
    
    /// Updates or clears metadata associated with the current session.
    ///
    /// - Parameters:
    ///   - operation: The type of operation to perform (`update` or `clear`).
    ///   - metadata: The metadata to update, or `nil` if clearing metadata.
    /// - Note: Metadata provides dynamic configuration or contextual data for the session.
    func updateMetadata(_ operation: MetadataOperationType, metadata: [String: Any]?)
    
    /// Ends the current connection to the server.
    ///
    /// - Parameter wasManuallyDisconnected: A flag indicating whether the disconnection
    ///   was initiated by the user.
    /// - Note: If `wasManuallyDisconnected` is `true`, the client should not automatically reconnect.
    func endConnection(wasManuallyDisconnected: Bool)
}

