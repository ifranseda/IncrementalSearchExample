//
//  GitHubSearchAPI.swift
//  IncrementalSearch
//
//  Created by Isnan Franseda on 12/10/22.
//

import Foundation

struct GitHubSearchRequest: Request {
    let query: String?
    let page: Int?
    let perPage: Int = 20

    func asParams() -> [String : String]? {
        guard let query = query else {
            return [:]
        }
        
        return [
            "q": query,
            "page": "\(page ?? 1)", // Default page is 1, as per github doc
            "per_page": "\(perPage)",
        ]
    }
}

struct GitHubSearchAPI: Operation {
    typealias ResponseType = RepositoryContainer
    
    let environment: EnvironmentService
    
    let path: String = "search/repositories"
    
    let method: HttpMethod = .GET
    
    let request: Request
    
    let search: String
}

extension GitHubSearchAPI {
    init(environment: EnvironmentService = GitHubEnvironment(), search: String) {
        self.environment = environment
        self.search = search
        self.request = GitHubSearchRequest(query: search, page: 0)
    }
}
