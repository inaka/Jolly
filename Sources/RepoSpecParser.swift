// RepoSpecParser.swift
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

class RepoSpecParser {
    
    func repoSpec(from dictionary: [String: Any]) -> RepoSpec? {
        guard
            let urlString = dictionary["html_url"] as? String,
            let url = URL(string: urlString),
            let fullName = dictionary["full_name"] as? String,
            let stars = dictionary["stargazers_count"] as? Int,
            let forks = dictionary["forks"] as? Int,
            let issues = dictionary["open_issues_count"] as? Int
            else {
                return nil
        }
        return RepoSpec(url: url,
                        fullName: fullName,
                        stars: stars,
                        forks: forks,
                        issues: issues)
    }
    
}
