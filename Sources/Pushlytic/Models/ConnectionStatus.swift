//
//  ConnectionStatus.swift
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

/// Represents the possible connection states of the Pushlytic SDK.
///
/// `ConnectionStatus` helps clients of the SDK understand the current state of the connection, enabling
/// them to manage user experience and retry logic effectively.
///
/// Cases:
/// - `.connected`: The SDK has successfully connected to the message stream.
/// - `.disconnected`: The SDK has been disconnected from the message stream, either intentionally or due to network issues.
/// - `.timeout`: The SDK's connection attempt has timed out, typically due to network conditions.
/// - `.error`: An error occurred during connection, providing details with an associated `PushlyticError`.
///
/// The `Equatable` conformance allows developers to easily compare different states for more efficient connection management.
public enum ConnectionStatus: Equatable {
    /// Successfully connected to the message stream.
    case connected
    
    /// Disconnected from the message stream.
    case disconnected
    
    /// Connection attempt timed out.
    case timeout
    
    /// An error occurred during connection, with an associated error.
    case error(PushlyticError)

    public static func == (lhs: ConnectionStatus, rhs: ConnectionStatus) -> Bool {
        switch (lhs, rhs) {
        case (.connected, .connected),
             (.disconnected, .disconnected),
             (.timeout, .timeout):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

