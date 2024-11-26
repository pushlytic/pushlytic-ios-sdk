//
//  HeartbeatManagerTests.swift
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

final class HeartbeatManagerTests: XCTestCase {
    
    private var manager: HeartbeatManager!
    
    override func tearDown() {
        manager?.stopMonitoring()
        manager = nil
        super.tearDown()
    }
    
    func testTimeoutHandlerCalled() {
        let expectation = expectation(description: "Timeout handler called")
        manager = HeartbeatManager {
            expectation.fulfill()
        }
        
        manager.startMonitoring(interval: 0.1)
        wait(for: [expectation], timeout: 0.2)
    }
    
    func testStopMonitoringPreventsTimeout() {
        var timeoutCount = 0
        manager = HeartbeatManager {
            timeoutCount += 1
        }
        
        manager.startMonitoring(interval: 0.1)
        manager.stopMonitoring()
        
        // Wait to ensure timer doesn't fire
        Thread.sleep(forTimeInterval: 0.2)
        XCTAssertEqual(timeoutCount, 0)
    }
    
    func testRestartingMonitoring() {
        let expectation = expectation(description: "Second timer fired")
        var timeoutCount = 0
        
        manager = HeartbeatManager {
            timeoutCount += 1
            if timeoutCount == 2 {
                expectation.fulfill()
            }
        }
        
        // Start with one interval
        manager.startMonitoring(interval: 0.2)
        
        // Restart with shorter interval
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.manager.startMonitoring(interval: 0.1)
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testMultipleTimeouts() {
        let expectation = expectation(description: "Multiple timeouts")
        var timeoutCount = 0
        
        manager = HeartbeatManager {
            timeoutCount += 1
            if timeoutCount == 3 {
                expectation.fulfill()
            }
        }
        
        manager.startMonitoring(interval: 0.1)
        wait(for: [expectation], timeout: 0.5)
        XCTAssertGreaterThanOrEqual(timeoutCount, 3)
    }
    
    func testConcurrentStartStop() {
        let iterations = 100
        let expectation = expectation(description: "Concurrent operations complete")
        expectation.expectedFulfillmentCount = iterations
        
        manager = HeartbeatManager {}
        
        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            self.manager.startMonitoring(interval: 0.1)
            self.manager.stopMonitoring()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeinitStopsTimer() {
        var timeoutCount = 0
        
        autoreleasepool {
            let localManager = HeartbeatManager {
                timeoutCount += 1
            }
            localManager.startMonitoring(interval: 0.1)
        }
        
        // Wait to ensure timer isn't running after deinit
        Thread.sleep(forTimeInterval: 0.2)
        XCTAssertEqual(timeoutCount, 0)
    }
}
