//
//  Operation.swift
//  IncrementalSearch
//
//  Created by Isnan Franseda on 12/10/22.
//

import Foundation

protocol Operation<ResponseType> {
    associatedtype ResponseType: Response
    
    var environment: EnvironmentService { get }
    var path: String { get }
    var method: HttpMethod { get }
    var request: Request { get }
    var timeout: TimeInterval { get }
    
    func urlRequest() throws -> URLRequest
}

// MARK: - Operation Alamofire
extension Operation {
    var timeout: TimeInterval {
        30
    }
    
    func urlRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = environment.scheme
        components.host = environment.host

        guard var url = components.url else {
            throw APIError.invalidComponents
        }
        
        url.append(path: path)
        
        var urlRequest = URLRequest.init(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: timeout)
        urlRequest.httpMethod = method.rawValue
        
        switch method {
        case .GET:
            let queryItems = request.asParams()?.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
            
            if let queryItems {
                urlRequest.url?.append(queryItems: queryItems)
            }
            
        case .POST, .PUT:
            if let body = try? JSONEncoder().encode(request) {
                urlRequest.httpBody = body
            }
        }
        

        return urlRequest
    }
}

enum HttpMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
}
