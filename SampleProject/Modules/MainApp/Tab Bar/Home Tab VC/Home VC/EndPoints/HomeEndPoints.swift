//
//  HomeEndPoints.swift
//  ComeraMoney
//
//  Created by NIKETAN SHARMA on 12/02/24.
//

import Foundation

enum HomeEndPoints: EndpointProvider {
   
    case getProfile
    case walletBalance
    case getPaymentMethod(type:String)
    case addFund(dict:[String:Any])
    case paymentMethodList
    case paymentStatus(transactionId:String)
    
    var baseURL: String {
        return ServerConfiguration.shared.userURLConfiguration.baseURL
    }
    
    var port: Int? {
        return ServerConfiguration.shared.userURLConfiguration.port
    }
    
    var path: String {
        switch self {
        case .paymentStatus:
            return "/paymentStatus"
        case .paymentMethodList:
            return "/paymentMethodList"
        case .getProfile:
            return "/userProfile"
        case .walletBalance:
            return "/walletBalance"
        case .getPaymentMethod:
            return "/getPaymentMethod"
        case .addFund:
            return "/addFund"
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .getProfile,.walletBalance,.getPaymentMethod, .paymentMethodList, .paymentStatus:
            return .GET
        default:
            return .POST
        }
    }
    
    var accessTokenRequired: Bool {
        true
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
            
        case .paymentStatus(let transactionId):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "transactionId", value: transactionId))

            return items
            
        case .getPaymentMethod(let type):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "type", value: type))

            return items
        default:
            return nil
        }
    }
    
    var params: [String : Any]? {
        switch self {
        case .addFund(let dict):
            return dict
            
        default:
            return nil
        }
    }
    var mockFile: String? {
        nil
    }
}
