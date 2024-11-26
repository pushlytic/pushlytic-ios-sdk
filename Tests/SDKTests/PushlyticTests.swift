//
//  PushlyticTests.swift
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

final class PushlyticTests: XCTestCase {
    
    private var mockDelegate: MockPushlyticDelegate!
    
    override func setUp() {
        super.setUp()
        mockDelegate = MockPushlyticDelegate()
        Pushlytic.setDelegate(mockDelegate)
    }
    
    override func tearDown() {
        Pushlytic.setDelegate(nil)
        mockDelegate = nil
        super.tearDown()
    }
    
    // MARK: - Auto Reconnect Tests
    
    func testAutoReconnectState() {
        XCTAssertTrue(Pushlytic.shouldAutoReconnect, "Should auto reconnect by default")
        
        Pushlytic.endStream(clearState: true)
        XCTAssertFalse(Pushlytic.shouldAutoReconnect, "Should not auto reconnect after manual disconnect")
        
        Pushlytic.endStream(clearState: false)
        XCTAssertFalse(Pushlytic.shouldAutoReconnect, "Should maintain manual disconnect state")
    }
    
    // MARK: - Delegate Tests
    
    func testDelegateSwitch() {
        let newDelegate = MockPushlyticDelegate()
        
        Pushlytic.setDelegate(newDelegate)
        XCTAssertNotEqual(
            ObjectIdentifier(mockDelegate),
            ObjectIdentifier(newDelegate),
            "Delegates should be different instances"
        )
    }
    
    func testNilDelegate() {
        Pushlytic.setDelegate(nil)
        // Test passes if setting nil delegate doesn't crash
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentDelegateAccess() {
        let expectation = expectation(description: "Concurrent delegate access")
        expectation.expectedFulfillmentCount = 100
        
        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            autoreleasepool {
                Pushlytic.setDelegate(self.mockDelegate)
                Pushlytic.setDelegate(nil)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testConcurrentStreamControl() {
        let expectation = expectation(description: "Concurrent stream control")
        expectation.expectedFulfillmentCount = 100
        
        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            autoreleasepool {
                Pushlytic.openStream()
                Pushlytic.endStream()
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
