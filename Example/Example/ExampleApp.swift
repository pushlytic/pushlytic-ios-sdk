//
//  ExampleApp.swift
//  Example
//
//  Created by Pushlytic on 11/25/24.
//

import Pushlytic
import SwiftUI

/// Example app demonstrating basic Pushlytic SDK setup and configuration
@main
struct ExampleApp: App {
    @StateObject private var appState = AppState()

    /// Delegate handles incoming messages and connection status updates from Pushlytic
    private let messagingDelegate: MessagingDelegate

    init() {
        let appState = AppState()
        self.messagingDelegate = MessagingDelegate(appState: appState)
        self._appState = StateObject(wrappedValue: appState)
        
        // Initialize Pushlytic SDK
        // 1. Set the delegate to handle incoming messages and connection status
        Pushlytic.setDelegate(messagingDelegate)
        // 2. Configure with your API key from the Pushlytic dashboard
        Pushlytic.configure(with: Pushlytic.Configuration(apiKey: "YOUR_API_KEY"))
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
