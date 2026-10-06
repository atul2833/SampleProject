//
//  ProfileViewModel.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 13/01/24.
//

import Foundation
import UIKit
import Combine

protocol ProfileViewModelProtocol {
    var stateSubject: PassthroughSubject<ProfileViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
    func getUserContext() -> UserContext
}

struct UserProfileImageModel {
    var fileData: Data
    var name: String
    var fileName: String
    var mimeType: FileType = .jpeg
}

struct UserProfileMultipleImageModel {
    var fileDatas: [Data]
    var name: String
    var fileNames: [String]
    var mimeType: FileType = .jpeg
    var helpSubjectId:String
    var orderId:String
    var description:String
}

struct MessageMultipleImageModel {
    var fileDatas: [Data]
    var name: String
    var fileNames: [String]
    var mimeType: FileType = .jpeg
    var senderId:String
    var groupId:String
}


final class ProfileViewModel: ProfileViewModelProtocol {
    
    private let userContext: UserContext
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    
    
    enum State {
        case loading

        case success(message: String)
        case sendToVerify(type: String,phoneNumber: String,countryCode: String,emailAddress: String, countryId: String)
        case updateSuccess(message: String)
        case logout
        case error(message: String)
    }
    
    private var verifiedData: [KYCDetailList] = [KYCDetailList]()
    
    private var cellViewModels: [HomeTabItemCellViewModel] = [HomeTabItemCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    var sectionArr = [
        [
            (title: "Complete your KYC", description: "", image: "Group 72439",slug:"kyc", bottomLine: "0"),
            (title: "Account", description:"", image: "Group 72440",slug:"account", bottomLine: "0"),
            (title: "Contribution amount", description: "", image: "Group 72441",slug:"conti_amount", bottomLine: "0"),(title: "Block History", description: "", image: "blockIconHi",slug:"block_history", bottomLine: "0"),
            (title: "Rental Properties", description: "", image: "Group 72999",slug:"rental_property", bottomLine: "0")
        ],
        [
            (title: "Enable Notification", description: "You can turn on your notification alert so we can notify you.", image: "Group 72442",slug:"app_notification", bottomLine: "0"),
            (title: "Enable Biometric", description: "You can turn on your biometric so we can identify you.", image: "Group 87822",slug:"biometric", bottomLine: "1")
        ],
        [
            (title: "Help Center", description: "", image: "Group 72443",slug:"help", bottomLine: "0"),
            (title: "About TAG Credit", description: "", image: "Group 72445",slug:"about", bottomLine: "0"),
            (title: "Terms & Conditions", description: "", image: "Group 72446",slug:"terms", bottomLine: "0"),
            (title: "Privacy Policy", description: "", image: "Group 72444",slug:"privacy", bottomLine: "0")
        ]
                ]
    
    
    var reloadTableViewClosure: (()->())?
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?
    
    init(userContext: UserContext,
        httpClient: HttpClientProtocol = HttpClient()
    ) {
        self.httpClient = httpClient
        self.userContext = userContext
        self.observerProfileInfoChanges()
    }
    
    func observerProfileInfoChanges() {
        self.userContext.observeUserInformation()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                if let profile = info.profileModel {
                    //self?.stateSubject.send
                }
            }.store(in: &self.cancellable)
    }
    
    func getUserContext() -> UserContext {
        self.userContext
    }
}

extension ProfileViewModel {
    func updateProfileInfo(nickName: String) {
        Task{
            do {
                let dict = ["fullName": nickName]
                let response = try await self.httpClient.asyncRequest(
                    endpoint: ProfileSettingsEndPoint.updateProfile(dict: dict),
                    responseModel: ApiResponse.self
                )
                if response.status  {
                    guard var profileModel = self.userContext.getUserInformation().profileModel else { return }
                    profileModel.fullName = nickName
                    self.userContext.update{$0.updateProfileModel(profileModel)}
                    //                    self.getProfileInfo()
                    self.stateSubject.send(.updateSuccess(message: response.message))
                } else {
                    self.stateSubject.send(.error(message: response.message))
                }
                // update and handle the response model
            }  catch let error as ApiResponse {
                handleApiError(error)
            }
        }
    }
    
