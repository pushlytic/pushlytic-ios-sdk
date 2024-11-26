# Pushlytic iOS SDK

A powerful iOS SDK for real-time communication using enabling seamless push messages and real-time interactions in your iOS applications.

## Key Features
- Real-time bidirectional streaming
- User targeting with IDs, tags, and metadata
- Customizable push messages with dynamic templates
- Automatic connection management
- Support for experiments and A/B testing

## Requirements
- iOS 13.0+
- Swift 5.0+
- Swift Package Manager

## Installation

### Swift Package Manager
1. Open Xcode and go to `File > Add Packages...`
2. Enter the package URL: `https://github.com/your-org/pushlytic-ios-sdk`
3. Set the dependency rule to **Up to Next Major Version**, starting at `1.0.0`
4. Add the package to your desired target

## Quick Start

```swift
import SwiftUI
import Pushlytic

@main
struct YourApp: App {
    private let messagingDelegate: MessageHandler
    
    init() {
        self.messagingDelegate = MessageHandler()
        
        // Initialize Pushlytic with delegate
        Pushlytic.setDelegate(messagingDelegate)
        Pushlytic.configure(with: Pushlytic.Configuration(apiKey: "YOUR_API_KEY"))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Basic Usage

### Set Up User Information
```swift
// Register user ID
Pushlytic.registerUserID("unique_user_id")

// Add tags for targeting
Pushlytic.registerTags(["premium_user", "electronics"])

// Set user metadata
Pushlytic.setMetadata([
    "first_name": "John",
    "account_type": "premium"
])
```

### Handle Messages
```swift
class MessageHandler: PushlyticDelegate {
    func pushlytic(didReceiveMessage message: String) {
        // Handle raw message string
        print("Received message: \(message)")
        
        // Parse message into a custom type
        struct CustomMessage: Codable {
            let id: String
            let content: String
        }
        
        Pushlytic.parseMessage(message) { (customMessage: CustomMessage) in
            print("Parsed message - ID: \(customMessage.id), Content: \(customMessage.content)")
        } errorHandler: { error in
            print("Failed to decode message: \(error)")
        }
    }
    
    func pushlytic(didChangeConnectionStatus status: ConnectionStatus) {
        switch status {
        case .connected:
            print("Connected to message stream")
        case .disconnected:
            print("Disconnected from message stream")
        case .error(let error):
            print("Connection error: \(error)")
        case .timeout:
            print("Connection timeout")
        }
    }
}
```

### Type-Safe Message Parsing
The SDK provides a convenient way to parse incoming JSON messages into Swift types:

```swift
// Define your message types
struct CustomMessage: Codable {
    let id: String
    let content: String
    let metadata: MessageMetadata
}

struct MessageMetadata: Codable {
    let timestamp: Date
    let priority: String
}

// Parse incoming messages
Pushlytic.parseMessage(jsonString) { (message: CustomMessage) in
    // Access typed message properties
    print("Message ID: \(message.id)")
    print("Content: \(message.content)")
    print("Timestamp: \(message.metadata.timestamp)")
} errorHandler: { error in
    print("Parsing error: \(error)")
}
```

## Example App
An example app demonstrating usage of Pushlytic SDK features is available in the `Examples/` directory. It showcases:
- Stream connection
- Message handling
- User segmentation
- Metadata-driven personalization

## Repository Structure
- **Examples/**: Contains a fully functional example app demonstrating SDK usage
- **Sources/**: Core SDK functionality
- **Tests/**: Unit tests for SDK components

## Contributing
Contributions are welcome! Please see the `CONTRIBUTING.md` file for guidelines on submitting issues, feature requests, and pull requests.

## License
Pushlytic iOS SDK is available under the MIT License. See the `LICENSE` file for more information.

## Security & Support
- For security vulnerabilities, contact our security team at [security@pushlytic.com](mailto:security@pushlytic.com)
- For general support, reach out to [support@pushlytic.com](mailto:support@pushlytic.com) or visit our [documentation site](https://pushlytic.com/docs)

## Related Resources
- [Pushlytic Android SDK](https://github.com/pushlytic/pushlytic-android-sdk)
- [Pushlytic API Documentation](https://pushlytic.com/docs)
