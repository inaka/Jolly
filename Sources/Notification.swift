// Notification.swift
// Jolly
//
// Copyright 2016 Erlang Solutions, Ltd. - http://erlang-solutions.com/
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// Models a Hipchat notification
struct Notification {
    let message: Message
    let color: Color
    let shouldNotify: Bool
    
    init(message: Message, color: Color = .gray, shouldNotify notify: Bool = true) {
        self.message = message
        self.color = color
        self.shouldNotify = notify
    }
}

extension Notification {
    struct Message {
        let text: String
        let format: Format
        
        init(_ text: String, format: Format = .html) {
            self.text = text
            self.format = format
        }
        
        enum Format: String {
            case html, text
        }
    }
    
    enum Color: String {
        case yellow, green, red, purple, gray, random
    }
}
