//
//  EndPointProvider.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import Foundation

enum RequestMethod: String {
    case DELETE
    case GET
    case PATCH
    case POST
    case PUT
}

protocol EndpointProvider {
    var scheme: String { get }
    var baseURL: String { get }
    var port: Int? { get }
    var path: String { get }
    var method: RequestMethod { get }
    var token: String? { get }
    var accessTokenRequired: Bool { get }
    var needToRefreshToken: Bool { get }
    var tokenRefreshModel: Codable.Type? { get }
    var queryItems: [URLQueryItem]? { get }
    var headers: [String: String]? { get }
    var params: [String: Any]? { get }
    var mockFile: String? { get }
    var multipart: MultipartRequest? { get }
    var uploadData: Data? { get }
    func saveTokenModelIntoKeyChain(model: Codable)
}

extension EndpointProvider {
    var scheme: String {
        return ServerConfiguration.shared.userURLConfiguration.scheme
    }
    
    var port: Int? {
        return ServerConfiguration.shared.userURLConfiguration.port
    }
    
    var baseURL: String {
        return ServerConfiguration.shared.userURLConfiguration.baseURL
    }
    
    var needToRefreshToken: Bool {
        false
    }
    
    var tokenRefreshModel: Codable.Type? {
        nil
    }
    
    var headers: [String: String]? {
        return nil
    }
    
    var token: String? {
        return ServerConfiguration.shared.token
    }
    
    var multipart: MultipartRequest? {
        return nil
    }
    
    var uploadData: Data? {
        return nil
    }
    
    func saveTokenModelIntoKeyChain(model: Codable) { }
    
    func buildURLRequest() throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = baseURL
        urlComponents.port = port
        urlComponents.path = path
        
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw ApiResponse(status: false, message: "URL error")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("true", forHTTPHeaderField: "X-Use-Cache")
        
        if headers != nil {
            headers?.forEach({ key, value in
                urlRequest.addValue(key, forHTTPHeaderField: value)
            })
        }
        if accessTokenRequired, 
            RefreshTokenEndPoints.self == Self.self,
            let token = ServerConfiguration.shared.refreshToken {
            
            Log.info("Refresh Token Bearer \(token)")
            urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else if accessTokenRequired, let token = ServerConfiguration.shared.token {
            Log.info("Bearer \(token)")
            urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = params {
            do {
//                var updatedBody = body
//                updatedBody["timeZone"] = TimeZone.current.identifier
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            } catch {
                throw ApiResponse(status: false, message: "Error encoding http body")
            }
        }
        
        if let multipart = multipart {
            urlRequest.setValue(multipart.headerValue, forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("\(multipart.length)", forHTTPHeaderField: "Content-Length")
            urlRequest.httpBody = multipart.httpBody
        }
        return urlRequest
    }
}
