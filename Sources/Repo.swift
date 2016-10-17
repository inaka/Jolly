

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
