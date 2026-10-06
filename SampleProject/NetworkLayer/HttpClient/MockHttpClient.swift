//
//  MockHttpClient.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import Foundation
import Combine

protocol Mockable: AnyObject {
    var bundle: Bundle { get }
    func loadJSON<T: Decodable>(filename: String, type: T.Type) -> T
}

final class MockHttpClient: Mockable, HttpClientProtocol {
    func asyncRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) async throws -> T {
        return try await asyncRequest(endpoint: endpoint, responseModel: responseModel, refreshTokenRetry: 3)
    }
    
    func asyncUpload<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) async throws -> T {
        return try await asyncUpload(endpoint: endpoint, responseModel: responseModel, refreshTokenRetry: 3)
    }
    
    func combineRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) -> AnyPublisher<T, ApiResponse> {
        return combineRequest(endpoint: endpoint, responseModel: responseModel, refreshTokenRetry: 3)
    }
    
    func asyncRequest<T>(endpoint: EndpointProvider, responseModel: T.Type, refreshTokenRetry:Int? = 0) async throws -> T where T: Decodable {
        return loadJSON(filename: endpoint.mockFile!, type: responseModel.self)
    }

    func combineRequest<T>(endpoint: EndpointProvider, responseModel: T.Type, refreshTokenRetry:Int? = 0) -> AnyPublisher<T, ApiResponse> where T: Decodable {
        return Just(loadJSON(filename: endpoint.mockFile!, type: responseModel.self) as T)
            .setFailureType(to: ApiResponse.self)
            .eraseToAnyPublisher()
    }

    func asyncUpload<T>(endpoint: EndpointProvider, responseModel: T.Type, refreshTokenRetry:Int? = 0) async throws -> T where T: Decodable {
        return loadJSON(filename: endpoint.mockFile!, type: responseModel.self)
    }
}

extension Mockable {
    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }

    func loadJSON<T: Decodable>(filename: String, type: T.Type) -> T {
        guard let path = bundle.url(forResource: filename, withExtension: "json") else {
            fatalError("Failed to load JSON")
        }

        do {
            let data = try Data(contentsOf: path)
            let decodedObject = try JSONDecoder().decode(type, from: data)

            return decodedObject
        } catch {
            fatalError("Failed to decode loaded JSON")
        }
    }
}
