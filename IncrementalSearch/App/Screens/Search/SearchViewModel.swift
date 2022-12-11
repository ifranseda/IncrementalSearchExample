//
//  SearchViewModel.swift
//  IncrementalSearch
//
//  Created by Isnan Franseda on 12/10/22.
//

import Foundation
import UIKit

protocol SearchViewModelDelegate: AnyObject {
    func viewModel(_ viewModel: SearchViewModel, stateDidChange state: SearchState)
}

@MainActor
class SearchViewModel {
    weak var delegate: SearchViewModelDelegate?

    private let searchRepository: GitHubSearchRepository

    private(set) var state: SearchState = .idle {
        didSet {
            delegate?.viewModel(self, stateDidChange: state)
        }
    }
    
    private var throttler: Throttler = Throttler(duration: .seconds(0.5))

    init(
        searchRepository: GitHubSearchRepository = GitHubSearchRepositoryImpl()
    ) {
        self.searchRepository = searchRepository
    }

    private func search(with query: String) async {
        guard state.canLoad else { return }
        state = .loading

        do {
            let results = try await searchRepository.search(with: query)
            state = .loaded(results)
        } catch {
            switch error {
            case APIError.requestCancelled:
                state = .idle
            
            default:
                state = .failed(error.localizedDescription)
            }
        }
    }
    
    func clearResults() {
        state = .loaded([])
    }
    
    func throttledSearch(for query: String) {
        Task {
            await throttler.run {
                await self.search(with: query)
            }
        }
    }

    func results(for id: Repository.ID) -> Repository! {
        guard case .loaded(let repositories) = state else {
            return nil
        }
        
        return repositories.first(where: { $0.id == id })
    }
    
    func resultItem(for indexPath: IndexPath) -> Repository? {
        guard case .loaded(let repositories) = state else {
            return nil
        }

        return repositories[indexPath.item]
    }

    func failureMessage() -> String {
        guard case .failed(let message) = state else { return "" }
        return message
    }
}


actor Throttler {
    private let duration: Duration
    private var task: Task<Void, Error>?
    
    init(duration: Duration) {
        self.duration = duration
    }

    func run(operation: @escaping () async -> Void) async {
        task?.cancel()
        
        self.task = Task {
            try? await Task.sleep(for: duration)
            
            guard task?.isCancelled == false else {
                return
            }
            
            await operation()
        }
    }
}
