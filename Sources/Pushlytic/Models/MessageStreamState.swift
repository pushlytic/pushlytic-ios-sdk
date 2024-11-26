//
//  MessageStreamState.swift
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

/// Represents the various states of the message stream connection in the Pushlytic SDK.
///
/// `MessageStreamState` allows SDK consumers to track the current state of the message stream
/// and handle incoming messages, connection errors, and heartbeat checks seamlessly.
///
/// Cases:
/// - `.connected`: The message stream is successfully connected.
/// - `.messageReceived(String)`: A message has been received from the stream, with the message contents provided as an associated value.
/// - `.heartbeatReceived(String)`: A heartbeat signal has been received, containing a status message.
/// - `.connectionError(Error)`: An error occurred with the message stream connection, providing an `Error` associated value.
/// - `.disconnected`: The message stream connection has been disconnected.
/// - `.timeout`: The connection attempt timed out, typically due to network or server conditions.
///
/// The `Equatable` conformance facilitates efficient state comparison.
enum MessageStreamState: Equatable {
    /// The message stream is successfully connected.
    case connected
    
    /// A message has been received from the stream.
    case messageReceived(String)
    
    /// An error occurred with the message stream connection.
    case connectionError(Error)
    
    /// The message stream connection has been disconnected.
    case disconnected
    
    /// The connection attempt timed out.
    case timeout
    
    // Implement Equatable manually due to Error not conforming to Equatable
    static func == (lhs: MessageStreamState, rhs: MessageStreamState) -> Bool {
        switch (lhs, rhs) {
        case (.connected, .connected),
             (.disconnected, .disconnected),
             (.timeout, .timeout):
            return true
        case (.messageReceived(let lhsMessage), .messageReceived(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.connectionError(let lhsError), .connectionError(let rhsError)):
            // Compare localized descriptions as a proxy for error equality
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

