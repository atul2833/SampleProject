//
//  MessageEndPoints.swift
//  TAGCreditMerchant
//
//  Created by NIKETAN SHARMA on 25/04/24.
//

import Foundation

struct MessageGetRequestParam: Encodable {
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

enum MessageEndPoints: EndpointProvider {
   
    case messageList(MessageGetRequestParam)
    case rejectReasonList
    case acceptRejectRequest(dict:[String:Any])
    case uploadChatImage(multipartRequest : MessageMultipleImageModel)

    var path: String {
        switch self {
        case .messageList:
            return "/messageList"
        case .rejectReasonList:
            return "/rejectReasonList"
        case .acceptRejectRequest:
            return "/acceptRejectRequest"
        case .uploadChatImage:
           return "/uploadChatImage"
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .acceptRejectRequest,.uploadChatImage:
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
        case .messageList(let model):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "page", value: String(model.page)))
            items.append(URLQueryItem(name: "limit", value: String(model.limit)))
            
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
    
    var multipart: MultipartRequest? {
        switch self {
      
            
        case .uploadChatImage(multipartRequest: let userProfileImageModel):
            var multipartRequest = MultipartRequest()
            multipartRequest.append(parameters: ["senderId":userProfileImageModel.senderId,"groupId":userProfileImageModel.groupId], fileDatas: userProfileImageModel.fileDatas, withName: userProfileImageModel.name, fileNames: userProfileImageModel.fileNames, mimeType: userProfileImageModel.mimeType)
            return multipartRequest
            
        default:
            return nil
        }
    }
    
    var mockFile: String? {
        nil
    }
}
