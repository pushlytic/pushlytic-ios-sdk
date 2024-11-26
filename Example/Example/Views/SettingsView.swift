//
//  SettingsView.swift
//  Example
//
//  Created by Pushlytic on 11/25/24.
//

import Pushlytic
import SwiftUI

struct SettingsView: View {
   @State private var notifications = true
   @EnvironmentObject var appState: AppState
   
   var body: some View {
       NavigationView {
           Form {
               Section(header: Text("Preferences")) {
                   Toggle("Enable Notifications", isOn: $notifications)
                       .onChange(of: notifications) { oldValue, newValue in
                           // Track notification preference changes
                           // Example event:
                           // {
                           //     "name": "notifications_toggled",
                           //     "metadata": {
                           //         "enabled": true/false
                           //     }
                           // }
                           Pushlytic.sendCustomEvent(
                               name: "notifications_toggled",
                               metadata: ["enabled": newValue]
                           )
                       }
               }
               
               Section {
                   Button("Close Stream") {
                       closeStream()
                   }
                   .foregroundColor(.red)
               }
           }
           .navigationTitle("Settings")
       }
   }

    /// Closes the Pushlytic message stream
    ///
    /// This example demonstrates stream closure with complete state clearing.
    /// Note that while connections automatically close when the app backgrounds,
    /// explicitly closing with clearState:
    /// - true: Removes all stored data (user ID, metadata, tags) and prevents reconnection
    /// on foregrounding
    /// - false: Would preserve data for automatic reconnection on foregrounding
    ///
    /// In production apps:
    /// - Handle connection states through PushlyticDelegate instead of direct UI updates
    /// - Consider preserving state (clearState: false) if you want automatic reconnection
    private func closeStream() {
       // End the stream and clear all connection data
       Pushlytic.endStream(clearState: true)
       
       // Demo UI updates - in production, handle through PushlyticDelegate
       appState.isStreamOpen = false
       appState.connectionStatus = "Disconnected"
    }
}
