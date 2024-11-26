//
//  LifecycleManagerTests.swift
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

import XCTest
@testable import Pushlytic

final class LifecycleManagerTests: XCTestCase {
    
    private var lifecycleManager: LifecycleManager!
    
    override func setUp() {
        super.setUp()
        lifecycleManager = LifecycleManager()
    }
    
    override func tearDown() {
        lifecycleManager.cleanup()
        lifecycleManager = nil
        super.tearDown()
    }
    
    // MARK: - State Transition Tests
    
    func testStateTransitions() {
        lifecycleManager.handleStateTransition(to: .background)
        lifecycleManager.handleStateTransition(to: .foreground)
        lifecycleManager.handleStateTransition(to: .terminated)
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentStateTransitions() {
        let expectation = expectation(description: "Concurrent transitions complete")
        expectation.expectedFulfillmentCount = 100
        
        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            self.lifecycleManager.handleStateTransition(to: .background)
            self.lifecycleManager.handleStateTransition(to: .foreground)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testConcurrentCleanup() {
        let expectation = expectation(description: "Concurrent cleanup complete")
        expectation.expectedFulfillmentCount = 100
        
        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            self.lifecycleManager.cleanup()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Initialization Tests
    
    func testBackgroundThreadInitialization() {
        let expectation = expectation(description: "Background initialization complete")
        
        DispatchQueue.global().async {
            let manager = LifecycleManager()
            manager.cleanup()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testMainThreadInitialization() {
        let manager = LifecycleManager()
        manager.cleanup()
    }
}
