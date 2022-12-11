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
        let resultCellRegistration = UICollectionView.CellRegistration<SearchItemCell, Repository> { cell, _, item in
            cell.configure(using: item)
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
        let sectionLayoutProvider: UICollectionViewCompositionalLayoutSectionProvider = { _, _ in
            let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
            let item = NSCollectionLayoutItem(layoutSize: layoutSize)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: [item])

            return NSCollectionLayoutSection(group: group)
        }
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.contentInsetsReference = .readableContent
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionLayoutProvider, configuration: configuration)
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

        addComponents()
        setLayoutConstraints()
    }
    
    private func addComponents() {
        searchBar.delegate = self
        view.addSubview(searchBar)

        collectionView.dataSource = viewAdapter.dataSource
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
    }
    
    private func setLayoutConstraints() {
        let safeArea = view.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 44),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
        ])
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = viewModel.resultItem(for: indexPath) {
            debugPrint(">>> \(item)")
        }
    }
}

extension SearchViewController: SearchViewModelDelegate {
    func viewModel(_ viewModel: SearchViewModel, stateDidChange state: SearchState) {
        viewAdapter.update(with: state)
        
        switch state {
        case .idle:
            break
            
        case .loading:
            break
            
        case .loaded(_):
            break
            
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
