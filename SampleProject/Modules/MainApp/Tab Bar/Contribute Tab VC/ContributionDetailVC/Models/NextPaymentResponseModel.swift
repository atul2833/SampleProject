//
//  NextPaymentResponseModel.swift
//  TAGCreditMerchant
//
//  Created by NIKETAN SHARMA on 09/05/24.
//

import Foundation

struct NextPaymentResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: NextPaymentResponsDataModel?
}

struct NextPaymentResponsDataModel: Codable {
    var count: Int?
    var totalPage: Int?
    var emiList: [NextPaymentDataModel]?
}


struct NextPaymentDataModel: Codable {
    var blockName: String?
    var timeDate: String?
    var blockId: String?
    var dueAmount: Double?
    var emiId: String?
    var rePaymentDurationRule:String?
}
