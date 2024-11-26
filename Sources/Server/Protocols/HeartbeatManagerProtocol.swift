//
//  HeartbeatManagerProtocol.swift
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

/// Protocol defining the contract for managing heartbeat monitoring.
///
/// `HeartbeatManagerProtocol` enables decoupling of the heartbeat monitoring logic
/// from its implementation, facilitating testing and future extensibility. The protocol
/// defines methods for starting and stopping heartbeat monitoring with configurable intervals.
protocol HeartbeatManagerProtocol: AnyObject {
    
    /// Initializes a heartbeat manager with a timeout handler.
    /// - Parameter timeoutHandler: Closure to be called when a heartbeat timeout occurs.
    init(timeoutHandler: @escaping () -> Void)
    
    /// Starts monitoring heartbeats at the specified interval.
    /// - Parameter interval: The time interval (in seconds) between each heartbeat check.
    ///
    /// This method should handle any cleanup of existing monitoring before starting a new one.
    func startMonitoring(interval: TimeInterval)
    
    /// Stops the heartbeat monitoring.
    ///
    /// This method should ensure proper cleanup of any running timers or resources
    /// to prevent memory leaks or continued execution after stopping.
    func stopMonitoring()
}
