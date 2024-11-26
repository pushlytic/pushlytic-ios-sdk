//
//  MessageModalView.swift
//  Example
//
//  Created by Pushlytic on 11/25/24.
//

import SwiftUI

struct MessageModalView: View {
    let message: Message
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .font(.title)
                            .padding()
                    }
                    Spacer()
                }
                
                Spacer()
                
                Text("Welcome, \(message.marketing.name)!")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                
                Text(message.marketing.email)
                    .font(.title2)
                
                Text(message.marketing.message)
                    .font(.body)
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(10)
                
                Spacer()
            }
            .padding()
        }
    }
}
