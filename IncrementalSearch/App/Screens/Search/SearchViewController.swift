//
//  SearchViewController.swift
//  IncrementalSearch
//
//  Created by Isnan Franseda on 12/10/22.
//

import UIKit

class SearchViewController: UIViewController {

    let viewModel: SearchViewModel = SearchViewModel()
    
    lazy var viewAdapter: SearchViewAdapter = {
        let resultCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Repository> { cell, _, collection in
//            cell.configure(using: collection)
//            cell.delegate = self
        }

        return SearchViewAdapter(collectionView) { collectionView, indexPath, item in
            switch item {
            case .results(let id):
                return collectionView.dequeueConfiguredReusableCell(
                    using: resultCellRegistration,
                    for: indexPath,
                    item: self.viewModel.results(for: id)
                )
            }
        }
    }()
    
    lazy var collectionViewLayout: UICollectionViewCompositionalLayout = {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { section, environment in
            return nil
        }
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.contentInsetsReference = .readableContent
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: configuration)
    }()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self

        searchBar.delegate = self
        view.addSubview(searchBar)
        
        setLayoutConstraints()
    }
    
    func setLayoutConstraints() {
        let safeArea = view.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
}

extension SearchViewController: SearchViewModelDelegate {
    func viewModel(_ viewModel: SearchViewModel, stateDidChange state: SearchState) {
        switch state {
        case .idle, .loading:
            break
            
        case .loaded(let results):
            debugPrint(results.map { $0.fullName })
            
        case .failed(let error):
            debugPrint(error)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange query: String) {
        guard query.count > 0 else {
            self.viewModel.clearResults()
            return
        }
        
        self.viewModel.throttledSearch(for: query)
    }
}
