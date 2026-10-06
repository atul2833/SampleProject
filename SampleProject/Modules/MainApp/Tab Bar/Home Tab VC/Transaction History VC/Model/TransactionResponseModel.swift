//
//  TransactionResponseModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 21/03/24.
//

import Foundation

struct TransactionResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: TransactionResponseDataModel?
}

struct TransactionResponseDataModel: Codable {
    var totalPage: Int?
    var transactionList: [TransactionDataModel]?
}

struct TransactionDetailResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: TransactionDetailDataModel?
}

struct TransactionDetailDataModel: Codable {
    var amount: Double?
    var statusText: String?
    var status: String?
    var dataList: [TransactionDetailChildModel]?
}

struct TransactionDataModel: Codable {
    var transactionId: String?
    var name: String?
    var timeDate: String?
    var amount: Double?
    var status: String?
}

struct TransactionDetailChildModel: Codable {
    var title: String?
    var value: String?
    var type: String?
}
