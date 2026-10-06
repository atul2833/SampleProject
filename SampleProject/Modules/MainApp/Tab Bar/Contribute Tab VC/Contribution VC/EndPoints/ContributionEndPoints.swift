//
//  MyContributionEndPoints.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 27/03/24.
//

import Foundation

enum ContributionEndPoints: EndpointProvider{
   
    case userContributionList(page:String,limit:String)
    case blockLoansList(page:String,limit:String,blockId:String)
    
    var path: String{
        switch self {
            case .userContributionList:
                return "/userContributionList"
            case .blockLoansList:
                return "/blockLoansList"
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
        case .userContributionList(let page,let limit):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "page", value: page))
            items.append(URLQueryItem(name: "limit", value: limit))

            return items
        case .blockLoansList(let page,let limit,let blockId):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "page", value: page))
            items.append(URLQueryItem(name: "limit", value: limit))
            items.append(URLQueryItem(name: "blockId", value: blockId))

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
