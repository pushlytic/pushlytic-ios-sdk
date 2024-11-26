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

Get started with Pushlytic in your iOS app - it's quick and easy! 

### Swift Package Manager
1. Open Xcode and go to `File > Add Packages...`
2. Enter the package URL: `https://github.com/pushlytic/pushlytic-ios-sdk`
3. Set the dependency rule to **Up to Next Minor Version**, starting at `0.1.0`
4. Add the package to your desired target

> **Note**: We're rapidly improving Pushlytic! 🚀 During our pre-1.0 phase:
> - Minor version updates (0.x.0) may include exciting new features and improvements that could have breaking changes
> - Using "Up to Next Minor" ensures you get all bug fixes while maintaining stability
> - Once we hit 1.0.0, we'll follow strict semantic versioning with "Up to Next Major Version"
>
> Join us early and help shape the future of push infrastructure! Your feedback and use cases are invaluable as we move toward our 1.0.0 release.

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

### Stream Management
```swift
// Open a connection to start receiving messages
Pushlytic.openStream()

// Later, when you want to stop receiving messages:
// - Set clearState to false to allow automatic reconnection on app foreground
// - Set clearState to true to clear all connection metadata and prevent automatic reconnection
Pushlytic.endStream(clearState: false)
```

### Set Up User Information
```swift
// Ensure the stream is opened before registering connection data
// Open a connection to start receiving messages
Pushlytic.openStream()

// You must open the stream first before registering connection data, such as user ID, tags, or metadata.
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
