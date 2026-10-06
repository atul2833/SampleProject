//
//  ApiResponse.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import Foundation

struct ApiResponse: Error {
    var statusCode: Int = 0
    let status: Bool
    var message: String
    var response: HTTPURLResponse?

    init(statusCode: Int = 0, status: Bool, message: String, response: HTTPURLResponse? = nil) {
        self.status = status
        self.statusCode = statusCode
        self.message = message
        self.response = response
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case message
    }
}

extension ApiResponse: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(Bool.self, forKey: .status)
        message = try container.decode(String.self, forKey: .message)
    }
}
