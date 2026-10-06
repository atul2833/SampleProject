//
//  MyContributionEndPoints.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 27/03/24.
//

import Foundation

enum CreditEndPoints: EndpointProvider{
    
    case merchantBlockLoanList(page:String,limit:String)
    case merchantLoanDetails(creditRequestId:String)
    var path: String{
        switch self {
            case .merchantBlockLoanList:
                return "/merchantBlockLoanList"
            case .merchantLoanDetails:
                return "/merchantLoanDetails"
        }
    }
    
    var method: RequestMethod{
        return .GET
    }
    
    var accessTokenRequired: Bool{
        true
    }
    
    var queryItems: [URLQueryItem]?{
        switch self {
        case .merchantBlockLoanList(let page,let limit):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "page", value: page))
            items.append(URLQueryItem(name: "limit", value: limit))

            return items
            
        case .merchantLoanDetails(let creditRequestId):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "creditRequestId", value: creditRequestId))
            return items
        default:
            return nil
        }
    }
    
    var params: [String : Any]?{
        return nil

    }
    var mockFile: String? {
        nil
    }
}
