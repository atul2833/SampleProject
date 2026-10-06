//
//  BlockResponseModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 13/03/24.
//

import Foundation

struct BlockResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: BlockResponseDataModel?
}

struct PaymentResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: PaymentIdResponseModel?
}

struct PaymentIdResponseModel: Codable {
    var transactionId: String?
}

struct PayPalRedirectResponse: Codable {
    let status: Bool?
    let message: String?
    let result: PayPalRedirectResult?
}

struct PayPalRedirectResult: Codable {
    let redirectUrl: String?
    let transactionId: String?
}

struct BlockResponseDataModel: Codable {
    var count: String?
    var totalPage: Int?

    var blockList: [BlockDataModel]?
}

struct BlockDataModel: Codable {
    var status: String?
    var blockId: String?
    var designation: String?
    var referenceCode : String?
    var amount : Double?
    var blockName : String?
    var statusText : String?
    var isVotingResultComing : Bool?
    var canSendInvitation: Bool?
    var depositRules:String?
    var description : String?
    var statusStage : String?
    var city : String?
    var duration : String?
    var createdAt : String?
    var country : String?
    var paymentDueDate : String?
    var totalNumberOfUnit : Int?
    var dateOfActivation:String?
    var dateOfRenewal:String?
    var isABlockMember : Bool?
    var isLateChargeAplied: Bool?
    var blockMemberData:BlockMemberResponseDataModel?
    var userData:BlockMembersDataModel?
}

struct BlockMemberResponseDataModel: Codable {
    var count: String?
    var expireTime : String?
    var pollId : String?
    var memberList: [BlockMembersDataModel]?
}

struct BlockMembersDataModel: Codable {
    var userId : String?
    var pollId : String?
    var profileImage: String?
    var fullName: String?
    var voteCount : String?
    var designation : String?
    var isSwapMember: Bool?
    var isMemberLeft: Bool?
    var isSwapRequested: Bool?
    
    var emailAddress: String?
    var phoneNumber: String?
    var countryCode: String?
    var userType:String?
    var fullPhoneNumber: String {
        return "\(countryCode ?? "") \(phoneNumber ?? "")"
    }
    var profileImageUrl: URL? {
        if let profileImage {
            return URL(string: String(format: "%@%@", ServerConfiguration.shared.baseImageURL, profileImage))
        }
        return nil
    }
}
