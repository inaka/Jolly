// NotificationSender.swift
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
            return ["from": "Jolly",
                    "color": notification.color.rawValue,
                    "message": notification.message.text,
                    "notify": notification.shouldNotify,
                    "message_format": notification.message.format.rawValue]
        }
        
        let json = dictionary(from: notification)
        return try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
    }
    
}
