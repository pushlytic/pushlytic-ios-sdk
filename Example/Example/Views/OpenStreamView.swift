//
//  OpenStreamView.swift
//  Example
//
//  Created by Pushlytic on 11/25/24.
//

import Pushlytic
import SwiftUI

/// Delegate class that handles Pushlytic connection status and message events
/// Demonstrates proper implementation of the PushlyticDelegate protocol
class MessagingDelegate: PushlyticDelegate {
   private var appState: AppState
   
   init(appState: AppState) {
       self.appState = appState
   }
   
   /// Handles connection status updates from Pushlytic
   /// Updates the UI to reflect the current connection state
   ///
   /// Status can be one of:
   /// - Connected: Successfully connected to Pushlytic servers
   /// - Disconnected: Connection ended normally
   /// - Error: Connection failed with specific error
   /// - Timeout: Connection timed out
   func pushlytic(didChangeConnectionStatus status: ConnectionStatus) {
       DispatchQueue.main.async {
           switch status {
           case .connected:
               self.appState.connectionStatus = "Connected"
           case .disconnected:
               self.appState.connectionStatus = "Disconnected"
           case .error(let error):
               self.appState.connectionStatus = "Error: \(error.localizedDescription)"
           case .timeout:
               self.appState.connectionStatus = "Connection timeout"
           }
       }
   }
   
   /// Handles incoming messages from Pushlytic
   /// Parses messages into strongly-typed Message objects
   ///
   /// Example message format:
   /// ```json
   /// {
   ///     "id": 12345,
   ///     "name": "John Doe",
   ///     "email": "john@example.com",
   ///     ...
   /// }
   /// ```
   func pushlytic(didReceiveMessage message: String) {
       Pushlytic.parseMessage(message) { (message: Message) in
           self.appState.currentMessage = message
           self.appState.showingMessage = true
       } errorHandler: { error in
           //Handle Error
       }
   }
}

struct OpenStreamView: View {
   @EnvironmentObject var appState: AppState

   var body: some View {
       VStack {
           Text("Welcome to our Demo")
               .font(.largeTitle)
               .padding()

           Button("Open Stream") {
               openStream()
           }
           .padding()
           .background(Color.blue)
           .foregroundColor(.white)
           .cornerRadius(8)
       }
   }

    /// Opens a Pushlytic message stream
    /// Note: The artificial delay is for demonstration purposes only and should not be used in production
    ///
    /// In a production environment, you should:
    /// - Open the stream immediately when needed
    /// - Handle connection state through the PushlyticDelegate
    private func openStream() {
       // Demo delay - remove in production
       DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
           appState.isStreamOpen = true
           // Initialize stream communication with Pushlytic servers
           Pushlytic.openStream()
       }
    }
}
