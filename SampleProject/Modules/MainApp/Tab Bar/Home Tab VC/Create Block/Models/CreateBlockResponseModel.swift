//
//  CreateBlockResponseModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 01/04/24.
//

import Foundation

struct CreateBlockResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: CreateBlockDataModel?
}

struct CreateBlockDataModel: Codable {
    var blockId: String?
}
