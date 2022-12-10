//
//  GitHubSearchRepository.swift
//  IncrementalSearch
//
//  Created by Isnan Franseda on 12/10/22.
//

import Foundation

protocol GitHubSearchRepository {
    func search(with query: String) async throws -> [Repository]
}

class GitHubSearchRepositoryImpl: GitHubSearchRepository {
    private let backend: BackendService
    
    init(backend: BackendService = GitHubService()) {
        self.backend = backend
    }
    
    func search(with query: String) async throws -> [Repository] {
        let api = GitHubSearchAPI(search: query)
        let results: Result<RepositoryContainer, Error> = try await backend.perform(api)
        
        switch results {
        case .success(let container):
            return container.items
            
        case .failure(let failure):
            throw failure
        }
    }
}
