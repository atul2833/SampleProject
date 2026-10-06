//
//  BlockDetailResponseModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 14/03/24.
//

import Foundation

struct BlockDetailResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: BlockDataModel?
}


