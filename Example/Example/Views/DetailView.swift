//
//  DetailView.swift
//  Example
//
//  Created by Pushlytic on 11/25/24.
//

import Pushlytic
import SwiftUI

struct DetailView: View {
   var body: some View {
       VStack(spacing: 20) {
           Text("Detail View")
               .font(.title)
           
           Button("Perform Action") {
               // Track user interactions with custom events
               // Example event:
               // {
               //     "name": "detail_action_performed",
               //     "metadata": {
               //         "action": "button_tap"
               //     }
               // }
               Pushlytic.sendCustomEvent(name: "detail_action_performed", metadata: ["action": "button_tap"])
           }
           .padding()
           .background(Color.orange)
           .foregroundColor(.white)
           .cornerRadius(8)
           
           Button("Update Some Metadata") {
               updatePartialMetadata()
           }
           .padding()
           .background(Color.orange)
           .foregroundColor(.white)
           .cornerRadius(8)
           
           Button("Clear All Metadata") {
               // Removes all metadata associated with the current connection
               Pushlytic.clearMetadata()
           }
           .padding()
           .background(Color.red)
           .foregroundColor(.white)
           .cornerRadius(8)
       }
       .navigationTitle("Detail")
       .onAppear {
           // Track view lifecycle events
           Pushlytic.sendCustomEvent(name: "detail_view_opened", metadata: [:])
       }
   }

    /// Updates specific metadata fields without affecting other existing metadata
    ///
    /// Pushlytic.setMetadata performs an upsert operation:
    /// - Existing fields are updated with new values
    /// - New fields are added
    /// - Unmentioned fields remain unchanged
    ///
    /// Note: To completely reset metadata before setting new values,
    /// first call Pushlytic.clearMetadata() followed by setMetadata()
    ///
    /// Example metadata update:
    /// ```json
    /// {
    ///     "last_name": "Smith",
    ///     "os_version": "17.0",
    ///     "device_info": {
    ///         "screen_size": "6.1 inch",
    ///         "brightness": 0.8
    ///     },
    ///     "new_top_level": "value"
    /// }
    /// ```
    private func updatePartialMetadata() {
       let updatedMetadata: [String: Any] = [
           "last_name": "Smith",        // Updates existing field
           "os_version": "17.0",        // Updates existing field
           "device_info": [             // Adds new nested structure
               "screen_size": "6.1 inch",
               "brightness": 0.8
           ],
           "new_top_level": "value"     // Adds new field
       ]
       
       // To completely replace metadata instead of upserting:
       // Pushlytic.clearMetadata()
       // Pushlytic.setMetadata(updatedMetadata)
       
       // Performs upsert - updates existing fields and adds new ones
       Pushlytic.setMetadata(updatedMetadata)
    }
}
