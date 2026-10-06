//
//  RefreshTokenEndPoints.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import Foundation

enum RefreshTokenEndPoints: EndpointProvider {
    
    case refreshToken
    
    var path: String {
        return "/refreshToken"
    }
    
    var method: RequestMethod {
        return .POST
    }
    
    var accessTokenRequired: Bool {
        return true
    }
    
    var needToCheckRefreshToken: Bool {
        true
    }
    
    var tokenRefreshModel: Codable.Type? {
        return OTPResponseModel.self
    }
    var queryItems: [URLQueryItem]? {
        nil
    }
    
    var params: [String : Any]? {
        nil
    }
    
    var mockFile: String? {
        nil
    }
    
    func saveTokenModelIntoKeyChain(model: Codable) {
        ServerConfiguration.shared.saveInKeyChain(model: model)
    }
    
}
