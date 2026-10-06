//
//  ProfileSettingsEndPoints.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 13/03/24.
//

import Foundation

enum ProfileSettingsEndPoint: EndpointProvider {
    case deleteAccount
    case logout
    case updateSetting(isNotificationEnabled:Bool)
    case updateProfile(dict: [String: Any])
    case updateImageProfile(multipartRequest : UserProfileImageModel)
    case helpRequest(multipartRequest : UserProfileMultipleImageModel)

    case updateEmailOrPhone(dict: [String: Any])
    case helpSubjectList
    
    var path: String {
        switch self {
        case .deleteAccount:
            "/deleteAccount"
        case .updateProfile:
            "/updateName"
        case .updateImageProfile:
            "/updateProfileImage"
        case .helpRequest:
            "/helpRequest"
        case .updateEmailOrPhone:
            "/sendOtpNumberOrEmail"
        case .logout:
            "/logout"
        case .updateSetting:
            "/updateSetting"
        case .helpSubjectList:
            "/helpSubjectList"
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .deleteAccount:
            return .DELETE
        case .updateProfile, .updateImageProfile:
            return .PUT
        case .updateSetting:
            return .PATCH
        case .logout,.helpSubjectList:
            return .GET
        default:
            return .POST
        }
    }
    
    var accessTokenRequired: Bool {
        true
    }
    
    var queryItems: [URLQueryItem]? {
        nil
    }
    
    var params: [String : Any]? {
        switch self {
        case .updateProfile(let dict),.updateEmailOrPhone(let dict):
            return dict
        case .updateSetting(let isNotificationEnabled):
            return ["isNotificationEnabled":isNotificationEnabled]

        default:
            return nil
        }
    }
    
    var multipart: MultipartRequest? {
        switch self {
        case .updateImageProfile(multipartRequest: let userProfileImageModel):
            var multipartRequest = MultipartRequest()
            multipartRequest.append(fileData: userProfileImageModel.fileData, withName: userProfileImageModel.name, fileName: userProfileImageModel.fileName, mimeType: userProfileImageModel.mimeType)
            return multipartRequest
            
        case .helpRequest(multipartRequest: let userProfileImageModel):
            var multipartRequest = MultipartRequest()
            multipartRequest.append(parameters: ["helpSubjectId":userProfileImageModel.helpSubjectId,"orderId":userProfileImageModel.orderId,"description":userProfileImageModel.description], fileDatas: userProfileImageModel.fileDatas, withName: userProfileImageModel.name, fileNames: userProfileImageModel.fileNames, mimeType: userProfileImageModel.mimeType)
            return multipartRequest
            
        default:
            return nil
        }
    }
    
    var mockFile: String? {
        nil
    }
}
