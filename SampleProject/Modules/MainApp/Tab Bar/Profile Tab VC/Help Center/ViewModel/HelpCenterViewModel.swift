//
//  HelpCenterViewModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 13/03/24.
//

import Foundation
import UIKit
import Combine

protocol HelpCenterViewModelProtocol {
    var stateSubject: PassthroughSubject<HelpCenterViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}


final class HelpCenterViewModel:HelpCenterViewModelProtocol {
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    var subjectList : [HelpCenterModel]?
    enum State {
        case loading
        case success(message: String)
        case listFetched

        case logout
        case error(message: String)
    }
    
    private var userId:String?
    init(httpClient: HttpClientProtocol = HttpClient(),userId:String?) {
        self.httpClient = httpClient
        self.userId = userId
    }
    
    func getUserId()->String{
        return userId ?? ""
    }
}

extension HelpCenterViewModel {
   
    func helpSubjectList()  {
        Task{
            do {
                stateSubject.send(.loading)
                let response = try await self.httpClient.asyncRequest(
                    endpoint: ProfileSettingsEndPoint.helpSubjectList,
                    responseModel: HelpCenterResponseModel.self
                )
                
                if response.status ?? false {
                    self.subjectList = response.result
                    self.stateSubject.send(.listFetched)
                } else {
                    self.stateSubject.send(.error(message: response.message ?? ""))
                }
                // update and handle the response model
            }  catch let error as ApiResponse {
                handleApiError(error)
            }
        }
    }
    
    func updateImages(imageDatas: [Data], fileNames: [String],helpSubjectId:String,orderId:String,description:String) {
        self.stateSubject.send(.loading)
        let multipartRequest = UserProfileMultipleImageModel(fileDatas: imageDatas, name: "image", fileNames: fileNames,helpSubjectId: helpSubjectId, orderId: orderId,description: description)
        
        print(multipartRequest)
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: ProfileSettingsEndPoint.helpRequest(multipartRequest: multipartRequest),
                    responseModel: HelpCentreImageResponseModel.self
                )
                
                if let status = response.status, status {
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


