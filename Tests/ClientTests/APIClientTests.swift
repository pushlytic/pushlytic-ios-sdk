//
//  APIClientTests.swift
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
import GRPC
@testable import Pushlytic

final class APIClientTests: XCTestCase {
    
    private var client: APIClient!
    private var mockLogger: MockLogger!
    
    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        client = APIClient(apiKey: "test-api-key", logger: mockLogger)
    }
    
    override func tearDown() {
        client.endConnection(wasManuallyDisconnected: true)
        client = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Basic State Tests
    
    func testInitialState() {
        XCTAssertFalse(client.isConnected)
        XCTAssertNil(client.userID)
        XCTAssertNil(client.tags)
    }
    
    func testUserRegistration() {
        let userId = "test-user"
        client.registerUserID(userId)
        XCTAssertEqual(client.userID, userId)
    }
    
    func testTagsRegistration() {
        let tags = ["tag1", "tag2"]
        client.registerTags(tags)
        XCTAssertEqual(client.tags, tags)
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentOperations() {
        let expectation = expectation(description: "Concurrent operations complete")
        expectation.expectedFulfillmentCount = 100
        
        DispatchQueue.concurrentPerform(iterations: 100) { index in
            let userId = "user-\(index)"
            let tags = ["tag-\(index)"]
            
            // Test all public methods
            client.registerUserID(userId)
            client.registerTags(tags)
            client.sendCustomEvent(name: "event-\(index)", metadata: ["key": "value"])
            client.updateMetadata(.update, metadata: ["key": "value"])
            client.openMessageStream { _ in }
            client.endConnection()
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testConcurrentStateAccess() {
        let expectation = expectation(description: "Concurrent state access complete")
        expectation.expectedFulfillmentCount = 100
        
        let queue = DispatchQueue(label: "test.concurrent.queue", attributes: .concurrent)
        let group = DispatchGroup()
        
        for index in 0..<100 {
            group.enter()
            queue.async {
                // Read state
                _ = self.client.isConnected
                _ = self.client.userID
                _ = self.client.tags
                
                // Write state with static arrays
                let tags = ["tag-\(index)"]
                self.client.registerUserID("user-\(index)")
                self.client.registerTags(tags)
                
                expectation.fulfill()
                group.leave()
            }
        }
        
        group.wait()
        wait(for: [expectation], timeout: 5.0)
    }

    func testHighLoadConcurrentAccess() {
        let iterations = 1000
        let expectation = expectation(description: "High load concurrent access")
        expectation.expectedFulfillmentCount = iterations
        
        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            autoreleasepool {
                let tags = ["tag-\(index)"]
                self.client.registerTags(tags)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Error Cases
    
    func testEmptyAPIKey() {
        let invalidClient = APIClient(apiKey: "", logger: mockLogger)
        XCTAssertFalse(invalidClient.isConnected)
    }
    
    func testNilMetadataOnClear() {
        client.updateMetadata(.clear, metadata: nil)
        // Test passes if no crash occurs
    }
    
    // MARK: - Resource Management
    
    func testMultipleConnectionAttempts() {
        // Attempt multiple connections in quick succession
        for _ in 0..<10 {
            client.openMessageStream { _ in }
        }
        
        // Add small delay to allow internal queues to process
        let expectation = expectation(description: "Processing delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        // Only one connection attempt should be in progress
        // This test verifies that multiple calls don't cause issues
        XCTAssertFalse(client.isConnected) // We know it won't actually connect without a server
    }

    func testMultipleOpenAndCloseAttempts() {
        for _ in 0..<10 {
            client.openMessageStream { _ in }
            client.endConnection()
        }
        
        // Add small delay to allow internal queues to process
        let expectation = expectation(description: "Processing delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        // Verify final state
        XCTAssertFalse(client.isConnected)
    }

    func testConnectionStateTransitions() {
        // Initially disconnected
        XCTAssertFalse(client.isConnected)
        
        // Attempt connection
        client.openMessageStream { _ in }
        
        // End connection
        client.endConnection()
        
        // Verify disconnected state
        XCTAssertFalse(client.isConnected)
    }
    
    func testCleanupAfterManualDisconnection() {
        client.openMessageStream { _ in }
        client.endConnection(wasManuallyDisconnected: true)
        XCTAssertFalse(client.isConnected)
    }
    
    // MARK: - State Transitions
    
    func testStateAfterEndConnection() {
        client.openMessageStream { _ in }
        client.endConnection()
        XCTAssertFalse(client.isConnected)
    }
    
    func testStateAfterManualDisconnection() {
        client.openMessageStream { _ in }
        client.endConnection(wasManuallyDisconnected: true)
        XCTAssertFalse(client.isConnected)
    }
}
