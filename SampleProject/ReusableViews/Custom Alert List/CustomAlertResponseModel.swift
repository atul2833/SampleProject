//
//  CustomAlertResponseModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 25/06/24.
//

import Foundation

struct CustomAlertListResponseModel: Codable, Hashable {
    var status: Bool?
    var message: String?
    var result: CustomAlertListResponseDataModel?
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case result = "result"
    }
}

struct CustomAlertListResponseDataModel: Codable, Hashable {
    var content: String?
    var title: String?
}
