//
//  ContributionDetailResponseModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 27/05/24.
//

import Foundation

struct ContributionDetailResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: ContributionDetailResponseDataModel?
}

struct ContributionDetailResponseDataModel: Codable {
    var totalPage: Int?
    var count: String?
    var contributionData: ContributionDetailDataModel?
    var blockLoansList:[BlockLoansListModel]?
}

struct ContributionDetailDataModel: Codable {
    var totalCreditedMoney: Double?
    var currentBlockValue: Double?
    var totalContribution: Double?
    var totalBlockValue: Double?
}


struct BlockLoansListModel:Codable{
    var userData:BlockMembersDataModel?
    var creditData:CreditDataModel?
}

