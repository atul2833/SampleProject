//
//  CustomAlertListEndPoints.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 25/06/24.
//

import Foundation

enum CustomAlertListEndPoints: EndpointProvider{
   
    case rulesAndConditions(type:String)
    
    var path: String{
        switch self {
            case .rulesAndConditions:
                return "/rulesAndConditions"
        }
    }
    
    var method: RequestMethod{
        switch self {
        case .rulesAndConditions:
            return .GET
        default:
            return .POST
        }
    }
    
    var accessTokenRequired: Bool{
        true
    }
    
    var queryItems: [URLQueryItem]?{
        switch self {
        case .rulesAndConditions(let type):
            var items = [URLQueryItem]()
                items.append(URLQueryItem(name: "type", value: type))
            return items
                      
        default:
            return nil
        }
    }
    
    var params: [String : Any]?{
       nil
    }
    var mockFile: String? {
        nil
    }
}
