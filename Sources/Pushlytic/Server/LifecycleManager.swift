//
//  LifecycleManager.swift
//  Pushlytic
//
//  Copyright © 2024 Pushlytic.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import UIKit

/// Manages application lifecycle events for the Pushlytic SDK.
///
/// `LifecycleManager` is responsible for:
/// - Monitoring application state transitions (e.g., foreground, background, terminated)
/// - Managing connection state based on application lifecycle events
/// - Ensuring proper cleanup of resources to avoid memory leaks
/// - Maintaining connection state across app termination and relaunch
///
/// The manager listens for `UIApplication` notifications to detect state changes,
/// enabling the SDK to handle connection management seamlessly based on app state.
final class LifecycleManager: LifecycleManagerProtocol {
    
    // MARK: - Types
    
    /// Represents possible states of the application relevant to SDK management.
    enum AppState {
        case foreground
        case background
        case terminated
    }
    
    /// Provides thread safety utilities for asserting main-thread execution and dispatching to the main thread.
    private enum ThreadSafety {

        /// Ensures a block is executed on the main thread.
        static func ensureMainThread(_ block: @escaping () -> Void) {
            if Thread.isMainThread {
                block()
            } else {
                DispatchQueue.main.async(execute: block)
            }
        }
    }
    
    // MARK: - Properties
    
    /// Observers for lifecycle notifications.
    private var notificationObservers: [NSObjectProtocol] = []
    
    /// Current application state.
    private var currentState: AppState = .foreground
    
    /// Lock to ensure thread-safe operations on shared resources.
    private let lock = NSLock()
    
    // MARK: - Initialization
    
    /// Initializes a new `LifecycleManager` and sets up lifecycle observers.
    ///
    /// The setup of lifecycle observers is ensured to happen on the main thread, as required by `UIApplication` notifications.
    init() {
        if Thread.isMainThread {
            setupLifecycleObservers()
        } else {
            DispatchQueue.main.sync {
                setupLifecycleObservers()
            }
        }
    }
    
    // MARK: - Observer Setup
    
    /// Sets up observers to monitor application lifecycle notifications.
    private func setupLifecycleObservers() {
        let backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleStateTransition(to: .background)
        }
        
        let foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleStateTransition(to: .foreground)
        }
        
        let terminationObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleStateTransition(to: .terminated)
        }
        
        lock.lock()
        notificationObservers = [backgroundObserver, foregroundObserver, terminationObserver]
        lock.unlock()
    }
    
    // MARK: - State Management
    
    /// Handles application state transitions by managing SDK connection accordingly.
    ///
    /// - Parameter newState: The new application state.
    internal func handleStateTransition(to newState: AppState) {
        lock.lock()
        currentState = newState
        lock.unlock()
        
        switch newState {
        case .background:
            handleBackgroundTransition()
        case .foreground:
            handleForegroundTransition()
        case .terminated:
            handleTermination()
        }
    }
    
    // MARK: - Lifecycle Handlers
    
    /// Handles background transition by ending the stream if it’s currently connected.
    private func handleBackgroundTransition() {
        if Pushlytic.isConnected {
            Pushlytic.endStream()
        }
    }
    
    /// Handles foreground transition by reopening the stream if auto-reconnect is enabled.
    private func handleForegroundTransition() {
        if Pushlytic.shouldAutoReconnect {
            Pushlytic.openStream()
        }
    }
    
    /// Handles application termination by ensuring any active connections are properly closed.
    private func handleTermination() {
        if Pushlytic.isConnected {
            Pushlytic.endStream()
        }
    }
    
    // MARK: - Cleanup
    
    /// Removes lifecycle observers and releases any retained resources.
    ///
    /// This function is thread-safe and ensures cleanup happens on the main thread.
    func cleanup() {
        lock.lock()
        let observers = notificationObservers
        notificationObservers.removeAll()
        lock.unlock()

        // Use weak self to prevent retain cycle
        ThreadSafety.ensureMainThread { [weak self] in
            observers.forEach { observer in
                NotificationCenter.default.removeObserver(observer)
            }
            // Clear remaining references within self after cleanup to avoid dangling pointers
            self?.notificationObservers.removeAll()
        }
    }

    deinit {
        ThreadSafety.ensureMainThread { [weak self] in
            self?.cleanup()
        }
    }
}
