//
//  MyContactsResponseModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 01/04/24.
//

import Foundation

struct MyContactsResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: [MyContactsDataModel]?
}

struct MyContactsDataModel: Codable {
    var profileImage: String?
    var phone: String?
    var isAlreadyMember: Bool?
    var name: String?
    var userId : String?
    var userType : String?
    
    var isSelected : Bool?
}
