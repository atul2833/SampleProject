//
//  WalletResponseModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 02/05/24.
//

import Foundation


struct PaymentMethodResponse: Codable {
    let status: Bool?
    let message: String?
    let result: [PaymentMethod]?
}

struct PaymentMethod: Codable {
    let id: Int?
    let title: String?
    let value: String?
    let image: String?
    
    var payImageUrl: URL? {
        if let image {
            return URL(string: String(format: "%@%@", ServerConfiguration.shared.baseImageURL, image))
        }
        return nil
    }
}

struct WalletBalanceResponseModel: Codable, Hashable {
    var status: Bool?
    var message: String?
    var result: WalletBalanceModel?
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case result
    }
}

struct WalletBalanceModel: Codable, Hashable {
    var currentValue: Double?
    var totalContribution: Double?
    var totalCreditedAmount: Double?
}

struct FundTransferResponseModel: Codable, Hashable {
    var status: Bool?
    var message: String?
    var result: BankDataResponseModel?
}

struct BankDataResponseModel: Codable, Hashable {
    var methodId: String?
    var bankName: String?
    var image: String?
    var accountNumber: String?
    
    var imageUrl: URL? {
        if let image {
            return URL(string: String(format: "%@%@", ServerConfiguration.shared.baseImageURL, image))
        }
        return nil
    }
}
