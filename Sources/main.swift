import Kitura
import HeliumLogger
import Foundation
import SwiftyJSON

HeliumLogger.use()

print("🐒 Jolly chimp server running!")

let router = Router()

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
            next()
            return
    }
    
    let json = JSON(data: data)
    guard
        let commandMessage = json["item"]["message"]["message"].string,
        let roomId = json["item"]["room"]["id"].int
        else {
            print("⛔️ Got JSON body, but invalid format.")
            next()
            return
    }
    
    let commandRouter = CommandRouter(forRoomWithId: "\(roomId)")
    commandRouter.handle(commandMessage.commandValue).start() { result in
        switch result {
        case .success(let path):
            print("✅ Notification sent via \(path)")
            next()
        case .failure(let error):
            print("⛔️ CommandRouter Error: \(error)")
            exit(1)
        }
    }

}

Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()
