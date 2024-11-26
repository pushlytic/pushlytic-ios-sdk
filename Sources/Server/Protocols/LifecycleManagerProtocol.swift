//
//  LifecycleManagerProtocol.swift
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
/// Protocol defining the contract for managing application lifecycle events.
///
/// `LifecycleManagerProtocol` enables decoupling of the lifecycle management logic
/// from its implementation, facilitating testing and future extensibility.
protocol LifecycleManagerProtocol: AnyObject {
    
    /// Initializes the lifecycle manager and sets up observers for application lifecycle events.
    init()

    /// Handles application state transitions.
    /// - Parameter newState: The new application state.
    func handleStateTransition(to newState: LifecycleManager.AppState)

    /// Cleans up resources and removes lifecycle observers.
    ///
    /// - Note: This method should ensure no memory leaks or dangling observers remain.
    func cleanup()
}
