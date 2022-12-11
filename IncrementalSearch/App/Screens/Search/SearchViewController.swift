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
    
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = UIColor.gray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.stopAnimating()
        return indicator
    }()
    
    lazy var errorTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .primaryText
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    lazy var errorDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .primaryText
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 4
        label.textAlignment = .center
        return label
    }()
    
    lazy var errorStackView: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .vertical
        stackview.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 8)
        return stackview
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
        
        view.addSubview(loadingIndicator)
        
        view.addSubview(errorStackView)
        errorStackView.translatesAutoresizingMaskIntoConstraints = false
        errorStackView.addArrangedSubview(errorTitleLabel)
        errorStackView.addArrangedSubview(errorDescriptionLabel)
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
            
            loadingIndicator.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 28),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 28),
            
            errorStackView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            errorStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            errorStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            errorStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
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
        errorStackView.isHidden = true
        
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
            break

        case .idle, .loaded(_):
            loadingIndicator.stopAnimating()
            break
            
        case .failed(_):
            loadingIndicator.stopAnimating()
            
            errorStackView.isHidden = false
            errorTitleLabel.text = "Error"
            errorDescriptionLabel.text = viewModel.failureMessage()
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
