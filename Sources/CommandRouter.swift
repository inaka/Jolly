//  Notification+CommandMessage.swift
//
//  Created by Pablo Villar on 10/14/16.

import Foundation

typealias Command = (String, String, String)

class CommandRouter {
    
    let roomId: String
    let cache = Cache()
    
    init(forRoomWithId id: String) {
        roomId = id
    }
    
    private let authToken = "UcwWAeGwN3YFOYjlQ9soiK8hI8C1Rli4pQSML9G3" // TODO: DO NOT PUSH TOKENS TO THE REPO!
    
    func handle(_ command: Command) -> Future<String, Error> {
        let notification = self.notification(for: command)
        let path = "https://api.hipchat.com/v2/room/\(roomId)/notification?auth_token=\(authToken)"
        guard let sender = try? NotificationSender(path: path) else {
            return Future() { completion in completion(.failure(.couldNotCreateNotificationSender)) }
        }
        let future: Future<String, Error> = Future() { completion in
            sender.send(notification).start() { result in
                switch result {
                case .success(_):
                    completion(.success(path))
                case .failure(_):
                    completion(.failure(.errorSendingNotification))
                }
            }
        }
        return future
    }
    
    private func notification(for command: Command) -> Notification {
        let notification: Notification
        
        switch command {
            
        case ("/jolly", "", ""):
            notification = Notification(message: Messages.welcome, color: .purple, shouldNotify: true)
            
        case ("/jolly", "about", _):
            notification = Notification(message: Messages.about, color: .gray, shouldNotify: false)
            
        case ("/jolly", "ping", _):
            notification = Notification(message: Messages.pong, color: .green, shouldNotify: true)
            
        case ("/jolly", "list", _):
            let repos = self.cache.repos(forRoomWithId: self.roomId)
            notification = Notification(message: Messages.list(with: repos), color: .green, shouldNotify: true)
            
        case ("/jolly", "report", _):
            let specs = self.cache.repos(forRoomWithId: self.roomId)
                .map { RepoSpec(url: URL(string: "https://github.com/\($0.fullName)")!,
                                fullName: $0.fullName, stars: 0, forks: 0, pullRequests: 0, issues: 0) }
            notification = Notification(message: Messages.report(with: specs), color: .purple, shouldNotify: true)
            
        case ("/jolly", "clear", _):
            notification = Notification(message: Messages.cleared, color: .gray, shouldNotify: false)
            
        case ("/jolly", "watch", ""):
            notification = Notification(message: Messages.watchHelp, color: .yellow, shouldNotify: true)
            
        case ("/jolly", "watch", let text):
            guard let repo = Repo(fullName: text) else {
                notification = Notification(message: Messages.wrongRepoFormat(text), color: .red, shouldNotify: true)
                break
            }
            if let existentRepo = self.cache.repos(forRoomWithId: self.roomId)
                .filter({ $0.fullName == text })
                .first {
                notification = Notification(message: Messages.alreadyWatching(repo: existentRepo), color: .green, shouldNotify: true)
                break
            }
            let canWatch = text.hasPrefix("inaka") // Hardcoded. Replace with Github API request for getting repo detail
            if canWatch {
                self.cache.add(repo, toRoomWithId: self.roomId)
                notification = Notification(message: Messages.watchingWithSuccess(repo: repo), color: .green, shouldNotify: true)
            } else {
                notification = Notification(message: Messages.couldNotWatch(repo: repo), color: .red, shouldNotify: true)
            }
            
        case ("/jolly", "unwatch", let text):
            guard let repo = Repo(fullName: text) else {
                notification = Notification(message: Messages.wrongRepoFormat(text), color: .red, shouldNotify: true)
                break
            }
            guard let existentRepo = self.cache.repos(forRoomWithId: self.roomId)
                .filter({ $0.fullName == text })
                .first else {
                    notification = Notification(message: Messages.wasntWatching(repo: repo), color: .red, shouldNotify: true)
                    break
            }
            self.cache.remove(existentRepo, fromRoomWithId: self.roomId)
            notification = Notification(message: Messages.unwatchingWithSuccess(repo: repo), color: .green, shouldNotify: true)
            
        case ("/jolly", "unwatch", ""):
            notification = Notification(message: Messages.unwatchHelp, color: .yellow, shouldNotify: true)
            
        case ("/jolly", "jolly", _), ("/jolly", "/jolly", _):
            notification = Notification(message: Messages.yoDawg, color: .gray, shouldNotify: true)
            
        default:
            notification = Notification(message: Messages.unknown(command: command), color: .red, shouldNotify: true)
            
        }
        
        return notification
    }
    
    enum Error: Swift.Error {
        case couldNotCreateNotificationSender
        case errorSendingNotification
    }
    
}

extension String {
    
    static func from(_ command: Command) -> String {
        return "\(command.0) \(command.1) \(command.2)"
    }
    
    var commandValue: Command {
        let components = self.components(separatedBy: " ")
        let tuple = (components.count > 0 ? components[0] : "",
                     components.count > 1 ? components[1] : "",
                     components.count > 2 ? components[2] : "")
        return tuple
    }
    
}
