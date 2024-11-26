//
//  CartView.swift
//  Example
//
//  Created by Pushlytic on 11/25/24.
//

import Pushlytic
import SwiftUI

struct CartView: View {
   @State private var cartItems = ["Item 1", "Item 2", "Item 3"]
   
   var body: some View {
       NavigationView {
           List {
               ForEach(cartItems, id: \.self) { item in
                   Text(item)
               }
               .onDelete(perform: removeItems)
           }
           .navigationTitle("Cart")
           .toolbar {
               Button("Checkout") {
                   checkout()
               }
           }
       }
   }
   
   /// Removes items from cart and sends analytics event via Pushlytic
   /// Example event:
   /// ```json
   /// {
   ///     "name": "cart_item_removed",
   ///     "metadata": {
   ///         "remaining_items": 2
   ///     }
   /// }
   /// ```
   private func removeItems(at offsets: IndexSet) {
       cartItems.remove(atOffsets: offsets)
       // Track cart item removal with remaining item count
       Pushlytic.sendCustomEvent(name: "cart_item_removed", metadata: ["remaining_items": cartItems.count])
   }
   
   /// Initiates checkout and sends analytics event via Pushlytic
   /// Example event:
   /// ```json
   /// {
   ///     "name": "checkout_initiated",
   ///     "metadata": {
   ///         "items_count": 3
   ///     }
   /// }
   /// ```
   private func checkout() {
       // Track checkout initiation with total items in cart
       Pushlytic.sendCustomEvent(name: "checkout_initiated", metadata: ["items_count": cartItems.count])
   }
}
