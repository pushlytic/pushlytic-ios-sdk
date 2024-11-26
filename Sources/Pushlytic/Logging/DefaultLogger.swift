//
//  APIClient.swift
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

import os

/// Default implementation of the `PushlyticLogger` protocol.
/// Logs messages using Apple's `os.Logger` framework.
///
/// - Since: 1.0.0
@available(iOS 14.0, *)
class DefaultLogger: PushlyticLogger {
    
    /// The underlying logger instance
    private let logger: Logger
    
    /// Initializes a new instance of DefaultLogger
    init() {
        self.logger = Logger(subsystem: "com.pushlytic.sdk", category: "PushlyticSDK")
    }
    
    func logInfo(tag: String, message: String) {
        logger.info("[\(tag)] \(message)")
    }
    
    func logWarning(tag: String, message: String) {
        logger.warning("[\(tag)] \(message)")
    }
    
    func logError(tag: String, message: String, error: Error?) {
        if let error = error {
            logger.error("[\(tag)] \(message): \(error.localizedDescription)")
        } else {
            logger.error("[\(tag)] \(message)")
        }
    }
}
