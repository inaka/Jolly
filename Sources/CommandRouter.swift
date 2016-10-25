// CommandRouter.swift
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

typealias Command = (String, String)

class CommandRouter {
    
    let cache: Cache
    let notificationSender: NotificationSender
    let repoSpecProvider: RepoSpecProvider
    
    var roomId: String {
        return self.notificationSender.roomId
    }
    
    init(notificationSender: NotificationSender, repoSpecProvider: RepoSpecProvider = RepoSpecProvider(), cache: Cache = Cache()) {
        self.notificationSender = notificationSender
        self.repoSpecProvider = repoSpecProvider
        self.cache = cache
    }
    
    func handle(_ message: String) -> Future<Void, Error> {
        guard message == "/jolly" || message.hasPrefix("/jolly ") else {
            return Future() { completion in
                completion(.failure(.notSlashJollyCommand))
            }
        }
        return self.notification(for: message)
            .andThen {
                self.notificationSender.send($0)
                    .map { _ in return }
                    .mapError { _ in return .errorSendingNotification }
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    // We want to preserve all the possible paths at this level in this function. If you find a neater way to write it, feel free to collaborate.
    private func notification(for message: String) -> Future<Notification, Error> {
        
        let command = message.commandValue
        let notification: Notification
        
        switch command {
            
        case ("", ""):
            notification = Notification(message: Messages.welcome, color: .purple, shouldNotify: true)
            
        case ("about", _):
            notification = Notification(message: Messages.about, color: .gray, shouldNotify: false)
            
        case ("ping", _):
            notification = Notification(message: Messages.pong, color: .green, shouldNotify: true)
            
        case ("list", _):
            let repos = self.cache.repos(forRoomWithId: self.roomId)
            notification = Notification(message: Messages.list(with: repos), color: .green, shouldNotify: true)
            
        case ("report", _):
            return self.notificationForReport()
    
        case ("clear", _):
            let repos = self.cache.repos(forRoomWithId: self.roomId)
            for repo in repos {
                self.cache.remove(repo, fromRoomWithId: self.roomId)
            }
            notification = Notification(message: Messages.cleared, color: .gray, shouldNotify: false)
            
        case ("watch", let argument):
            return self.notificationForWatching(argument)
            
        case ("unwatch", let argument):
            return self.notificationForUnwatching(argument)
            
        case ("jolly", _), ("/jolly", _):
            notification = Notification(message: Messages.yoDawg, color: .gray, shouldNotify: true)
            
        default:
            notification = Notification(message: Messages.unknown(message: message), color: .red, shouldNotify: true)
        }
        
        return Future() { completion in completion(.success(notification)) }
    }
    
    private func notificationForWatching(_ argument: String) -> Future<Notification, Error> {
        let notification: Notification
        switch argument {
        case "":
            notification = Notification(message: Messages.watchHelp, color: .yellow, shouldNotify: true)
        default:
            guard let repo = Repo(fullName: argument) else {
                notification = Notification(message: Messages.wrongRepoFormat(argument), color: .red, shouldNotify: true)
                break
            }
            if let existentRepo = self.cache.repos(forRoomWithId: self.roomId)
                .filter({ $0.fullName == argument })
                .first {
                notification = Notification(message: Messages.alreadyWatching(repo: existentRepo), color: .green, shouldNotify: true)
                break
            }
            return Future() { completion in
                self.repoSpecProvider.fetchSpec(for: repo).start() { result in
                    let notification: Notification
                    switch result {
                    case .success(_):
                        self.cache.add(repo, toRoomWithId: self.roomId)
                        notification = Notification(message: Messages.watchingWithSuccess(repo: repo), color: .green, shouldNotify: true)
                    case .failure(_):
                        notification = Notification(message: Messages.couldNotWatch(repo: repo), color: .red, shouldNotify: true)
                    }
                    completion(.success(notification))
                }
            }
        }
        return Future() { completion in completion(.success(notification)) }
    }
    
    private func notificationForUnwatching(_ argument: String) -> Future<Notification, Error> {
        let notification: Notification
        switch argument {
        case "":
            notification = Notification(message: Messages.unwatchHelp, color: .yellow, shouldNotify: true)
        default:
            guard let repo = Repo(fullName: argument) else {
                notification = Notification(message: Messages.wrongRepoFormat(argument), color: .red, shouldNotify: true)
                break
            }
            guard let existentRepo = self.cache.repos(forRoomWithId: self.roomId)
                .filter({ $0.fullName == argument })
                .first else {
                    notification = Notification(message: Messages.wasntWatching(repo: repo), color: .red, shouldNotify: true)
                    break
            }
            self.cache.remove(existentRepo, fromRoomWithId: self.roomId)
            notification = Notification(message: Messages.unwatchingWithSuccess(repo: repo), color: .green, shouldNotify: true)
        }
        return Future() { completion in completion(.success(notification)) }
    }
    
    private func notificationForReport() -> Future<Notification, Error> {
        let repos = self.cache.repos(forRoomWithId: self.roomId)
        return Future() { completion in
            self.repoSpecProvider.fetchSpecs(for: repos).start() { result in
                switch result {
                case .success(let specs):
                    let notification = Notification(message: Messages.report(with: specs), color: .purple, shouldNotify: true)
                    completion(.success(notification))
                case .failure(_):
                    completion(.failure(.errorFetchingRepoSpecs))
                }
            }
        }
    }
    
    enum Error: Swift.Error {
        case errorFetchingRepoSpecs
        case errorSendingNotification
        case notSlashJollyCommand
    }
    
}

fileprivate extension String {
    
    var commandValue: Command {
        let components = self.components(separatedBy: " ")
        return (components.count > 1 ? components[1] : "",
                components.count > 2 ? components[2] : "")
    }
    
}
