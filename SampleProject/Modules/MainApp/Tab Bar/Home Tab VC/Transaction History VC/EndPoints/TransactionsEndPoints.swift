//
//  TransactionEndPoints.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 21/03/24.
//

import Foundation

enum TransactionsEndPoints: EndpointProvider{
   
    case transactionList(dict:[String:String])
    case transectionDetails(dict:[String:String])
    
    var path: String{
        switch self {
            case .transactionList:
                return "/transactionList"
            case .transectionDetails:
                return "/transectionDetails"
        }
    }
    
    var method: RequestMethod{
        switch self {
        case .transactionList,.transectionDetails:
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
        case .transactionList(let dict)  , .transectionDetails(let dict):
            var items = [URLQueryItem]()
            for (key,value) in dict{
                items.append(URLQueryItem(name: "\(key)", value: value))
            }
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
