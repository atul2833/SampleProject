//
//  ProfileViewModel.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 13/01/24.
//


import Foundation
import UIKit
import Combine

protocol RentalViewModelProtocol {
    var stateSubject: PassthroughSubject<RentalViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}

struct RentalPropertyMultipleImageModel{
    var fileDatas: [Data]
    var name: String
    var fileNames: [String]
    var mimeType: FileType = .jpeg
    var mimeTypes: [FileType] = [.jpeg,.jpeg]

    var title:String
    var propertyAreaSqt:String
    var bedRooms:String
    var bathRooms:String
    var price:String
    var rentTypeId:String
    var city:String
    var description:String
    var specifications: [String]
    var phoneNumber:String
    var propertyAddress:[String:String]
    var propertyId:String
    var countryId:String
}

final class RentalViewModel:RentalViewModelProtocol {
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    
    var subjectList : [HelpCenterModel]?
    
    var paginationParams = RentalPropertiesGetRequestParam()
    private var propertyList: RentalPropertiesDataModel?
    private var propertyDetails: PropertyDataModel?

    private var isFetching = false

    enum State {
        case loading
        case success(message: String)
        case listFetched
        case removeImage
        case request(groupId:String)

        case logout
        case error(message: String)
    }
    
    var countryId:String? = ""
    
    init(httpClient: HttpClientProtocol = HttpClient()) {
        self.httpClient = httpClient
    }
}

extension RentalViewModel{
    
    func clearRenatalData() {
        propertyList?.propertyList = []
        propertyList = nil
    }
    
    
    func getPropertyDetails()->PropertyDataModel?{
        propertyDetails
    }
    
    func setPropertyDetails(index:Int){
        propertyDetails?.propertyMediaList?.remove(at: index)
    }
    
    func getNumberOfRows() -> Int {
        self.propertyList?.propertyList?.count ?? .zero
    }
    
    func getNumberOfItem(At index: IndexPath) -> PropertyDataModel? {
        return self.propertyList?.propertyList?[index.row]
    }
    
}

extension RentalViewModel {
    
    func removeImageOrVideo(mediaId:String)  {
        Task{
            do {
                stateSubject.send(.loading)
                let response = try await self.httpClient.asyncRequest(
                    endpoint: RentalPropertiesEndPoint.removeImageOrVideo(mediaId: mediaId),
                    responseModel: ApiResponse.self
                )
                
                if response.status  {
                    self.stateSubject.send(.removeImage)
                } else {
                    self.stateSubject.send(.error(message: response.message))
                }
                // update and handle the response model
            }  catch let error as ApiResponse {
                handleApiError(error)
            }
        }
    }
    
