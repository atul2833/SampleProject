//
//  VerifyIdentityViewModel.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 17/01/2024.
//

import Foundation
import Combine

struct KycSaveDataModel {
    var fileDatas: [Data]
    var name: String
    var fileNames: [String]
    var mimeType: FileType = .jpeg
    var nationalIdentityTypeId:String
    var nationalIdentityNumber:String
}
protocol VerifyIdentityViewModelProtocol {
    var stateSubject: PassthroughSubject<VerifyIdentityViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable>{ get set }
    func getUserKycInfo()
    func getNumberOfRows() -> Int
    func getItem(At indexPath: IndexPath) -> InformationModel?
}

class VerifyIdentityViewModel: VerifyIdentityViewModelProtocol {
    enum State {
        case loading
        case successList
        case success
        case kycConfirmSuccess(message: String)
        case logout
        case error(message: String)
    }

    private var httpClient: HttpClientProtocol
    
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    
    private var InformationModel: [InformationModel] = []
    var kycDocModel: KYCDocumentList?

    init(
        httpClient: HttpClientProtocol = HttpClient()
    ) {
        self.httpClient = httpClient
    }
    
    func getNumberOfRows() -> Int {
        self.InformationModel.count
    }
    
    func getItem(At indexPath: IndexPath) -> InformationModel? {
        self.InformationModel[indexPath.row]
    }
    
    
    func getUserKycInfo() {
        Task {
            do {
                stateSubject.send(.loading)
                let response = try await httpClient.asyncRequest(endpoint: OnBoardingEndPoints.userKycInfo, responseModel: IdentityInformationResponseModel.self)
                if response.status ?? false {
                    self.InformationModel = response.result ?? []
                    stateSubject.send(.successList)
                } else {
                    stateSubject.send(.error(message: response.message ?? ""))
                }
            } catch let error as ApiResponse {
                if error.statusCode == 401 {
                    stateSubject.send(.logout)
                } else {
                    stateSubject.send(.error(message: error.message))
                }
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func saveKyc(imageDatas: [Data], fileNames: [String],nationalIdentityTypeId:String,nationalIdentityNumber:String) {
        self.stateSubject.send(.loading)
        let multipartRequest = KycSaveDataModel(fileDatas: imageDatas, name: "nationalIdentityFrontImage", fileNames: fileNames,nationalIdentityTypeId: nationalIdentityTypeId,nationalIdentityNumber: nationalIdentityNumber)
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: OnBoardingEndPoints.saveKycDocument(multipartRequest: multipartRequest),
                    responseModel: KycUpdateResponseModel.self
                )
                
                if let status = response.status, status {
                    self.stateSubject.send(.kycConfirmSuccess(message: response.message ?? ""))
                } else {
                    let errorMessage = response.message ?? "Unknown error occurred."
                    self.stateSubject.send(.error(message: errorMessage))
                }
            } catch let error as ApiResponse {
//                handleApiError(error)
            } catch {
                // Handle other errors
                print("Unexpected error:", error)
            }
        }
    }
    
    func kycDocumentType(page:Int,limit:Int) {
        Task {
            stateSubject.send(.loading)
            do {
                let model = try await self.httpClient.asyncRequest(
                    endpoint: OnBoardingEndPoints.userKycDocumentTypes(page: page, limit: limit),
                    responseModel: KYCResponseModel.self
                )
                if model.status ?? false {
                    self.kycDocModel = model.result
                    stateSubject.send(.success)
                } else {
                    stateSubject.send(.error(message: model.message ?? ""))
                }
                
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
}
