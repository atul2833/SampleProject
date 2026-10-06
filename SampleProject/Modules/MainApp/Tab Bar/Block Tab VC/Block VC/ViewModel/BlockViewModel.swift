//
//  BlockViewModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 14/03/24.
//

import Foundation
import Combine
import UIKit

protocol BlockViewModelProtocol {
    var stateSubject: PassthroughSubject<BlockViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}

final class BlockViewModel: BlockViewModelProtocol {
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    private var blockList: [BlockDataModel]?
    private var createdBlockList: [BlockDataModel]?
    private var investedBlockList: [BlockDataModel]?
    private var blockResponseData: BlockResponseDataModel?
    var type: String?
    
    private var isFetching = false
    var paginationParams = BlockGetRequestParam()
    
    enum State {
        case loading
        case success
        case blockListFetched
        case logout
        case error(message: String)
    }
    
    init(type:String? = "",httpClient: HttpClientProtocol = HttpClient()
    ) {
        self.type = type
        self.httpClient = httpClient
    }
    
    func clearBlockData() {
        blockList = []
        blockList = nil
    }
    
    func getNumberOfRows() -> Int {
        self.blockList?.count ?? .zero
    }
    
    func getNumberOfCount() -> String {
        self.blockResponseData?.count ?? "0"
    }
        
    func getNumberOfItem(At index: IndexPath) -> BlockDataModel? {
        return self.blockList?[index.row]
    }
    
   
    
//    func getNumberOfRowsForCreatedBlocks() -> Int {
//        self.createdBlockList?.count ?? .zero
//    }
//    
//    func getNumberOfItemForCreatedBlocks(At index: IndexPath) -> BlockDataModel? {
//        return self.createdBlockList?[index.row]
//    }
//    
//    func getNumberOfRowsForInvestedBlocks() -> Int {
//        self.investedBlockList?.count ?? .zero
//    }
//    
//    func getNumberOfItemForInvestedBlocks(At index: IndexPath) -> BlockDataModel? {
//        return self.investedBlockList?[index.row]
//    }
    
//    func getNotificationList(page: Int) {
//        
//        guard !isFetching else { return } // Prevent multiple concurrent requests
//        
//        // Check if we've reached the end of available pages
//        guard paginationParams.totalPage == 0 || paginationParams.page <= paginationParams.totalPage else {
//            // If totalPage is known and current page exceeds it, no need to fetch
//            return
//        }
//        
//        if getNumberOfRows() == paginationParams.totalPage {
//            return
//        }
//        
//        isFetching = true
//        
//        let endpoint = NotificationEndPoints.notificationsList(.init(page: page,
//                                                                   limit: paginationParams.limit))
//        Task {
//            do {
//                stateSubject.send(.loading)
//
//                let response = try await self.httpClient.asyncRequest(
//                    endpoint: endpoint,
//                    responseModel: NotificationResponseModel.self
//                )
//                handleResponse(response)
//                self.paginationParams.page += 1
//                isFetching = false
//                stateSubject.send(.notificationListFetched)
//            } catch let error as ApiResponse {
//                stateSubject.send(.error(message: error.message))
//                isFetching = false
//
//            }
//        }
//    }
    
 
    
    
    
    func getBlockHistoryList() {

        guard !isFetching else { return } // Prevent multiple concurrent requests
        
        // Check if we've reached the end of available pages
        guard paginationParams.totalPage == 0 || paginationParams.page <= paginationParams.totalPage else {
            // If totalPage is known and current page exceeds it, no need to fetch
            return
        }
        
        isFetching = true
        
        let endpoint = BlockEndPoints.blockHistoryList(list: paginationParams)
        Task {
            do {
                stateSubject.send(.loading)

                let response = try await self.httpClient.asyncRequest(
                    endpoint: endpoint,
                    responseModel: BlockResponseModel.self
                )
                handleResponse(response)
                self.blockResponseData = response.result
                self.paginationParams.page += 1
                isFetching = false
                stateSubject.send(.blockListFetched)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
                isFetching = false

            }
        }
    }
    
    func getBlockList() {

        guard !isFetching else { return } // Prevent multiple concurrent requests
        
        // Check if we've reached the end of available pages
        guard paginationParams.totalPage == 0 || paginationParams.page <= paginationParams.totalPage else {
            // If totalPage is known and current page exceeds it, no need to fetch
            return
        }
        
        isFetching = true
        
        let endpoint = BlockEndPoints.blockList(list: paginationParams)
        Task {
            do {
                stateSubject.send(.loading)

                let response = try await self.httpClient.asyncRequest(
                    endpoint: endpoint,
                    responseModel: BlockResponseModel.self
                )
                handleResponse(response)
                self.blockResponseData = response.result
                self.paginationParams.page += 1
                isFetching = false
                stateSubject.send(.blockListFetched)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
                isFetching = false

            }
        }
    }
    
    private func handleResponse(_ response: BlockResponseModel) {
        guard let result = response.result else {
//            stateSubject.send(.error(message: "Response result is nil"))
            return
        }
        
        guard let blockList = result.blockList else {
//            stateSubject.send(.error(message: "propertyList list is nil"))
            return
        }
        
        // Append new propertyList to the existing list or create a new list if none exists.
        if self.blockList == nil {
            self.blockList = blockList
        } else {
            self.blockList?.append(contentsOf: blockList)
        }
        
        self.paginationParams.totalPage = result.totalPage ?? 1
        stateSubject.send(.blockListFetched)
    }
    

    private func handleApiError(_ error: ApiResponse) {
        if error.statusCode == 401,
           error.status == false {
            stateSubject.send(.logout)
        } else {
            stateSubject.send(.error(message: error.message))
        }
    }
}
