//
//  MyContactsViewModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 01/04/24.
//

import Foundation
import UIKit
import Combine

protocol MyContactsViewModelProtocol {
    var stateSubject: PassthroughSubject<MyContactsViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}


struct ContactsGetRequestParam: Encodable {
    var page: Int  // Use Int to represent numeric values
    var limit: Int // Ditto
    var totalPage: Int
    
    // Initialize with default values if needed
    init(page: Int = 1, limit: Int = 50, totalPage: Int = 1) {
        self.page = page
        self.limit = limit
        self.totalPage = totalPage
    }
}


final class MyContactsViewModel:MyContactsViewModelProtocol {
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    
    private var isFetching = false
    var paginationParams = ContactsGetRequestParam()
    private var blockId : String?

    private var myContactsResponse:[MyContactsDataModel]?
    
    enum State {
        case loading
        case success(message: String)
        case listFetched

        case logout
        case error(message: String)
    }
    
    init(httpClient: HttpClientProtocol = HttpClient(),blockId:String?) {
        self.httpClient = httpClient
        self.blockId = blockId
    }
    
    func getBlockId()->String?{
        blockId
    }
    
    func clearContactsData(){
        self.myContactsResponse = []
        self.myContactsResponse = nil
    }
    
    func setIsFetching(){
       isFetching = false
    }
    
    func getSelectedUsers()->[String]?{
        myContactsResponse?.filter { $0.isSelected == true }.compactMap { $0.userId }
    }
    
    func getNumberOfRows() -> Int {
        self.myContactsResponse?.count ?? .zero
    }
    
    func setSelectedValue(At index: IndexPath){
        self.myContactsResponse![index.row].isSelected = self.myContactsResponse?[index.row].isSelected != nil ? !(self.myContactsResponse![index.row].isSelected!) : true
        
    }
    
    func getNumberOfItem(At index: IndexPath) -> MyContactsDataModel? {
        return (index.row < myContactsResponse?.count ?? 0) ? self.myContactsResponse?[index.row] : nil
    }
}

extension MyContactsViewModel {
    
    func getInvitationContacts(page:Int,list: [Any],isLoading:Bool) {

        guard !isFetching else { return } // Prevent multiple concurrent requests
        
        // Check if we've reached the end of available pages
        guard paginationParams.totalPage == 0 || paginationParams.page <= paginationParams.totalPage else {
            // If totalPage is known and current page exceeds it, no need to fetch
            return
        }
        
//        if getNumberOfRows() == paginationParams.totalPage {
//            return
//        }
        
        isFetching = true
        
        let endpoint = MyContactsEndPoints.getInvitationContacts(dict: ["blockId":blockId!,"contactsList":list])
        Task {
            do {
                if isLoading{
                    stateSubject.send(.loading)
                }

                let response = try await self.httpClient.asyncRequest(
                    endpoint: endpoint,
                    responseModel: MyContactsResponseModel.self
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
    
    private func handleResponse(_ response: MyContactsResponseModel) {
        guard let result = response.result else {
//            stateSubject.send(.error(message: "Response result is nil"))
            return
        }
        
       
       
        // Append new notifications to the existing list or create a new list if none exists.
        
        
        if var result = response.result {
            // Iterate through the result array and set isSelected to false for each entry
            for index in 0..<result.count {
                result[index].isSelected = false
            }
            if self.myContactsResponse == nil {
                self.myContactsResponse = result
            } else {
                self.myContactsResponse?.append(contentsOf: result)
            }
        }
        
        stateSubject.send(.listFetched)
    }
    
    func sendInvitation(selectedUserIds:[String]?) {
        
        Task{
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: MyContactsEndPoints.sendInvitation(dict: ["blockId":blockId ?? "","receiverIds":selectedUserIds ?? []]),
                    responseModel: ApiResponse.self
                )
                if response.status  {
                    self.stateSubject.send(.success(message: response.message ))
                } else {
                    self.stateSubject.send(.error(message: response.message ))
                }
                // update and handle the response model
            }  catch let error as ApiResponse {
                handleApiError(error)
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


