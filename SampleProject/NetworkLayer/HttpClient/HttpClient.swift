//
//  ApiProtocol.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import Foundation
import Combine

protocol HttpClientProtocol {
    func asyncRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) async throws -> T
    func combineRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) -> AnyPublisher<T, ApiResponse>
    func asyncUpload<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) async throws -> T
}

final class HttpClient: HttpClientProtocol {
    
    func asyncRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) async throws -> T {
        if ReachabilityWrapper.shared.isInternetConnected {
            return try await asyncRequest(endpoint: endpoint, responseModel: responseModel, refreshTokenRetry: 3)
        } else {
            throw ApiResponse(
                status: false,
                message: NSLocalizedString(
                    "It's seems that you are not connected, please check your network connection.",
                    comment: ""
                )
            )
        }
    }
    
    func asyncUpload<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) async throws -> T {
        if ReachabilityWrapper.shared.isInternetConnected {
            return try await asyncUpload(endpoint: endpoint, responseModel: responseModel, refreshTokenRetry: 3)
        } else {
            throw ApiResponse(
                status: false,
                message: NSLocalizedString(
                    "It's seems that you are not connected, please check your network connection.",
                    comment: ""
                )
            )
        }
    }
    
    func combineRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) -> AnyPublisher<T, ApiResponse> {
        if ReachabilityWrapper.shared.isInternetConnected {
            return combineRequest(endpoint: endpoint, responseModel: responseModel, refreshTokenRetry: 3)
        } else {
            return AnyPublisher<T, ApiResponse>(
                (
                    Fail(
                        error: ApiResponse(
                            status: false,
                            message: NSLocalizedString(
                                "It's seems that you are not connected, please check your network connection.",
                                comment: ""
                            )
                        )
                    )
                )
            )
        }
    }
    
    var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 60 // seconds that a task will wait for data to arrive
        configuration.timeoutIntervalForResource = 90 // seconds for whole resource request to complete
        return URLSession(configuration: configuration)
    }
    
    func asyncRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type, refreshTokenRetry:Int? = nil) async throws -> T {
        do {
            let request = try endpoint.buildURLRequest()
            Log.info("=== URL REQUEST === \(request)")
            Log.info("=== HTTP METHOD === \(request.httpMethod ?? "")")
            
            self.printDataBeautify(
                data: request.httpBody,
                prefixString: "=== API REQUEST PARAMS ==="
            )
            let (data, response) = try await session.data(for: request)
            return try self.manageResponse(data: data, response: response, endpoint: endpoint)
        } catch let error as ApiResponse {
            if error.statusCode == 401,
               let retryCount = refreshTokenRetry,
               retryCount > 0 {
                try await refreshToken(tokenEndPoint: RefreshTokenEndPoints.refreshToken, retryCount: retryCount - 1)
                return try await self.asyncRequest(endpoint: endpoint, responseModel: responseModel)
            } else {
                throw error
            }
        } catch {
            throw ApiResponse(
                status: false,
                message: "Unknown API error \(error.localizedDescription)"
            )
        }
    }
    
    func combineRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type, refreshTokenRetry:Int? = 3) -> AnyPublisher<T, ApiResponse> {
        do {
            let request = try endpoint.buildURLRequest()
            Log.info("=== URL REQUEST === \(request)")
            Log.info("=== HTTP METHOD === \(request.httpMethod ?? "")")
            
            self.printDataBeautify(
                data: request.httpBody,
                prefixString: "=== API REQUEST PARAMS ==="
            )
            
            return self.session
                .dataTaskPublisher(for: request)
                .tryMap { output in
                    try self.manageResponse(data: output.data, response: output.response, endpoint: endpoint)
                }
                .mapError {
                    $0 as? ApiResponse ?? ApiResponse(status: false, message: "Unknown API error \($0.localizedDescription)")
                }
                .eraseToAnyPublisher()
        } catch let error as ApiResponse {
            return AnyPublisher<T, ApiResponse>(Fail(error: error))
        } catch {
            return AnyPublisher<T, ApiResponse>(Fail(error: ApiResponse(
                status: false,
                message: "Unknown API error \(error.localizedDescription)"
            )))
        }
    }
    
    func asyncUpload<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type, refreshTokenRetry:Int? = 3) async throws -> T {
        guard let uploadData = endpoint.uploadData else {
            throw ApiResponse(status: false, message: "Invalid upload data")
        }
        do {
            let request = try endpoint.buildURLRequest()
            
            Log.info("=== URL REQUEST === \(request)")
            Log.info("=== HTTP METHOD === \(request.httpMethod ?? "")")
            self.printDataBeautify(
                data: request.httpBody,
                prefixString: "=== API REQUEST PARAMS ==="
            )
            
            let (data, response) = try await session.upload(for: request, from: uploadData)
            return try self.manageResponse(data: data, response: response, endpoint: endpoint)
        } catch let error as ApiResponse {
            throw error
        } catch {
            throw ApiResponse(
                status: false,
                message: "Unknown API error \(error.localizedDescription)"
            )
        }
    }
    
    private func manageResponse<T: Decodable>(data: Data, response: URLResponse, endpoint: EndpointProvider) throws -> T {
        
        self.printDataBeautify(data: data, prefixString: "=== API RESPONSE ===")
        guard let response = response as? HTTPURLResponse else {
            throw ApiResponse(
                status: false,
                message: "Invalid HTTP response"
            )
        }
        switch response.statusCode {
        case 200 ... 299:
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                Log.error(error.localizedDescription)

                throw ApiResponse(
                    status: false,
                    message: "Error decoding data",
                    response: response
                )
            }
        default:
            guard let decodedError = try? JSONDecoder().decode(ApiResponse.self, from: data) else {
                throw ApiResponse(
                    statusCode: response.statusCode,
                    status: false,
                    message: "Unknown backend error",
                    response: response
                )
            }
            
            throw ApiResponse(
                statusCode: response.statusCode,
                status: decodedError.status,
                message: decodedError.message,
                response: response
            )
        }
    }
    
    private func printDataBeautify(data: Data?, prefixString: String) {
        guard let data else { return }
        if let jsonData = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonData, options: .withoutEscapingSlashes),
           let jsonString = String(data: prettyPrintedData, encoding: .utf8) {
            Log.info("\(prefixString) \(jsonString)")
        } else {
            Log.error("\(prefixString) Unable to parse data.")
        }
    }
}

private extension HttpClient {
    private func refreshToken(tokenEndPoint: EndpointProvider, retryCount: Int) async throws {
        
        do {
            guard let tokenModelType = tokenEndPoint.tokenRefreshModel else {
                throw ApiResponse(
                    status: false,
                    message: "Token response Model is missing"
                )
            }
            
            let refreshedTokenModel = try await self.asyncRequest(endpoint: tokenEndPoint, responseModel: tokenModelType, refreshTokenRetry: retryCount-1)
            tokenEndPoint.saveTokenModelIntoKeyChain(model: refreshedTokenModel)
        } catch {
            throw ApiResponse(
                statusCode: 401,// used for logout code, token expired and not refreshed
                status: false,
                message: "Refresh token retries exhausted, please logout the app"
            )
        }
    }    
}
