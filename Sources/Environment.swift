//
//  Environment.swift
//  Jolly
//
//  Created by Pablo Villar on 10/17/16.
//
//

import Foundation

class Environment {
    static let shared = Environment()
    
    var hipchatToken: String? {
        guard let rawValue = getenv("HIPCHAT_TOKEN") else { return nil }
        return String(utf8String: rawValue)
    }
}
