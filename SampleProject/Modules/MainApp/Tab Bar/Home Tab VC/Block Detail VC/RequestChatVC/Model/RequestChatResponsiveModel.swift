//
//  RequestChatResponsiveModel.swift
//  TAGCredit
//
//  Created by somendra on 27/06/24.
//

import Foundation
import Foundation


struct RequestChatResponsiveModel: Codable {
    let status: Bool?
    let message: String?
    let result: RequestChatDataModel?
}


struct RequestChatDataModel: Codable {
    let totalAmountPay: String?
    let amountList: [AmountList]
}


struct AmountList: Codable {
    let title, value, type: String?
}



struct SwapRequestResponsiveModel: Codable {
    let status: Bool?
    let message: String?
    let result: ResultModel?
}

struct ResultModel: Codable {
    let groupId: String?

}
