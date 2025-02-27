//
//  APIConstants.swift
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

import Foundation

struct APIConstants {
    static let heartbeatInterval: TimeInterval = 60
    static let heartbeatTimeout: TimeInterval = 300
    static let reconnectionDelay: TimeInterval = 10
    static let eventLoopThreads = 5
    static let serverHost = "stream.pushlytic.com"
    static let serverPort = 443
    static let bundleIdentifier = "com.pushlytic"
}
