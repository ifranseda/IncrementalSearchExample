//
//  RepositoryContainer.swift
//  IncrementalSearch
//
//  Created by Isnan Franseda on 12/11/22.
//

import Foundation

struct RepositoryContainer: Response {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [Repository]
}
