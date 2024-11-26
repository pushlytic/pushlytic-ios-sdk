//
//  HeartbeatManager.swift
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

import Foundation

/// Manages periodic heartbeat signals for monitoring connectivity.
///
/// `HeartbeatManager` periodically invokes a timeout handler to check for connectivity
/// or heartbeat reception, enabling clients to handle timeout events if the expected
/// heartbeat signal isn’t received within the specified interval.
///
/// Usage:
/// - Initialize with a timeout handler closure that defines the behavior on a missed heartbeat.
/// - Call `startMonitoring(interval:)` to begin the timer with a specified interval.
/// - Call `stopMonitoring()` to end the heartbeat monitoring, which is also called automatically upon deinitialization.
final class HeartbeatManager: HeartbeatManagerProtocol {
    
    /// Timer for scheduling heartbeat checks.
    private var timer: Timer?
    
    /// The closure executed when the heartbeat interval is missed.
    private let timeoutHandler: () -> Void
    
    /// Initializes a new `HeartbeatManager` instance.
    /// - Parameter timeoutHandler: Closure to be called upon heartbeat timeout.
    init(timeoutHandler: @escaping () -> Void) {
        self.timeoutHandler = timeoutHandler
    }
    
    /// Starts monitoring heartbeats at the specified interval.
    /// - Parameter interval: The time interval (in seconds) between each heartbeat check.
    ///
    /// If a previous timer exists, it stops the existing timer before creating a new one.
    func startMonitoring(interval: TimeInterval) {
        stopMonitoring()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                self?.timeoutHandler()
            }
        }
    }
    
    /// Stops the heartbeat monitoring.
    ///
    /// This method invalidates the timer if it exists and sets it to nil.
    func stopMonitoring() {
        DispatchQueue.main.async { [weak self] in
            self?.timer?.invalidate()
            self?.timer = nil
        }
    }
    
    deinit {
        stopMonitoring()
    }
}
