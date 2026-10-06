//
//  BlockMemberResponseModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 14/03/24.
//

import Foundation

struct BlockMemberResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: BlockMemberModelData?
}

struct BlockMemberModelData: Codable {
    var pollId: String?
    var count: String?
    var totalPage: Int?
    var expireTime: String?
    var memberList: [BlockMembersDataModel]?
}


struct BlockMemberVotingResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: [BlockMembersDataModel]?
}






