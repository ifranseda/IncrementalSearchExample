//
//  Environment.swift
//  IncrementalSearch
//
//  Created by Isnan Franseda on 12/10/22.
//

import Foundation

protocol EnvironmentService {
    var scheme: String { get }
    var host: String { get }
}

struct GitHubEnvironment: EnvironmentService {
    let scheme: String = "https"
    let host: String = "api.github.com"
}
