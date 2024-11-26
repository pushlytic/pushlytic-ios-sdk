//
//  MockLifecycleManager.swift
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

/// Mock implementation of `LifecycleManagerProtocol` for testing purposes.
final class MockLifecycleManager: LifecycleManagerProtocol {
    var cleanupCalled = false
    var stateTransitions: [LifecycleManager.AppState] = []

    func handleStateTransition(to state: LifecycleManager.AppState) {
        stateTransitions.append(state)
    }

    func cleanup() {
        cleanupCalled = true
    }
}
