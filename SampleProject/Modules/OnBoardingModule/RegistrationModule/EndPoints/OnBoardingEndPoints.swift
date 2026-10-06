//
//  OnBoardingEndPoints.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 09/01/2024.
//

import Foundation

enum OnBoardingEndPoints: EndpointProvider {
    
    case login(
        countryId: String?,
        phoneNumber: String?
    )
    
    case signup(
        phoneNumber: String?,
        emailAddress: String?,
        fullName: String?,
        cityId:String?,
        countryId:String?

    )
    case verify(
        phoneNumber: String?,
        emailAddress: String?,
        fullName: String?,
        otpCode: String?,
        cityId:String?,
        countryId:String?,

        type:String?
    )
    
    case verifyNumberOrEmail(
        phoneNumber: String?,
        emailAddress: String?,
        otpCode: String?,
        type:String?,
        countryId:String?
    )
    
    case userKyc(type: String)
    case userKycDocumentTypes(page:Int,limit:Int)
    case saveKycDocument(multipartRequest : KycSaveDataModel)
    case updatePlan(planId:String)
    case resend(
        countryId: String?,
        phoneNumber: String?
    )
   
    case userKycInfo
    case plans
    case getProfile


    var path: String {
        switch self {
        case .signup:
            return "/signup"
        case .login:
            return "/login"
        case .verify:
            return "/verifyOtp"
        case .verifyNumberOrEmail:
            return "/verifyNumberOrEmail"
        case .resend:
            return "/resend-otp"
        case .userKyc:
            return "/userKyc"
        case .updatePlan:
            return "/updatePlan"        
        case .userKycInfo:
            return "/userKycInfo"
        case .plans:
            return "/plans"
        case .getProfile:
            return "/user/profile"
        case .userKycDocumentTypes:
            return "/kycDocumentTypes"
        case .saveKycDocument:
            return "/userKyc"

        }
    }
    
    var baseURL: String {
        return ServerConfiguration.shared.userURLConfiguration.baseURL
    }
    
    var accessTokenRequired: Bool {
        switch self {
        case .userKycInfo, .userKyc, .plans,.updatePlan, .getProfile,.verifyNumberOrEmail,.userKycDocumentTypes,.saveKycDocument:
            return true
        default:
            return false
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .getProfile, .userKycInfo,.plans,.userKycDocumentTypes:
            return .GET
        default:
            return .POST
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .plans:
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "userType", value: userType))
            return items

        case .userKycDocumentTypes(let page,let limit):
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "page", value: String(page)))
            items.append(URLQueryItem(name: "limit", value: String(limit)))
            return items
            
        default:
            return nil
        }
    }
    
    var params: [String: Any]? {
        switch self {
        case .signup(let phoneNumber, let emailAddress, let fullName,let cityId, let countryId):
            return [
                "phoneNumber": phoneNumber ?? "",
                "emailAddress":emailAddress ?? "",
                "fullName":fullName ?? "",
                "cityId":cityId ?? "",
                "countryId":countryId ?? "37",
                "userType":userType
            ]
            
        case .login(let countryId, let phoneNumber):
            return [
                "countryId": countryId ?? "37",
                "phoneNumber": phoneNumber ?? "",
                "userType":userType
            ]
            
        case .resend(let countryId, let phoneNumber):
        return [
            "type":"login",
            "phoneNumber": phoneNumber ?? "",
            "emailAddress":"",
            "userType":userType,
            "countryId":countryId ?? "37"

        ]
            
        case .verify(let phoneNumber, let emailAddress, let fullName, let otpCode,let cityId, let countryId,let type):
            return [
                "otpCode": otpCode ?? "",
                "phoneNumber": phoneNumber ?? "",
                "emailAddress":emailAddress ?? "",
                "fullName":fullName ?? "",
                "countryId":countryId ?? "37",
                "cityId":cityId ?? "",
                "type":type ?? "",
                "userType":userType
            ]
            
        case .verifyNumberOrEmail(let phoneNumber, let emailAddress, let otpCode, let type, let countryId):
            return [
                "otpCode": otpCode ?? "",
                "phoneNumber": phoneNumber ?? "",
                "emailAddress":emailAddress ?? "",
                "currencySymbol":"",
                "type":type ?? "",
                "userType":userType,
                "countryId": countryId ?? "37"

            ]
            
        case .userKyc(let type):
            return ["type": type]
        
        case .updatePlan(let planId):
            return ["planId": planId]
        default:
            return nil
        }
    }
    
    var mockFile: String? {
        return "localResponseJsonFileNameForeachCase"
    }
    
    var multipart: MultipartRequest? {
        switch self {
        case .saveKycDocument(multipartRequest: let KycSaveDataModel):
            var multipartRequest = MultipartRequest()
            multipartRequest.append(parameters: ["nationalIdentityTypeId":KycSaveDataModel.nationalIdentityTypeId,"nationalIdentityNumber":KycSaveDataModel.nationalIdentityNumber], fileDatas: KycSaveDataModel.fileDatas, withName: KycSaveDataModel.name, fileNames: KycSaveDataModel.fileNames, mimeType: KycSaveDataModel.mimeType)
            return multipartRequest
            
        default:
            return nil
        }
    }
}
