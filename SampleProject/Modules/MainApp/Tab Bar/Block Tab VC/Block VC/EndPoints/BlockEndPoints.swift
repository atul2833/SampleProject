//
//  CreateBlockEndPoints.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 13/03/24.
//

import Foundation

struct BlockGetRequestParam: Encodable {
    var page: Int  // Use Int to represent numeric values
    var limit: Int // Ditto
    var totalPage: Int
    var search: String
    var type: String

    // Initialize with default values if needed
    init(page: Int = 1, limit: Int = 10, totalPage: Int = 1,search:String = "",type: String = "") {
        self.page = page
        self.limit = limit
        self.totalPage = totalPage
        self.search = search
        self.type = type
    }
}

enum BlockEndPoints: EndpointProvider {
 
    case dropDownListData(type:String,countryId:String)
    case createBlocks(dict:[String:Any])
    case blockList(list:BlockGetRequestParam)
    case joinBlock(dict:[String:Any])
    
    case blockMembersList(dict:[String:String])
    case blockDetails(blockId:String)
    case requestJoinBlock(blockId:String)
    case vote(dict:[String:Any])
    case leaveBlock(dict:[String:Any])
    case voterList(dict:[String:Any])
    case voteResult(blockId:String)
    case payment(blockId:String)
    case updateVotingResultSettings(blockId:String)
    case depositDetails(blockId: String)
    case leaveMemberDetails(blockId: String,memberId: String)
    case swapRequest(blockId: String,receiverId: String)
    case blockHistoryList(list:BlockGetRequestParam)

    var path: String {
        switch self {
        case .blockHistoryList:
            "/userBlockHistoryList"
        case .dropDownListData:
            "/dropDownListData"
        case .createBlocks:
            "/createBlocks"
        case .blockList:
             "/blockList"
        case .joinBlock:
            "/joinBlock"
        case .blockMembersList:
            "/blockMembersList"
        case .blockDetails:
            "/blockDetails"
        case .requestJoinBlock:
            "/requestJoinBlock"
        case .vote:
            "/vote"
        case .leaveBlock:
            "/leaveBlock"
        case .voterList:
            "/voterList"
        case .voteResult:
            "/voteResult"
        case .payment:
            "/payment"
        case .updateVotingResultSettings:
            "/updateVotingResultSettings"
        case .depositDetails:
            "/depositDetails"
        case .leaveMemberDetails:
            "/leaveMemberDetails"
        case .swapRequest:
            "/swapRequest"
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .dropDownListData,.blockDetails,.blockMembersList,.depositDetails,.leaveMemberDetails,.voterList,.voteResult:
            return .GET
        default:
            return .POST
        }
    }
    
    var accessTokenRequired: Bool {
        switch self {
           case .dropDownListData:
               return false
           default:
               return true
           }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .dropDownListData(let type,let countryId):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "type", value: type))
            items.append(URLQueryItem(name: "countryId", value: countryId))
            return items

        case .blockList(let model):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "type", value: model.type))
            items.append(URLQueryItem(name: "page", value: String(model.page)))
            items.append(URLQueryItem(name: "limit", value: String(model.limit)))
            return items
            
        case .blockHistoryList(let model):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "type", value: model.type))
            items.append(URLQueryItem(name: "page", value: String(model.page)))
            items.append(URLQueryItem(name: "limit", value: String(model.limit)))
            return items

        case .blockDetails(let blockId):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "blockId", value: blockId))
            return items

        case .blockMembersList(let dict):
            var items = [URLQueryItem]()
            for (key,value) in dict{
                items.append(URLQueryItem(name: "\(key)", value: value))
            }
            return items
        case .voteResult(let blockId):
            var items = [URLQueryItem]()
//            for (key,value) in dict{
                items.append(URLQueryItem(name: "blockId", value: blockId))
//            }
            
            return items
        case .depositDetails(let blockId):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "blockId", value: blockId))
            return items
            
        case .voterList(let dict):
            var items = [URLQueryItem]()
            for (key,value) in dict{
                items.append(URLQueryItem(name: "\(key)", value: value as? String))
            }
            return items
            
        case .leaveMemberDetails(let blockId,let memberId):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "blockId", value: blockId))
            items.append(URLQueryItem(name: "memberId", value: memberId))
            return items
            
        default:
            return nil
        }
    }
    
    var params: [String : Any]? {
        switch self {
       
        case .createBlocks(let dict),.joinBlock(let dict),.vote(let dict),.leaveBlock(let dict):
            return dict
        
        case .requestJoinBlock(let blockId),.payment(let blockId),.updateVotingResultSettings(let blockId):
            return ["blockId":blockId]

        case .blockList(let model):
            return ["search":model.search]
            
        case .swapRequest(let blockId, let receiverId):
            return ["blockId":blockId,"receiverId":receiverId]

        default:
            return nil
        }
    }
    
    var multipart: MultipartRequest? {
        nil
    }
    
    var mockFile: String? {
        nil
    }
}
