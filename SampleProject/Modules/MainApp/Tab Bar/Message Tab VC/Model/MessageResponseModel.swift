//
//  MessageResponseModel.swift
//  TAGCreditMerchant
//
//  Created by NIKETAN SHARMA on 25/04/24.
//

import Foundation

struct MessageResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: MessageResponseDataModel?
}

struct MessageResponseDataModel: Codable {
    var count: String?
    var totalPage: Int?
    var messageList: [MessageResponseSubDataModel]?
}

struct MessageResponseSubDataModel: Codable {
    var blockData:BlockDataModel?
    var messageData: MessageDataModel?
    var propertyData: PropertyDataModel?
}

struct MessageDataModel: Codable {
    var messageId: String?
    var senderId: String?
    var groupId:String?
    var receiverId : String?
    var content : String?
    var timeDate : String?
    var contentType : String?
    var title : String?
    var isSeen : Bool?
    var imagesData:[String]?
    var swapRequestData: SwapRequestData?
    var propertyRequestData: SwapRequestData?
    var propertyData: PropertyDataModel?

    var blockData : BlockDataModel?
    var creditRequestData:CreditDataModel?
}
struct SwapRequestData: Codable {
    var status: String?
    var statusText:String?
    var isRequestApproved:Bool?
    let swapRequestId: String?
    let amount: Double?
    let duration: String?
      
}

struct CreditDataModel: Codable {
    var status: String?
    var statusText:String?
    var creditRequestId: String?
    var interestRate: Double?
    var loanAmount: Double?
    var repaymentDuration :String?
    var totalAmount: Double?
    var dueAmount: Double?
    var paidAmount:Double?
    var isRequestApproved:Bool?
}

struct MessageInnerResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: MessageResponseInnerDataModel?
}

struct MessageResponseInnerDataModel: Codable {
    var action: String?
    var createGroup: MessageInnerResponseDataModel?
    var newMessage:[MessageDataModel]?
    var updateMessage:[MessageDataModel]?
    var removeMessageId: String?
    var blockUser:String?
    var clearChat:String?
    
}

struct MessageInnerResponseDataModel: Codable {
    var groupId: String?
    var groupName: String?
    var isBlocked: Bool?
    var canSendMessage : Bool?
    var messageList :[MessageDataModel]?
}


