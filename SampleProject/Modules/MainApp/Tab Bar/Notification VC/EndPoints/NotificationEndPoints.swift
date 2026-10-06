//
//  NotificationEndPoints.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 14/03/24.
//

import Foundation

struct NotificationGetRequestParam: Encodable {
    var page: Int  // Use Int to represent numeric values
    var limit: Int // Ditto
    var totalPage: Int
    
    // Initialize with default values if needed
    init(page: Int = 1, limit: Int = 10, totalPage: Int = 1) {
        self.page = page
        self.limit = limit
        self.totalPage = totalPage
    }
}

enum NotificationEndPoints: EndpointProvider {
   
    case notificationsList(NotificationGetRequestParam)
    case rejectReasonList(type: String)
    case acceptRejectRequest(dict:[String:Any])
    
    var path: String {
        switch self {
        case .notificationsList:
            return "/notificationsList"
        case .rejectReasonList:
            return "/rejectReasonList"
        case .acceptRejectRequest:
            return "/acceptRejectRequest"
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .acceptRejectRequest:
            return .POST
        default:
            return .GET
        }
    }
    
    var accessTokenRequired: Bool {
        true
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .notificationsList(let model):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "page", value: String(model.page)))
            items.append(URLQueryItem(name: "limit", value: String(model.limit)))
            
            return items
            
        case .rejectReasonList(let type):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "type", value: type))
            return items
        default:
            return nil
        }
    }
    
    var params: [String : Any]? {
        switch self {
        case .acceptRejectRequest(let dict):
            return dict

        default:
            return nil
        }
    }
    var mockFile: String? {
        nil
    }
}
