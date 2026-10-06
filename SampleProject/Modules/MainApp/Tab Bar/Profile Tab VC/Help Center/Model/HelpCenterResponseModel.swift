//
//  HelpCenterResponseModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 13/03/24.
//

import Foundation

struct HelpCenterResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: [HelpCenterModel]?
}

struct HelpCenterModel: Codable {
    var id: String?
    var title: String?
    let value: String?
}



