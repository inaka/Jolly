//
//  Cache.swift
//  myFirstProject
//
//  Created by Pablo Villar on 10/14/16.
//
//

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
    
    let defaults = UserDefaults.standard
    
    func add(_ repo: Repo, toRoomWithId roomId: String) {
        let repoId = repo.fullName
        guard let reposIds = self.defaults.value(forKey: roomId) as? [String] else {
            self.defaults.set([repoId], forKey: roomId)
            return
        }
        self.defaults.set(reposIds + [repoId], forKey: roomId)
    }
    
    func remove(_ repo: Repo, fromRoomWithId roomId: String) {
        guard let reposIds = self.defaults.value(forKey: roomId) as? [String] else { return }
        self.defaults.set(reposIds.filter { $0 != repo.fullName },
                          forKey: roomId)
    }
    
    func repos(forRoomWithId roomId: String) -> [Repo] {
        guard let reposIds = self.defaults.value(forKey: roomId) as? [String] else { return [Repo]() }
        return reposIds
            .sorted()
            .flatMap { Repo(fullName: $0) }
    }
    
}
