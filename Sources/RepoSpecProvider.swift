// RepoSpecProvider.swift
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

class RepoSpecProvider {
    
    enum Error: Swift.Error {
        case responseError
        case dataError
        case parsingError
        case corruptedResponse
    }
    
    func fetchSpecs(for repos: [Repo]) -> Future<[RepoSpec], Error> {
        
        let repo = repos.first!
        return self.fetchSpec(for: repo).map { [$0] }
        
        
//            // Hardcoded
//            let specs = repos.map { RepoSpec(url: URL(string: "https://github.com/\($0.fullName)")!,
//                                             fullName: $0.fullName, stars: 0, forks: 0, pullRequests: 0, issues: 0) }
//            completion(.success(specs))
    }
    
    let urlSession = URLSession.shared
    
    func fetchSpec(for repo: Repo) -> Future<RepoSpec, Error> {
        let url = URL(string: "https://api.github.com/repos/\(repo.organization)/\(repo.name)")!
        let request = URLRequest.githubGETRequest(for: url)
        return Future() { completion in
            self.urlSession.dataTask(with: request) { data, response, error in
                if error != nil {
                    completion(.failure(.responseError))
                    return
                }
                guard
                    let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                    let dict = json as? [String: Any],
                    let spec = RepoSpecParser().repoSpec(from: dict)
                    else {
                        completion(.failure(.dataError)); return
                }
                completion(.success(spec))
                }.resume()
        }
    }
    
}

extension URLRequest {
    
    static func githubGETRequest(for url: URL) -> URLRequest {
        let request = NSMutableURLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        return request as URLRequest
    }
    
}
