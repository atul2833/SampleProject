//
//  WalkThroughModel.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 09/01/2024.
//

import Foundation

struct WalkThroughResponseModel : Decodable {
    let status : String?
    let message : String?
    let walkThroughItems : [WalkThroughModel]?
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case walkThroughItems = "data"
    }
}

struct WalkThroughModel : Decodable {
    let sNo : Int?
    let id : Int?
    let image : String?
    let title : String?
    let description : String?
    var imageUrl: URL? {
        if let image {
            return URL(string: String(format: "%@%@", ServerConfiguration.shared.baseImageURL, image))
        }
        return nil
    }
}
