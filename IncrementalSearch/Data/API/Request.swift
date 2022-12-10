//
//  Request.swift
//  IncrementalSearch
//
//  Created by Isnan Franseda on 12/10/22.
//

import Foundation

protocol Request: Encodable {
    func asParams() -> [String: String]?
}
