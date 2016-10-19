// Repo.swift
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

struct Repo {
    let organization: String
    let name: String
    
    init?(fullName: String) {
        guard
            let components = URL(string: fullName)?.pathComponents,
            components.count == 2
        else {
            return nil
        }
        organization = components[0]
        name = components[1]
    }
}

extension Repo {
    
    var fullName: String {
        return "\(organization)/\(name)"
    }
    
}
