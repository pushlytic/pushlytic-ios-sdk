//
//  MockHeartbeatManager.swift
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
@testable import Pushlytic

/// Mock implementation of `HeartbeatManagerProtocol` for testing purposes.
final class MockHeartbeatManager: HeartbeatManagerProtocol {
    var timeoutHandler: () -> Void
    var startMonitoringCalled = false
    var stopMonitoringCalled = false
    var lastInterval: TimeInterval?
    
    required init(timeoutHandler: @escaping () -> Void) {
        self.timeoutHandler = timeoutHandler
    }
    
    func startMonitoring(interval: TimeInterval) {
        startMonitoringCalled = true
        lastInterval = interval
    }
    
    func stopMonitoring() {
        stopMonitoringCalled = true
    }
    
    func simulateTimeout() {
        timeoutHandler()
    }
}
