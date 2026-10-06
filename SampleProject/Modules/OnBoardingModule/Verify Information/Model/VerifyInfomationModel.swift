//
//  VerifyInfomationModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 12/03/24.
//

import Foundation

struct KYCDetailList: Codable {
    var title : String?
    var value : String?
    var hidden : String?
    var isShowing : String?

}

struct IdentityInformationResponseModel : Codable {
    let status : Bool?
    let message : String?
    let result : [InformationModel]?
}

struct InformationModel: Codable {
    let title : String?
    let value: String?
    
    var getInDateString: String? {
          if let title = title,
             title.contains("Date") {
              return value?.convertIntoDate()
          }else {
              return value

          }
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

struct KYCResponseModel : Codable {
    let status : Bool?
    let message : String?
    let result : KYCDocumentList?
}

struct KYCDocumentList: Codable {
    let documentTypeList: [DocumentTypeList]
    let totalPage: Int
    let count: String
}

struct DocumentTypeList: Codable {
    let id : Int?
    let title: String?
}

struct KycUpdateResponseModel: Codable {
    let status: Bool?
    let message: String?
}

