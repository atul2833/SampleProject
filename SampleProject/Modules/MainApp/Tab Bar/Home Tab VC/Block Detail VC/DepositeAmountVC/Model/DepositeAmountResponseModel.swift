import Foundation

struct DepositeAmountResponseModel: Codable {
    let status: Bool?
    let message: String?
    let result: [DepositeAmountDataModel]?
}

struct DepositeAmountDataModel: Codable {
    let title, value: String?
    
}

