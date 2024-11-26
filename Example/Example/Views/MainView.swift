//
//  MainView.swift
//  Example
//
//  Created by Pushlytic on 11/25/24.
//

import Pushlytic
import SwiftUI

/// Example user data structure for demonstration
struct UserInfo {
   let userID: String
   let firstName: String
   let lastName: String
   let email: String
   let premiumStatus: Bool
}

struct MainView: View {
   @EnvironmentObject var appState: AppState
   @State private var userInfo: UserInfo?
   
   var body: some View {
       NavigationView {
           VStack(spacing: 20) {
               Text("Connection Status: \(appState.connectionStatus)")
                   .padding()
                   .background(Color.gray.opacity(0.2))
                   .cornerRadius(8)
               
               if let userInfo = userInfo {
                   Text("Welcome, \(userInfo.firstName) \(userInfo.lastName)!")
                       .font(.headline)
               }
               
               Button("Send Custom Event") {
                   // Track button interaction
                   // Example event:
                   // {
                   //     "name": "main_button_tapped",
                   //     "metadata": {
                   //         "screen": "main"
                   //     }
                   // }
                   Pushlytic.sendCustomEvent(name: "main_button_tapped", metadata: ["screen": "main"])
               }
               .padding()
               .background(Color.blue)
               .foregroundColor(.white)
               .cornerRadius(8)
               
               NavigationLink(destination: DetailView()) {
                   Text("Go to Detail View")
                       .padding()
                       .background(Color.green)
                       .foregroundColor(.white)
                       .cornerRadius(8)
               }
           }
           .navigationTitle("Main")
           .onAppear {
               fetchEarlyLifecycleData()
           }
       }
   }
   
   /// Simulates fetching early app lifecycle data and initializes Pushlytic with user information
   ///
   /// In a production app:
   /// - Replace the delay with actual API calls
   /// - Handle authentication states
   /// - Manage error cases
   private func fetchEarlyLifecycleData() {
       // Demo delay - remove in production
       DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
           self.userInfo = UserInfo(userID: "12345",
                                  firstName: "Doug",
                                  lastName: "Jones",
                                  email: "doug@example.com",
                                  premiumStatus: true)
           setEarlyMetadata()
           registerUserWithPushlytic()
       }
   }
   
   /// Sets initial metadata for the Pushlytic connection
   ///
   /// This demonstrates comprehensive metadata setup including:
   /// - User information
   /// - Device details
   /// - App configuration
   /// - A/B test assignments
   ///
   /// Example metadata payload:
   /// ```json
   /// {
   ///     "treatment": "treatment_one",
   ///     "first_name": "Doug",
   ///     "last_name": "Jones",
   ///     "email": "doug@example.com",
   ///     "premium_status": true,
   ///     "app_version": "1.0.0",
   ///     "device_type": "iPhone",
   ///     "os_version": "17.0",
   ///     "device_model": "iPhone"
   /// }
   /// ```
   private func setEarlyMetadata() {
       guard let userInfo = userInfo else { return }
       
       let metadata: [String: Any] = [
           "treatment": "treatment_one",
           "first_name": userInfo.firstName,
           "last_name": userInfo.lastName,
           "email": userInfo.email,
           "premium_status": userInfo.premiumStatus,
           "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
           "device_type": "iPhone",
           "os_version": UIDevice.current.systemVersion,
           "device_model": UIDevice.current.model
       ]
       
       // Set initial connection metadata
       // Note: Subsequent calls to setMetadata will upsert rather than replace
       // Use clearMetadata() first if you need to reset all metadata
       Pushlytic.setMetadata(metadata)
   }
   
   /// Registers user identification and segmentation data with Pushlytic
   ///
   /// This method:
   /// 1. Sets a unique user identifier for message targeting
   /// 2. Adds tags for user segmentation (e.g., platform, test groups)
   ///
   /// Note: User registration should typically happen early in the app lifecycle,
   /// but after any necessary authentication
   private func registerUserWithPushlytic() {
       guard let userInfo = userInfo else { return }
       // Register unique user identifier
       Pushlytic.registerUserID(userInfo.userID)
       
       // Add tags for user segmentation
       Pushlytic.registerTags(["iOS", "Treatment 2"])
   }
}
