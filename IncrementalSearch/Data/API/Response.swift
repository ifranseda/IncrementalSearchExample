//
//  Response.swift
//  IncrementalSearch
//
//  Created by Isnan Franseda on 12/10/22.
//

import Foundation

protocol Response: Decodable { }

extension Array: Response where Element: Response { }
