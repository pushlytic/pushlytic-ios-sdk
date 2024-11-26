//
//  RootView.swift
//  Example
//
//  Created by Pushlytic on 11/25/24.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var isStreamOpen = false
    @Published var connectionStatus = "Disconnected"
    @Published var currentMessage: Message?
    @Published var showingMessage = false
}

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            Group {
                if appState.isStreamOpen {
                    MainTabView()
                } else {
                    OpenStreamView()
                }
            }
        }
        .fullScreenCover(isPresented: $appState.showingMessage, content: {
            if let message = appState.currentMessage {
                MessageModalView(message: message, isPresented: $appState.showingMessage)
            }
        })
    }
}
