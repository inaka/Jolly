//
//  Notification.swift
//  TestRequest
//
//  Created by Pablo Villar on 10/7/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

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
