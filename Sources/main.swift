// main.swift
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

import Kitura
import HeliumLogger
import Foundation
import SwiftyJSON

HeliumLogger.use()

print("🐒 Jolly chimp server running!")

let router = Router()
guard let authToken = Environment.shared.hipchatToken else {
    print("⛔️ Missing hipchat auth token. Make sure a 'HIPCHAT_TOKEN' environment variable is set.")
    exit(1)
}

router.get("/") { request, response, next in
    print("↘️ Received GET to /")
    response.send("<h1>Jolly chimp server running!</h1><img src='http://cf.collectorsweekly.com/stories/D5qsVaR.sNIBaPbCl4pjTA.jpg'>")
    next()
}

router.get("/ping") { request, response, next in
    print("↘️ Received GET to /ping")
    response.send("Pong!")
    next()
}

router.post("/") { request, response, next in
    print("↘️ Received POST to /")
    
    var data = Data()
    guard let _ = try? request.read(into: &data)
        else {
            print("⛔️ Could not read JSON body data.")
            next(); return
    }
    let json = JSON(data: data)
    guard
        let commandMessage = json["item"]["message"]["message"].string,
        let roomId = json["item"]["room"]["id"].int
        else {
            print("⛔️ Got JSON body, but invalid format.")
            next(); return
    }
   
    let sender = NotificationSender(roomId: "\(roomId)", authenticationToken: authToken)
    let commandRouter = CommandRouter(notificationSender: sender)
    commandRouter.handle(commandMessage).start() { result in
        switch result {
        case .success:
            print("✅ Notification sent!")
            next()
        case .failure(let error):
            print("⛔️ CommandRouter Error: \(error)")
            exit(1)
        }
    }

}

Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()
