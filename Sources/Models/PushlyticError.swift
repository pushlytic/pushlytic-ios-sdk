//
//  PushlyticError.swift
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

/// Represents possible errors that can occur in the PushlyticError SDK.
///
/// `PushlyticError` provides detailed error cases to describe various issues that might arise when using the SDK,
/// including configuration problems, network issues, and server rejections.
///
/// Cases:
/// - `.notConfigured`: The SDK has not been properly configured, such as a missing or invalid API key.
/// - `.notAuthorized`: Authorization failed, often due to an invalid API key.
/// - `.connectionLost`: The network connection was lost, commonly due to connectivity issues.
/// - `.invalidMessage`: The SDK received a message with an invalid format.
/// - `.connectionRejected`: The server rejected the connection request, suggesting an issue on the server side.
/// - `.custom(String)`: A custom error message, allowing for dynamic error descriptions.
///
/// The `Equatable` conformance allows SDK users to compare errors directly, which is helpful for error handling and retry logic.
public enum PushlyticError: Error, Equatable {
    /// SDK not properly configured (e.g., missing or invalid API key).
    case notConfigured
    
    /// Authorization failed (e.g., invalid API key).
    case notAuthorized
    
    /// Network connection lost, possibly due to connectivity issues.
    case connectionLost
    
    /// Invalid message format received by the SDK.
    case invalidMessage
    
    /// Message string could not be converted to valid JSON data.
    case invalidMessageFormat
    
    /// Server rejected the connection request.
    case connectionRejected
    
    /// Custom error with an associated description message.
    case custom(String)
    
    /// This implementation allows equality checking across all `PushlyticError` cases, including a detailed
    /// comparison for `.custom` errors based on their associated messages.
    public static func == (lhs: PushlyticError, rhs: PushlyticError) -> Bool {
        switch (lhs, rhs) {
        case (.notConfigured, .notConfigured),
             (.notAuthorized, .notAuthorized),
             (.connectionLost, .connectionLost),
             (.invalidMessage, .invalidMessage),
             (.invalidMessageFormat, .invalidMessageFormat),
             (.connectionRejected, .connectionRejected):
            return true
        case (.custom(let lhsMessage), .custom(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

// MARK: - Error Descriptions

extension PushlyticError: LocalizedError {
    /// Provides human-readable descriptions for each error case, enhancing diagnostics for end users.
    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "SDK not properly configured. Please ensure you've called configure() with a valid API key."
        case .notAuthorized:
            return "Authorization failed. Please check your API key and try again."
        case .connectionLost:
            return "Network connection lost. Please check your internet connection and try again."
        case .invalidMessage:
            return "Invalid message format received. Please verify the message content."
        case .invalidMessageFormat:
            return "Invalid message format. Unable to convert message string to JSON data."
        case .connectionRejected:
            return "Connection rejected by the server. Please try again later or contact support if the issue persists."
        case .custom(let message):
            return message
        }
    }
}
