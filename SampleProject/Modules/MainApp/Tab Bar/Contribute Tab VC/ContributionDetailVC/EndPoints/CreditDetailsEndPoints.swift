//
//  NextPaymentEndPoints.swift
//  TAGCreditMerchant
//
//  Created by NIKETAN SHARMA on 09/05/24.
//

import Foundation

enum CreditDetailsEndPoints: EndpointProvider {
   
    case emiList
    case emiPayment(dict:[String:String])
    
    var baseURL: String {
        return ServerConfiguration.shared.userURLConfiguration.baseURL
    }
    
    var port: Int? {
        return ServerConfiguration.shared.userURLConfiguration.port
    }
    
    var path: String {
        switch self {

        case .emiList:
            return "/emiList"
        case .emiPayment:
            return "/emiPayment"
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .emiList:
            return .GET
        default:
            return .POST
        }
    }
    
    var accessTokenRequired: Bool {
        true
    }
    
    var queryItems: [URLQueryItem]? {
        nil
    }
    
    var params: [String : Any]? {
        switch self {
       
        case .emiPayment(let dict):
            return dict

        default:
            return nil
        }
    }
    var mockFile: String? {
        nil
    }
}
