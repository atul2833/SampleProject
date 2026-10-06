//
//  OTPResponseModel.swift
//  ComeraMoney
//
//  Created by NIKETAN SHARMA on 12/02/24.
//

import Foundation

struct OTPResponseModel : Codable {
    let status : Bool?
    let message : String?
    let verifiedModel : VerifiedModel?

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case verifiedModel = "result"
    }
}

struct VerifiedModel: Codable {
    let accessToken : String?
    let accessType : String?
    let refreshToken : String?
    let kycDone: String?
    let kycStatus: String?
    let isSubscribed:Bool?
}

struct OTPResendResponseModel : Codable {
    let status : Bool?
    let message : String?
    let result : String?
}
