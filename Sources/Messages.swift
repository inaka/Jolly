// Messages.swift
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

struct Messages {
    
    static let welcome = Notification.Message("🐵 Hey, I'm Jolly! I'm in charge of monitoring any github repo that you tell me.<br>Here's a list of all the commands I understand, with their respective examples:<br><br><b>Watch a repo</b> - <i>Adds a repo to the watching list</i><br>&emsp;<code>/jolly watch :org/:repo</code><br>&emsp;<code>/jolly watch inaka/Jayme</code><br><br><b>Unwatch a repo</b> - <i>Removes a repo from the watching list</i><br>&emsp;<code>/jolly unwatch :org/:repo</code><br>&emsp;<code>/jolly unwatch inaka/Jayme</code><br><br><b>Unwatch all the repos</b> - <i>Clears the watching list</i><br>&emsp;<code>/jolly clear</code><br><br><b>Get the watched repos list</b><br>&emsp;<code>/jolly list</code><br><br><b>Get report</b> - <i>Writes a report of the watched repos</i><br>&emsp;<code>/jolly report</code><br><br><b>About</b> - <i>Get more info about me</i><br>&emsp;<code>/jolly about</code>")
    
    static let about = Notification.Message("🐒  Hey there, I'm your <b>Jolly chimp</b> monitor. I'm just a Hipchat integration that connects to the <b><a href='https://github.com/inaka/jolly'>Jolly Server</a></b> when you send commands.<br><br>For a list of all the commands I support, type <code>/jolly</code><br><br><b><i>© 2016 Erlang Solutions Ltd.</i></b>", format: .html)

    static let watchHelp = Notification.Message("🐵 Want to add a repo to the list? Please, <b>specify the repo</b>.<br>∙ <b>Format</b>: <code>/jolly watch :org/:repo</code><br>∙ <b>Example</b>: <code>/jolly watch inaka/Jayme</code>")
    
    static func wrongRepoFormat(_ text: String) -> Notification.Message {
        return Notification.Message("🐵 You specified a wrong repo format. Make sure it reads as <code>:org/:repo</code><br>∙ <b>Example</b>: <code>/jolly watch inaka/Jayme</code>")
    }
    
    static let pong = Notification.Message("(pingpong) pong!", format: .text)
    
    static func couldNotWatch(repo: Repo) -> Notification.Message {
        return Notification.Message("🙊 It seems that I cannot watch the \(repo.htmlLink) repo! Make sure it's <b>public</b> and currently <b>up</b>.")
    }
    
    static let unwatchHelp = Notification.Message("🙊 Want to remove a repo from the list? Please, <b>specify the repo</b>.<br>∙ <b>Format</b>: <code>/jolly unwatch :org/:repo</code><br>∙ <b>Example</b>: <code>/jolly unwatch inaka/Jayme</code>")
    
    static func unknown(message: String) -> Notification.Message {
        return Notification.Message("🙊 I don't know what <code>\(message))</code> is supposed to mean... Need help? type <code>/jolly</code>")
    }
    
    static let yoDawg = Notification.Message("(yodawg)", format: .text)
    
    static let cleared = Notification.Message("🙈 Ok, I'm no longer watching anything!")
        
    static func alreadyWatching(repo: Repo) -> Notification.Message {
        return Notification.Message("🐵 I'm already watching \(repo.htmlLink) !")
    }
    
    static func wasntWatching(repo: Repo) -> Notification.Message {
        return Notification.Message("🙊 I was not watching \(repo.htmlLink) !")
    }
    
    static func watchingWithSuccess(repo: Repo) -> Notification.Message {
        return Notification.Message("👀 Ok, I'm now watching \(repo.htmlLink)")
    }
    
    static func unwatchingWithSuccess(repo: Repo) -> Notification.Message {
        return Notification.Message("🙈 Ok, I'm no longer watching \(repo.htmlLink) !")
    }
    
    static func list(with repos: [Repo]) -> Notification.Message {
        let formattedList = repos
            .map { "<br>&emsp;→ \($0.htmlLink)" }
            .reduce("") { $0 + $1 }
        let header: String
        switch repos.count {
        case 0: header = "🙈 I ain't watching any repo right now!"
        case 1: header = "🐵 I'm only watching this repo:"
        default: header = "🐵 I'm watching these \(repos.count) repos:"
        }
        return Notification.Message("\(header)<br>\(formattedList)")
    }
    
    static func report(with specs: [RepoSpec]) -> Notification.Message {
        guard specs.count > 0 else {
            return Notification.Message("🐵 I'm not watching any repo yet!")
        }
        let tableContent = specs
            .map { $0.htmlTableRow }
            .reduce("") { $0 + $1 }
        return Notification.Message("🐵 Here's my report:<br><br><table width=\"100%\">\(tableContent)</table>")
    }
    
}

extension Repo {
    
    var htmlLink: String {
        let fullName = self.fullName
        return "<code><a href='https://github.com/\(fullName)'>\(fullName)</a></code>"
    }
    
}

extension RepoSpec {
    
    var htmlTableRow: String {
        return "<tr><td>&emsp;→ \(htmlLink)</td><td>⚠︎ <b>\(issues)</b> issues</td><td>⭑ <b>\(stars)</b> stars</td><td>⑂ <b>\(forks)</b> forks</td></tr>"
    }
    
    private var htmlLink: String {
        return "<code><a href='\(self.url.absoluteString)'>\(self.fullName)</a></code>"
    }
    
}