    func deleteProperty(propertyId:String)  {
        Task{
            do {
                stateSubject.send(.loading)
                let response = try await self.httpClient.asyncRequest(
                    endpoint: RentalPropertiesEndPoint.deleteProperty(propertyId: propertyId),
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
    
    func rentPropertyRequest(propertyId:String)  {
        Task{
            do {
                stateSubject.send(.loading)
                let response = try await self.httpClient.asyncRequest(
                    endpoint: RentalPropertiesEndPoint.rentPropertyRequest(propertyId: propertyId),
                    responseModel: SwapRequestResponsiveModel.self
                )
              
                if response.status ?? false  {
                    self.stateSubject.send(.request(groupId: response.result?.groupId ?? ""))
                } else {
                    self.stateSubject.send(.error(message: response.message ?? ""))
                }
                // update and handle the response model
            }  catch let error as ApiResponse {
                handleApiError(error)
            }
        }
    }
    
    func getPropertyDetailsData(propertyId:String) {
        
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: RentalPropertiesEndPoint.propertyDetails(propertyId:propertyId),
                    responseModel: RentalPropertiesDetailResponseModel.self
                )
                if let status = response.status, status {
                    self.propertyDetails = response.result
                    self.stateSubject.send(.listFetched)
                } else {
                    let errorMessage = response.message ?? "Unknown error occurred."
                    self.stateSubject.send(.error(message: errorMessage))
                }
            } catch let error as ApiResponse {
                self.handleApiError(error)
            }
        }
    }
    
    func leaveProperty(propertyId:String) {
        
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: RentalPropertiesEndPoint.leaveProperty(propertyId:propertyId),
                    responseModel: RentalPropertiesDetailResponseModel.self
                )
                if let status = response.status, status {
                    self.propertyDetails = response.result
                    self.stateSubject.send(.listFetched)
                } else {
                    let errorMessage = response.message ?? "Unknown error occurred."
                    self.stateSubject.send(.error(message: errorMessage))
                }
            } catch let error as ApiResponse {
                self.handleApiError(error)
            }
        }
    }
    
    func extendProperty(propertyId:String) {
        
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: RentalPropertiesEndPoint.extendProperty(propertyId:propertyId),
                    responseModel: RentalPropertiesDetailResponseModel.self
                )
                if let status = response.status, status {
                    self.propertyDetails = response.result
                    self.stateSubject.send(.listFetched)
                } else {
                    let errorMessage = response.message ?? "Unknown error occurred."
                    self.stateSubject.send(.error(message: errorMessage))
                }
            } catch let error as ApiResponse {
                self.handleApiError(error)
            }
        }
    }
    
    func getRentPropertyHistoryList() {
        
        guard !isFetching else { return } // Prevent multiple concurrent requests
        
        // Check if we've reached the end of available pages
        guard paginationParams.totalPage == 0 || paginationParams.page <= paginationParams.totalPage else {
            // If totalPage is known and current page exceeds it, no need to fetch
            return
        }
        
        isFetching = true
        
        let endpoint = RentalPropertiesEndPoint.rentHistoryPropertyList(paginationParams)
        Task {
            do {
                stateSubject.send(.loading)

                let response = try await self.httpClient.asyncRequest(
                    endpoint: endpoint,
                    responseModel: RentalPropertiesResponseModel.self
                )
                handleResponse(response)
                self.paginationParams.page += 1
                isFetching = false
                stateSubject.send(.listFetched)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
                isFetching = false

            }
        }
    }
    
    func getPropertyList() {
        
        guard !isFetching else { return } // Prevent multiple concurrent requests
        
        // Check if we've reached the end of available pages
        guard paginationParams.totalPage == 0 || paginationParams.page <= paginationParams.totalPage else {
            // If totalPage is known and current page exceeds it, no need to fetch
            return
        }
        
        isFetching = true
        
        let endpoint = RentalPropertiesEndPoint.propertyList(paginationParams)
        Task {
            do {
                stateSubject.send(.loading)

                let response = try await self.httpClient.asyncRequest(
                    endpoint: endpoint,
                    responseModel: RentalPropertiesResponseModel.self
                )
                handleResponse(response)
                self.paginationParams.page += 1
                isFetching = false
                stateSubject.send(.listFetched)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
                isFetching = false

            }
        }
    }
    
    private func handleResponse(_ response: RentalPropertiesResponseModel) {
        guard let result = response.result else {
//            stateSubject.send(.error(message: "Response result is nil"))
            return
        }
        
        guard let propertyList = result.propertyList else {
//            stateSubject.send(.error(message: "propertyList list is nil"))
            return
        }
        
        // Append new propertyList to the existing list or create a new list if none exists.
        if self.propertyList == nil {
            self.propertyList = result
        } else {
            self.propertyList?.propertyList?.append(contentsOf: propertyList)
        }
        
        self.paginationParams.totalPage = result.totalPage
        stateSubject.send(.listFetched)
    }
    
    func addProperty(imageDatas: [Data], fileNames: [String], mimeTypes: [FileType], title:String,propertyAreaSqt:String,bedRooms:String,bathRooms:String,price:String,rentTypeId:String,city:String,description:String,specifications: [String],phoneNumber:String,propertyAddress:[String:String], propertyId:String,countryId:String) {
        
        let multipartRequest = RentalPropertyMultipleImageModel(fileDatas: imageDatas, name: "imagesAndVideos", fileNames: fileNames,mimeTypes: mimeTypes, title:title,propertyAreaSqt:propertyAreaSqt,bedRooms:bedRooms,bathRooms:bathRooms,price:price,rentTypeId:rentTypeId,city:city,description:description,specifications: specifications,phoneNumber:phoneNumber,propertyAddress:propertyAddress, propertyId:propertyId, countryId: countryId)
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: RentalPropertiesEndPoint.addProperty(multipartRequest: multipartRequest),
                    responseModel: ResponseSuccessModel.self
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



