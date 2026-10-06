//
//  TopStoriesListViewModel.swift
//  CodingTest
//
//  Created by faizal on 07/10/18.
//  Copyright © 2018 test. All rights reserved.
//


import Foundation
import UIKit
import Combine

struct UserRegisterRequestModel {
    var phoneNumber: String?
    var emailAddress : String?
    var fullName : String?
    var cityId:String?
    var countryId:String?
    var comingFrom: String?

}

protocol RegisterViewModelProtocol {
    var stateSubject: PassthroughSubject<RegisterViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable>{ get set }
    func signUpUserData(phoneNumber:String,emailAddress:String,fullName:String,cityId:String,countryId:String)
    func loginUser(phoneNumber:String)
}

final class RegisterViewModel: RegisterViewModelProtocol {
    
    var isTermsSelected = false
    var countryId:String? = "37"

    enum State {
        case loading
        case otpSent(message:String?)
        case success
        case listFetched
        case error(message: String)
    }
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    
    private var cityList : [HelpCenterModel]?

    init(httpClient: HttpClientProtocol = HttpClient()) {
        self.httpClient = httpClient
    }
    
    
    var sectionArr = [
       
            (title: "Terms & Conditions", description: "", image: "Group 72446",slug:"terms", bottomLine: "0"),
            (title: "Privacy Policy", description: "", image: "Group 72444",slug:"privacy", bottomLine: "0")
        
                ]
    
    func getCityList()->[HelpCenterModel]?{
        cityList
    }
    
    func signUpUserData(phoneNumber:String,emailAddress:String,fullName:String,cityId:String,countryId:String) {
        Task {
            stateSubject.send(.loading)
            do {
                let model = try await self.httpClient.asyncRequest(
                    endpoint: OnBoardingEndPoints.signup(phoneNumber:phoneNumber, emailAddress: emailAddress, fullName: fullName, cityId: cityId, countryId: countryId),
                    responseModel: ResponseSuccessModel.self
                )
                if model.status ?? false {
                    stateSubject.send(.success)
                } else {
                    stateSubject.send(.error(message: model.message ?? ""))
                }
                
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
    
    func loginUser(phoneNumber:String) {
        Task {
            stateSubject.send(.loading)
            do {
                let model = try await self.httpClient.asyncRequest(
                    endpoint: OnBoardingEndPoints.login(countryId: countryId, phoneNumber: phoneNumber),
                    responseModel: ResponseSuccessModel.self
                )
                if model.status ?? false {
                    stateSubject.send(.success)
                } else {
                    stateSubject.send(.error(message: model.message ?? ""))
                }
                
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
    
    func dropDownListData(countryId:String)  {
        Task{
            do {
               // stateSubject.send(.loading)
                let response = try await self.httpClient.asyncRequest(
                    endpoint: BlockEndPoints.dropDownListData(type: "city", countryId: countryId),
                    responseModel: HelpCenterResponseModel.self
                )
                
                if response.status ?? false {
                    self.cityList = response.result
                   
                    self.stateSubject.send(.listFetched)
                } else {
                    self.stateSubject.send(.error(message: response.message ?? ""))
                }
                // update and handle the response model
            }  catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
}
