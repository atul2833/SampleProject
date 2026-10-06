//
//  MyContributionResponseModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 27/03/24.
//

import Foundation

struct ContributionResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: ContributionResponseDataModel?
}

struct ContributionResponseDataModel: Codable {
    var totalPage: Int?
    var contributionList: [ContributionResponseInnerDataModel]?
}

struct ContributionResponseInnerDataModel:Codable{
    var creditData:CreditDataModel?
    var contributionData:ContributionDataModel?
    var blockData:BlockDataModel?
}

struct ContributionDataModel: Codable {
    var contributedAmount: Double?
    var totalBlockValue: Double?
    var creditedAmount: Double?
    var currentValue: Double?
}


