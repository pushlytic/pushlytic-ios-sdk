//
//  MockPushlyticDelegate.swift
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

/// Mock implementation of the `PushlyticDelegate` protocol for testing purposes.
class MockPushlyticDelegate: PushlyticDelegate {
    
    var connectionStatusChanges: [ConnectionStatus] = []
    var receivedMessages: [String] = []
    var receivedHeartbeats: [String] = []
    
    func pushlytic(didChangeConnectionStatus status: ConnectionStatus) {
        connectionStatusChanges.append(status)
    }
    
    func pushlytic(didReceiveMessage message: String) {
        receivedMessages.append(message)
    }
    
    func pushlytic(didReceiveHeartbeat status: String) {
        receivedHeartbeats.append(status)
    }
}
