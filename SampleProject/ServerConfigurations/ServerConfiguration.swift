//
//  ServerConfiguration.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import Foundation

struct URLConfiguration {
    let scheme: String
    let baseURL: String
    let port: Int
}

final class ServerConfiguration {
    static let shared = ServerConfiguration()
    
    enum Environment: String {
        case DEVElOPMENT, QA, PRODUCTION
    }
    
    private var currentEnvironment: Environment = .DEVElOPMENT
    
    
     let privacyPolicyURL = "http://162.241.71.136:7081/page/user-privacy-policy/"
     let termsOfServiceURL = "http://162.241.71.136:7081/page/user-terms-and-conditions/"
     let chatSocketUrl = "ws://162.241.71.136:7081/ws/chat/"
    
    private init() {}
    
//    func setEnvironment() {
//#if DEV
//        currentEnvironment = .DEVElOPMENT
//#elseif QA
//        currentEnvironment = .QA
//#elseif PRODUCTION
//        currentEnvironment = .PRODUCTION
//#endif
//    }
    
    @inline(never)
    private var scheme: String {
        return "http"
    }
    @inline(never)
    private var baseURL: String {
        switch currentEnvironment {
        case .PRODUCTION:
            return "65.0.15.221"
        case .QA:
            return "162.241.71.136"
        case .DEVElOPMENT:
            return "162.241.71.136"
        }
    }
    
    @inline(never)
    private var baseWalletURL: String {
        switch currentEnvironment {
        case .PRODUCTION:
            return "65.0.15.221"
        case .QA:
            return "65.0.15.221"
        case .DEVElOPMENT:
            return "162.241.71.136"
        }
    }
    
    @inline(never)
    var baseImageURL: String {
        switch currentEnvironment {
        case .PRODUCTION:
            return "http://65.0.15.221:8002/media/uploads/"
        case .QA:
            return "http://162.241.71.136:7081/media/uploads/"
        case .DEVElOPMENT:
            return "http://162.241.71.136:7081/media/uploads/"
        }
    }
    
    @inline(never)
    private var defaultPort: Int {
        switch currentEnvironment {
        case .DEVElOPMENT:
            return 7081
        case .QA:
            return 8001
        case .PRODUCTION:
            return 8002
        }
    }
    
    @inline(never)
    private var walletPort: Int {
        switch currentEnvironment {
        case .DEVElOPMENT:
            return 7081
        case .QA:
            return 8001
        case .PRODUCTION:
            return 8001
        }    }
    
    @inline(never)
    var userURLConfiguration: URLConfiguration {
        return URLConfiguration(scheme: scheme, baseURL: baseURL, port: defaultPort)
    }
    
    @inline(never)
    var walletURLConfiguration: URLConfiguration {
        return URLConfiguration(scheme: scheme, baseURL: baseWalletURL, port: walletPort)
    }
    
    @inline(never)
    var imageConfiguration: URLConfiguration {
        return URLConfiguration(scheme: scheme, baseURL: baseImageURL, port: 0)
    }
    
    @inline(never)
    var uqudoBaseUrl: String {
        return "auth.uqudo.io"
    }
    
    @inline(never)
    var leanAppToken: String {
        return "fd3ff3a7-54a1-4c2f-a9eb-14e0c2ef9ca5"
    }
    
    @inline(never)
    var token: String? {
        return getVerifiedModel()?.verifiedModel?.accessToken
    }
    
    @inline(never)
    var ugudoAccessToken: String? {
        return KeychainWrapper.shared.getString(forKey: KeychainWrapper.Keys.ugudoAccessToken.rawValue)
    }
    
    @inline(never)
    var refreshToken: String? {
        return getVerifiedModel()?.verifiedModel?.refreshToken
    }
    
    // move this into Other Class
    func getVerifiedModel() -> OTPResponseModel? {
        if let data = KeychainWrapper.shared.getData(forKey: KeychainWrapper.Keys.tokenVerifiedModel.rawValue) {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(OTPResponseModel.self, from: data)
            } catch {
                Log.error(error.localizedDescription)
            }
        }
        return nil
    }
    
    // move this into Other Class
    func saveInKeyChain(model: Codable) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(model)
            let isSaved = KeychainWrapper.shared.save(jsonData, forKey: KeychainWrapper.Keys.tokenVerifiedModel.rawValue)
            print(isSaved)
            Log.info("Token saved successfully")
        } catch {
            Log.error(error.localizedDescription)
        }
    }
}
