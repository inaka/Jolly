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
    
    init(roomId: String, authenticationToken token: String, urlSession: URLSession = .shared) {
        let path = "https://api.hipchat.com/v2/room/\(roomId)/notification?auth_token=\(token)"
        self.url = URL(string: path)!
        self.roomId = roomId
        self.urlSession = urlSession
    }
    
    let urlSession: URLSession
    let roomId: String
    private let url: URL
    
    enum Error: Swift.Error {
        case responseError
    }
    
    func send(_ notification: Notification) -> Future<Void, Error> {
        return Future() { completion in
            let data = self.data(from: notification)
            let request = URLRequest.postRequest(to: self.url, with: data)
            self.urlSession.dataTask(with: request) { data, response, error in
                if error != nil {
                    completion(.failure(.responseError))
                    return
                }
                completion(.success())
                }.resume()
        }
    }
    
    
    private func data(from notification: Notification) -> Data {
        
        func dictionary(from notification: Notification) -> [String: Any] {
            return ["from": "Jolly",
                    "color": notification.color.rawValue,
                    "message": notification.message.text,
                    "notify": notification.shouldNotify,
                    "message_format": notification.message.format.rawValue]
        }
        
        let json = dictionary(from: notification)
        return try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
    }
    
}
