//
//  Message.swift
//  Example
//
//  Created by Pushlytic on 11/25/24.
//

import Foundation

/// A sample message structure demonstrating how to create Codable models
/// for use with Pushlytic's message parsing system.
///
/// This model represents a complex nested JSON structure that can be automatically
/// decoded from messages received through the Pushlytic SDK.
///
/// Example JSON payload:
/// ```json
/// {
///     "id": 12345,
///     "name": "John Doe",
///     "age": 30,
///     "email": "john@example.com",
///     "address": {
///         "street": "123 Main St",
///         "city": "San Francisco",
///         "state": "CA",
///         "zip": "94105"
///     },
///     "marketing": {
///         "name": "Spring Campaign",
///         "email": "spring@marketing.com",
///         "message": "Check out our spring sale!"
///     },
///     "preferences": {
///         "newsletter": true,
///         "notifications": false
///     }
/// }
/// ```
///
/// Usage with Pushlytic:
/// ```swift
/// class MessageHandler: PushlyticDelegate {
///     func pushlytic(didReceiveMessage message: String) {
///         Pushlytic.parseMessage(message) { (message: Message) in
///             // Access parsed message properties
///             print("Received message for: \(message.name)")
///             if let city = message.address?.city {
///                 print("User is from: \(city)")
///             }
///             // Handle marketing preferences
///             if message.preferences.notifications {
///                 // Setup notifications
///             }
///         } errorHandler: { error in
///             print("Failed to parse message: \(error)")
///         }
///     }
/// }
/// ```
struct Message: Codable {
    let address: Address?
    let age: Int
    let email: String
    let id: Int
    let marketing: Marketing
    let name: String
    let preferences: Preferences
}

struct Address: Codable {
    let city: String
    let state: String
    let street: String
    let zip: String
}

struct Marketing: Codable {
    let email: String
    let message: String
    let name: String
}

struct Preferences: Codable {
    let newsletter: Bool
    let notifications: Bool
}
