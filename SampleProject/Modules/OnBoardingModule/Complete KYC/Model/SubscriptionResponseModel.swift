//
//  SubscriptionResponseModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 12/03/24.
//

import Foundation

struct SubscriptionResponseModel : Codable {
    let status : Bool?
    let message : String?
    let result : [SubscriptionInfoModel]?
}

struct SubscriptionInfoModel : Codable,Hashable {
    let id:String?
    let descriptionList : [String]?
    let name : String?
    let title : String?
    let expirationDate : String?

    let price : String?
    let duration : String?
    var selected : Bool? = false
}