    func updateEmailOrPhone(type: String,phoneNumber: String,countryCode: String,emailAddress: String,countryId: String) {
        Task{
            do {
                let dict = ["type": type,"phoneNumber": phoneNumber,"countryCode": countryCode,"emailAddress": emailAddress,"countryId": countryId]
                let response = try await self.httpClient.asyncRequest(
                    endpoint: ProfileSettingsEndPoint.updateEmailOrPhone(dict: dict),
                    responseModel: ApiResponse.self
                )
                if response.status  {
//                    guard var profileModel = self.userContext.getUserInformation().profileModel else { return }
//                    profileModel.fullName = email
//                    self.userContext.update{$0.updateProfileModel(profileModel)}
                    //                    self.getProfileInfo()
                    self.stateSubject.send(.sendToVerify(type: type,phoneNumber: phoneNumber,countryCode: countryCode,emailAddress: emailAddress, countryId: countryId))
                } else {
                    self.stateSubject.send(.error(message: response.message))
                }
                // update and handle the response model
            }  catch let error as ApiResponse {
                handleApiError(error)
            }
        }
    }
    
    func updateNotificationSetting(isNotificationEnabled:Bool)  {
        Task{
            do {
                stateSubject.send(.loading)
                let response = try await self.httpClient.asyncRequest(
                    endpoint: ProfileSettingsEndPoint.updateSetting(isNotificationEnabled: isNotificationEnabled),
                    responseModel: ApiResponse.self
                )
                
                if response.status  {
                    self.stateSubject.send(.success(message: response.message))
                } else {
                    self.stateSubject.send(.error(message: response.message))
                }
                // update and handle the response model
            }  catch let error as ApiResponse {
                handleApiError(error)
            }
        }
    }
    
    func logoutAccount()  {
        Task{
            do {
                stateSubject.send(.loading)
                let response = try await self.httpClient.asyncRequest(
                    endpoint: ProfileSettingsEndPoint.logout,
                    responseModel: ApiResponse.self
                )
                
                if response.status  {
                    self.stateSubject.send(.logout)
                } else {
                    self.stateSubject.send(.error(message: response.message))
                }
                // update and handle the response model
            }  catch let error as ApiResponse {
                handleApiError(error)
            }
        }
    }
    
    func deleteAccount()  {
        Task{
            do {
                stateSubject.send(.loading)
                let response = try await self.httpClient.asyncRequest(
                    endpoint: ProfileSettingsEndPoint.deleteAccount,
                    responseModel: ApiResponse.self
                )
                
                if response.status  {
                    self.stateSubject.send(.logout)
                } else {
                    self.stateSubject.send(.error(message: response.message))
                }
                // update and handle the response model
            }  catch let error as ApiResponse {
                handleApiError(error)
            }
        }
    }
    
    func updateProfileImage(profileImage: Data, fileName: String) {
        let multipartRequest = UserProfileImageModel(fileData: profileImage, name: "image", fileName: fileName)
        
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: ProfileSettingsEndPoint.updateImageProfile(multipartRequest: multipartRequest),
                    responseModel: UpdateProfileImageResponseModel.self
                )
                
                if let status = response.status, status {
                    guard var profileModel = self.userContext.getUserInformation().profileModel else { return }
                    
                    if let imageURL = response.result?.profileImage {
                        profileModel.profileImage = imageURL
                        self.userContext.update { $0.updateProfileModel(profileModel) }
                    }
                    self.stateSubject.send(.success(message: response.message ?? ""))
                } else {
                    let errorMessage = response.message ?? "Unknown error occurred."
                    self.stateSubject.send(.error(message: errorMessage))
                }
            } catch let error as ApiResponse {
                handleApiError(error)
            } catch {
                // Handle other errors
                print("Unexpected error:", error)
            }
        }
    }
    
    
    private func handleApiError(_ error: ApiResponse) {
        if error.statusCode == 401 {
            stateSubject.send(.logout)
        } else {
            stateSubject.send(.error(message: error.message))
        }
    }
}
struct HomeTabItemCellViewModel {
    var transactionId : String
    var name : String
    var timeDate : String
    var type: String
    var status: String
    var amount: String
    var currency: String
}

