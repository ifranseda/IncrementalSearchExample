//
//  SearchViewAdapter.swift
//  IncrementalSearch
//
//  Created by Isnan Franseda on 12/10/22.
//

import Foundation
import UIKit

enum SearchResultSection: Hashable {
    case main
}

enum SearchResultItem: Hashable {
    case results(Repository.ID)
}

class SearchViewAdapter {
    typealias CellProvider = (UICollectionView, IndexPath, SearchResultItem) -> UICollectionViewCell?
    typealias DataSource = UICollectionViewDiffableDataSource<SearchResultSection, SearchResultItem>

    let dataSource: DataSource

    init(_ collectionView: UICollectionView, cellProvider: @escaping CellProvider) {
        self.dataSource = DataSource(collectionView: collectionView, cellProvider: cellProvider)
    }

    private var state: SearchState? = nil {
        didSet {
            guard let state = state, state != oldValue else { return }

            let snapshot = NSDiffableDataSourceSnapshot.snapshot(from: state, oldValue: oldValue)
            dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        }
    }

    func update(with state: SearchState) {
        self.state = state
    }
}

private extension NSDiffableDataSourceSnapshot where SectionIdentifierType == SearchResultSection, ItemIdentifierType == SearchResultItem {
    static func snapshot(from state: SearchState, oldValue: SearchState?) -> Self {
        switch (state, oldValue) {
        case (.idle, _), (.loading, _):
            return .loading()

        case (.failed, _):
            return .error()

        case (.loaded(let items), .loaded(let oldValues)):
            return .loaded(using: items, updatingFrom: oldValues)

        case (.loaded(let items), _):
            return .loaded(using: items)
        }
    }

    static func error() -> Self {
        var snapshot = Self()
        snapshot.appendSections([.main])
        return snapshot
    }


    static func loading() -> Self {
        var snapshot = Self()
        snapshot.appendSections([.main])
        return snapshot
    }

    static func loaded(using collections: [Repository], updatingFrom oldValues: [Repository]? = nil) -> Self {
        let items: [SearchResultItem] = collections.map({ .results($0.id) })

        // Create the standard snapshot
        var snapshot = Self()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)

        // TODO: Make more efficient by only reloading items that have changed.
        if oldValues != nil {
            snapshot.reloadItems(items)
        }

        return snapshot
    }
}

