//
//  ProfileInfoViewResponseModel.swift
//  ComeraMoney
//
//  Created by NIKETAN SHARMA on 12/02/24.
//

import Foundation

struct ProfileInfoResponseModel: Codable, Hashable {
    var status: Bool?
    var message: String?
    var user: ProfileInfoModel?
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case user = "result"
    }
}

struct ProfileInfoModel: Codable, Hashable {
    var emailAddress: String?
    var isNotificationEnabled: Bool?
    var userType: String?
    var uqudoSessionId: String?
    var deviceType: String?
    var status: String?
    var profileImage: String?
    var fullName: String?
    var countryCode: String?
    var countryId: String?
    var countryCurrency: String?

    var userId: String?
    var phoneNumber: String?
    var kycDone: String?
    var isEmailVerified:Bool?
    var isSubscribed:Bool
    var fullPhoneNumber: String {
        return "\(countryCode ?? "") \(phoneNumber ?? "")"
    }
    
    var userSubscriptionPlan: SubscriptionInfoModel?
    var profileImageUrl: URL? {
        if let profileImage {
            return URL(string: String(format: "%@%@", ServerConfiguration.shared.baseImageURL, profileImage))
        }
        return nil
    }
}

struct KycModel: Codable, Hashable {
    var title: String?
    var value: String?
    var getInDateString: String? {
        if title?.lowercased().contains("date") ?? false, 
            let value {
            return value.convertIntoDate()
        }
        return value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try container.decodeIfPresent(String.self, forKey: .title)
        if let stringValue = try? container.decode(String.self, forKey: .value) {
            value = stringValue
        } else if let intValue = try? container.decode(Int.self, forKey: .value) {
            value = intValue.description
        } else {
            value = nil
        }
    }
    
}
