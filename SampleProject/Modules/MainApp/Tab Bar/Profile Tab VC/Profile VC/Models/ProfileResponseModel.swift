//
//  ProfileResponseModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 13/03/24.
//

import Foundation

struct UpdateProfileImageResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: UpdateProfileImageModel?
}

struct UpdateProfileImageModel: Codable {
    var profileImage: String?
}

struct HelpCentreImageResponseModel: Codable {
    var status: Bool?
    var message: String?
}
