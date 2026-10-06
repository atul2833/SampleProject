//
//  OTPCodeViewModel.swift
//  ComeraMoney
//
//  Created by NIKETAN SHARMA on 12/02/24.
//

import Foundation
import Combine

protocol OTPCodeViewModelProtocol {
    var stateSubject: PassthroughSubject<OTPCodeViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable>{ get set }
    func verifyNumberWith(OTP: String)
    func verifyNumberOrEmail(OTP: String,countryId: String)
    func resendOTP()
    func getTimeInSeconds() -> Int
}

final class OTPCodeViewModel: OTPCodeViewModelProtocol {
   
    private var userModel: UserRegisterRequestModel
    var entered_otp:String?
    var countryId:String?
    
    enum State {
        case loading
        case otpSent(message:String?)

        case success(model:VerifiedModel?)
        case error(message: String)
    }
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    
    init(httpClient: HttpClientProtocol = HttpClient(), userModel: UserRegisterRequestModel) {
        self.httpClient = httpClient
        self.userModel = userModel
    }
    
    func getTimeInSeconds() -> Int {
        120
    }
    
    func getComingType() -> String {
        userModel.comingFrom ?? ""
    }
    
    func verifyNumberWith(OTP: String) {
        Task {
            stateSubject.send(.loading)
            do {
                
                print("sendToVerify=====")
                print(countryId)
                let model = try await self.httpClient.asyncRequest(
                    endpoint: OnBoardingEndPoints.verify(
                        phoneNumber: userModel.phoneNumber,
                        emailAddress: userModel.emailAddress,
                        fullName: userModel.fullName,
                        otpCode: OTP,
                        cityId: userModel.cityId, 
                        countryId: userModel.countryId,
                        type: userModel.comingFrom
                    ),
                    responseModel: OTPResponseModel.self
                )
                if model.status ?? false {
                    ServerConfiguration.shared.saveInKeyChain(model: model)
                    stateSubject.send(.success(model: model.verifiedModel))
                } else {
                    stateSubject.send(.error(message: model.message ?? ""))
                }
                
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
    
    func verifyNumberOrEmail(OTP: String,countryId:String) {
        Task {
            stateSubject.send(.loading)
            do {
                
                print("sendToVerify1111111")
                print(countryId)
                let model = try await self.httpClient.asyncRequest(
                    endpoint: OnBoardingEndPoints.verifyNumberOrEmail(
                        phoneNumber: userModel.phoneNumber,
                        emailAddress: userModel.emailAddress,
                        otpCode: OTP,
                        type: userModel.comingFrom,
                        countryId: userModel.countryId
                    ),
                    responseModel: OTPResponseModel.self
                )
                if model.status ?? false {
                    ServerConfiguration.shared.saveInKeyChain(model: model)
                    stateSubject.send(.success(model: model.verifiedModel))
                } else {
                    stateSubject.send(.error(message: model.message ?? ""))
                }
                
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
    
    func resendOTP() {
        Task {
            stateSubject.send(.loading)
            do {
                let model = try await self.httpClient.asyncRequest(
                    endpoint: OnBoardingEndPoints.resend(
                        countryId: userModel.countryId,
                        phoneNumber: userModel.phoneNumber
                    ),
                    responseModel: OTPResendResponseModel.self
                )
                if model.status ?? false {
                    stateSubject.send(.otpSent(message: model.message))
                } else {
                    stateSubject.send(.error(message: model.message ?? ""))
                }
                
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
}
