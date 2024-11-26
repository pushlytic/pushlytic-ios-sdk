//
//  MockMessageStreamState.swift
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

/// Mock implementation to simulate `MessageStreamState` behavior.
enum MockMessageStreamState {
    case connected
    case messageReceived(String)
    case connectionError(Error)
    case disconnected
    case timeout
    
    static func simulateStateChange(
        to state: MockMessageStreamState,
        using callback: (MessageStreamState) -> Void
    ) {
        switch state {
        case .connected:
            callback(.connected)
        case .messageReceived(let message):
            callback(.messageReceived(message))
        case .connectionError(let error):
            callback(.connectionError(error))
        case .disconnected:
            callback(.disconnected)
        case .timeout:
            callback(.timeout)
        }
    }
}

