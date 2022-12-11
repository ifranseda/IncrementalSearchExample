//
//  BackendService.swift
//  IncrementalSearch
//
//  Created by Isnan Franseda on 12/10/22.
//

import Foundation

protocol BackendService {
    var urlSession: URLSession { get }
    
    func perform<R: Decodable>(_ operation: any Operation) async throws -> Result<R, Error>
}

extension BackendService {
    func perform<R: Decodable>(_ operation: any Operation) async throws -> Result<R, Error> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        guard let urlRequest = try? operation.urlRequest() else {
            return .failure(APIError.invalidRequest)
        }
        
        guard let response = try? await urlSession.data(for: urlRequest) else {
            return .failure(APIError.requestCancelled)
        }
        
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            return .failure(APIError.unknownResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            return .failure(APIError.invalidResponse(httpResponse.statusCode))
        }
        
        do {
            let response = try decoder.decode(R.self, from: response.0)
            return .success(response)
        } catch (let error) {
            return .failure(APIError.decodeError(info: error.localizedDescription))
        }
    }
}

enum APIError: Error, Equatable {
    case invalidComponents
    case invalidRequest
    case requestCancelled
    case unknownResponse
    case decodeError(info: String)
    case invalidResponse(Int)
}
