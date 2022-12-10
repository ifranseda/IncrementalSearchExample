//
//  SearchState.swift
//  IncrementalSearch
//
//  Created by Isnan Franseda on 12/10/22.
//

import Foundation
import UIKit

enum SearchState: Equatable {
    case idle
    case loading
    case loaded([Repository])
    case failed(String)

    var canLoad: Bool {
        switch self {
        case .idle, .failed, .loaded:
            return true
        case .loading:
            return false
        }
    }
}
