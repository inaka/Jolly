//
//  HTTPRequestSender.swift
//  TestRequest
//
//  Created by Pablo Villar on 10/7/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import Foundation

extension URLRequest {
    
    static func postRequest(to url: URL, with data: Data) -> URLRequest {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        return request as URLRequest
    }
    
}
