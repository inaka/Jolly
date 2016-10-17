//
//  NotificationSender.swift
//  TestRequest
//
//  Created by Pablo Villar on 10/7/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import Foundation

class NotificationSender {
    
    enum ConstructionError: Swift.Error {
        case badURL
    }
    
    init(path: String) throws {
        guard let url = URL(string: path) else {
            throw ConstructionError.badURL
        }
        self.url = url
    }
    
    let url: URL
    
    enum Error: Swift.Error {
        case notificationCannotBeBuilt
        case responseError
    }
    
    func send(_ notification: Notification) -> Future<Void, Error> {
        return Future() { completion in
            guard let data = self.data(from: notification) else {
                completion(.failure(.notificationCannotBeBuilt))
                return
            }
            let request = URLRequest.postRequest(to: self.url, with: data)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    completion(.failure(.responseError))
                    return
                }
                completion(.success())
                }.resume()
        }
    }
    
    
    private func data(from notification: Notification) -> Data? {
        
        func dictionary(from notification: Notification) -> [String: Any] {
            return ["color": notification.color.rawValue,
                    "message": notification.message.text,
                    "notify": notification.shouldNotify,
                    "message_format": notification.message.format.rawValue]
        }
        
        let json = dictionary(from: notification)
        return try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
    }
    
}
