//
//  PushlyticDelegate.swift
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

/// Protocol for receiving real-time updates from the Pushlytic SDK
///
/// This delegate protocol allows your application to respond to:
/// - Connection state changes
/// - Incoming messages
/// - System heartbeats
///
/// # Thread Safety
/// All delegate methods are called on the main thread for UI safety.
///
/// # Implementation Example
/// ```swift
/// class MessageHandler: PushlyticDelegate {
///     func pushlytic(didChangeConnectionStatus status: ConnectionStatus) {
///         switch status {
///         case .connected:
///             print("Connected to message stream")
///         case .disconnected:
///             print("Disconnected from message stream")
///         case .error(let error):
///             handleError(error)
///         case .timeout:
///             handleTimeout()
///         }
///     }
///
///     func pushlytic(didReceiveMessage message: String) {
///         print("Received message: \(message)")
///     }
/// }
/// ```
public protocol PushlyticDelegate: AnyObject {
    
    /// Called when the connection status changes
    /// - Parameter status: The new connection status
    /// - Note: This method is called on the main thread
    func pushlytic(didChangeConnectionStatus status: ConnectionStatus)
    
    /// Called when a new message is received
    /// - Parameter message: The received message content
    /// - Note: This method is called on the main thread
    func pushlytic(didReceiveMessage message: String)
}
