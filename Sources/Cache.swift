// Cache.swift
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

/*
 Even though the Jolly Hipchat extension works per room, the server is global. Therefore, we must store repos organized per room_id.
 
 > Example (Key-Value storage):
 > ------------------------------
 > K room_id_1:
 >   V [repo_1, repo_2]
 > K room_id_2:
 >   V [repo_1, repo_3, repo_4]
 
 */

class Cache {
    
    let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func add(_ repo: Repo, toRoomWithId roomId: String) {
        let repoId = repo.fullName
        guard let reposIds = self.defaults.array(forKey: roomId) as? [String] else {
            self.defaults.set([repoId], forKey: roomId)
            return
        }
        self.defaults.set(reposIds + [repoId], forKey: roomId)
    }
    
    func remove(_ repo: Repo, fromRoomWithId roomId: String) {
        guard let reposIds = self.defaults.array(forKey: roomId) as? [String] else { return }
        self.defaults.set(reposIds.filter { $0 != repo.fullName },
                          forKey: roomId)
    }
    
    func repos(forRoomWithId roomId: String) -> [Repo] {
        guard let reposIds = self.defaults.array(forKey: roomId) as? [String] else { return [Repo]() }
        return reposIds
            .sorted { $0.lowercased() < $1.lowercased() }
            .flatMap { Repo(fullName: $0) }
    }
    
}
