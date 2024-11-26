//
//  MainTabView.swift
//  Example
//
//  Created by Pushlytic on 11/25/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainView()
                .tabItem {
                    Label("Main", systemImage: "house")
                }
                .tag(0)
            
            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
}
