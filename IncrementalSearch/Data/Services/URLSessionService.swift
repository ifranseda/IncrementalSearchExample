//
//  URLSessionService.swift
//  IncrementalSearch
//
//  Created by Isnan Franseda on 12/11/22.
//

import Foundation

open class URLSessionService: BackendService {
    lazy var urlSession: URLSession = {
        URLSession(configuration: config)
    }()
    
    lazy var config: URLSessionConfiguration = {
        let cacheDirURL: URL? = {
            return FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appending(path: "GitHubCaches")
        }()
        
        let urlCache = URLCache.init(memoryCapacity: 0, diskCapacity: 1024 * 1024 * 10, directory: cacheDirURL)
        
        let config = URLSessionConfiguration.default
        config.urlCache = urlCache
        return config
    }()
}
