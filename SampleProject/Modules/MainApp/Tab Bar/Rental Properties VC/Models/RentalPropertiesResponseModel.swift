//
//  RentalPropertiesResponseModel.swift
//  TAGCreditMerchant
//
//  Created by somendra on 19/07/24.
//

import Foundation

struct RentalPropertiesResponseModel: Codable {
    let status: Bool?
    let message: String?
    var result: RentalPropertiesDataModel?
}

struct RentalPropertiesDataModel: Codable {
    var count :String?
    var totalPage: Int
    var propertyList: [PropertyDataModel]?
}

struct PropertyDataModel: Codable {
    var title: String?
    var propertyId: String?
    var propertyStatus : String?
    var description : String?
    var propertyStatusText : String?
    var rentType : String?
    var price : String?
    var cityId : String?
    var propertyImage : String?
    var isAlreadyRequested : Bool?
    var countryCode : String?
    var propertyAddress : AddressDataModel?
    var propertyMediaList : [PropertyMediaListModel]?
    var bedRooms : String?
    var specificationList : [String]?
    var bathRooms : String?
    var rentTypeId : String?
    var propertyAreaSqt : String?
    var phoneNumber : String?
    var userData : BlockMembersDataModel?

    var propertyImageURL: URL? {
        if let propertyImage {
            return URL(string: String(format: "%@%@", ServerConfiguration.shared.baseImageURL, propertyImage))
        }
        return nil
    }
}

struct RentalPropertiesDetailResponseModel: Codable {
    let status: Bool?
    let message: String?
    var result: PropertyDataModel?
}

struct PropertyMediaListModel: Codable {
    var value: String?
    var title: String?
    var type: String?
    var mediaId: Int?
}

struct AddressDataModel: Codable {
    var addressId, longitude, latitude, address1: String?
    var cityId, city, address2, pincode: String?
    var isDefault: Bool?
    var type: String?

}
