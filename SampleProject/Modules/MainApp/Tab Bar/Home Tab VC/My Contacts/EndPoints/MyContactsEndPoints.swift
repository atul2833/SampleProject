//
//  MyContactsEndPoints.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 01/04/24.
//

import Foundation

enum MyContactsEndPoints: EndpointProvider {
   
    case getInvitationContacts(dict:[String:Any])
    case sendInvitation(dict:[String:Any])
    var baseURL: String {
        return ServerConfiguration.shared.userURLConfiguration.baseURL
    }
    
    var port: Int? {
        return ServerConfiguration.shared.userURLConfiguration.port
    }
    
    var path: String {
        switch self {
        case .getInvitationContacts:
            return "/getInvitationContacts"
        case .sendInvitation:
            return "/sendInvitation"
        }
    }
    
    var method: RequestMethod {
        return .POST
    }
    
    var accessTokenRequired: Bool {
        true
    }
    
    var queryItems: [URLQueryItem]? {
        nil
    }
    
    var params: [String : Any]? {
        switch self{

        case .getInvitationContacts(let dict):
            return dict
        case .sendInvitation(dict: let dict):
            return dict
        }
    }
    var mockFile: String? {
        nil
    }
}
