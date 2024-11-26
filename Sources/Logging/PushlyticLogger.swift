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

protocol PushlyticLogger {
    
    /// Logs an informational message.
    /// - Parameters:
    ///   - tag: The tag associated with the log message
    ///   - message: The message to log
    func logInfo(tag: String, message: String)
    
    /// Logs a warning message.
    /// - Parameters:
    ///   - tag: The tag associated with the log message
    ///   - message: The message to log
    func logWarning(tag: String, message: String)
    
    /// Logs an error message.
    /// - Parameters:
    ///   - tag: The tag associated with the log message
    ///   - message: The message to log
    ///   - error: An optional error to log
    func logError(tag: String, message: String, error: Error?)
}
