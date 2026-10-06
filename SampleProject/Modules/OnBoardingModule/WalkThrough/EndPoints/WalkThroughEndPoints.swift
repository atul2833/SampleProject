//
//  WalkThroughEndPoints.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 09/01/2024.
//

import Foundation

enum WalkThroughEndPoints: EndpointProvider {
    case getWalkThrough
    
    var path: String {
        return "/getWalkthroughList"
    }
    
    var accessTokenRequired: Bool {
        return false
    }
    
    var method: RequestMethod {
        return .GET
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var params: [String: Any]? {
        return nil
    }
    
    var mockFile: String? {
        return "_mockWalkThroughResponse"
    }
}
