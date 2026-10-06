//
//  RegisterResponseModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 12/03/24.
//

import Foundation

struct ResponseSuccessModel : Codable {
    let status : Bool?
    let message : String?
    let result : String?
}
