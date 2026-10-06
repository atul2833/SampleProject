//
//  MyContributionResponseModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 27/03/24.
//

import Foundation

struct CreditResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: CreditResponseDataModel?
}

struct CreditResponseDataModel: Codable {
    var count:String?
    var totalPage: Int?
    var creditList: [CreditResponseSubDataModel]?
}

struct CreditResponseSubDataModel: Codable {
    var blockData:BlockDataModel?
    var creditData: CreditDataModel?
}

struct CreditDetailResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: CreditResponseSubDataModel?
}
