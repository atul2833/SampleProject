

import Foundation

struct RentalPropertiesGetRequestParam: Encodable {
    var page: Int  // Use Int to represent numeric values
    var limit: Int // Ditto
    var totalPage: Int
    var search: String
    var type: String

    // Initialize with default values if needed
    init(page: Int = 1, limit: Int = 10, totalPage: Int = 1,search:String = "",type: String = "") {
        self.page = page
        self.limit = limit
        self.totalPage = totalPage
        self.search = search
        self.type = type
    }
}

enum RentalPropertiesEndPoint: EndpointProvider {
    case addProperty(multipartRequest : RentalPropertyMultipleImageModel)
    case propertyDetails(propertyId:String)
    case rentPropertyRequest(propertyId:String)

    case deleteProperty(propertyId:String)
    case removeImageOrVideo(mediaId:String)
    
    case leaveProperty(propertyId:String)
    case extendProperty(propertyId:String)

    
    case propertyList(RentalPropertiesGetRequestParam)
    case rentHistoryPropertyList(RentalPropertiesGetRequestParam)
    var path: String {
        switch self {
            
        case .rentHistoryPropertyList:
            "/propertyHistoryList"
        case .propertyDetails:
            "/propertyDetails"
        case .addProperty:
            "/addProperty"
        case .propertyList:
            "/propertyList"
        case .rentPropertyRequest:
            "/rentPropertyRequest"
        case .deleteProperty:
            "/deleteProperty"
        case .removeImageOrVideo:
            "/removeImageOrVideo"
        case .leaveProperty:
            "/leaveProperty"
        case .extendProperty:
            "/extendProperty"
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .propertyDetails, .rentHistoryPropertyList:
            return .GET
        case .deleteProperty,.removeImageOrVideo:
            return .DELETE
        default:
            return .POST
        }
    }
    
    var accessTokenRequired: Bool {
        true
    }
    
    var queryItems: [URLQueryItem]?{
        switch self {
            
        case .rentHistoryPropertyList(let model):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "page", value: String(model.page)))
            items.append(URLQueryItem(name: "limit", value: String(model.limit)))
            items.append(URLQueryItem(name: "type", value: model.type))

            return items
            
            
        case .propertyList(let model):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "page", value: String(model.page)))
            items.append(URLQueryItem(name: "limit", value: String(model.limit)))
            items.append(URLQueryItem(name: "type", value: model.type))

            return items
            
        case .propertyDetails(let propertyId),.deleteProperty(let propertyId):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "propertyId", value: propertyId))
            return items
            
        case .removeImageOrVideo(let mediaId):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "mediaId", value: mediaId))
            return items
        default:
            return nil
        }
    }
    
    var params: [String : Any]? {
        switch self {
       
        case .propertyList(let model):
            return ["search":model.search]

        case .rentPropertyRequest(let propertyId):
            return ["propertyId":propertyId]
            
        case .leaveProperty(let propertyId):
            return ["propertyId":propertyId]

        case .extendProperty(let propertyId):
            return ["propertyId":propertyId]
        default:
            return nil
        }
    }
    
    var multipart: MultipartRequest? {
        switch self {
        case .addProperty(multipartRequest: let userProfileImageModel):
            
            var multipartRequest = MultipartRequest()

            multipartRequest.append(
                parameters: [
                    "title": userProfileImageModel.title,
                    "propertyAreaSqt": userProfileImageModel.propertyAreaSqt,
                    "bedRooms": userProfileImageModel.bedRooms,
                    "bathRooms": userProfileImageModel.bathRooms,
                    "price": userProfileImageModel.price,
                    "rentTypeId": userProfileImageModel.rentTypeId,
                    "city": userProfileImageModel.city,
                    "description": userProfileImageModel.description,
                    "phoneNumber": userProfileImageModel.phoneNumber,
                    "propertyId": userProfileImageModel.propertyId,
                    "countryId": userProfileImageModel.countryId

                ], parametersArray: [
                    "specifications": userProfileImageModel.specifications,
                ],
                parametersObjects: [
                    "propertyAddress": userProfileImageModel.propertyAddress,
                ],
                fileDatas: userProfileImageModel.fileDatas,
                withName: userProfileImageModel.name,
                fileNames: userProfileImageModel.fileNames,
                mimeTypes: userProfileImageModel.mimeTypes
            )
            return multipartRequest
        default:
            return nil
        }
    }
    
    var mockFile: String? {
        nil
    }
}
