//
//  MessageViewModel.swift
//  TAGCreditMerchant
//
//  Created by NIKETAN SHARMA on 25/04/24.
//

import Foundation
import Combine
import UIKit

protocol MessageViewModelProtocol {
    var stateSubject: PassthroughSubject<MessageViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}

final class MessageViewModel: MessageViewModelProtocol {
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    private var messages: MessageResponseDataModel?
    private var type: String?
    
    private var reasonList : [HelpCenterModel]?
    private var isFetching = false
    var paginationParams = MessageGetRequestParam()

    enum State {
        case loading
        case success
        case messageListFetched
        case sendImage
        case logout
        case error(message: String)
    }
    
    init(httpClient: HttpClientProtocol = HttpClient()
    ) {
        self.httpClient = httpClient
    }
    
    func clearData() {
        self.messages?.messageList = []
        self.messages = nil
    }
    
    func getReasonList() -> [HelpCenterModel]? {
        self.reasonList
    }
    
    func getNumberOfRows() -> Int {
        self.messages?.messageList?.count ?? .zero
    }
    
    func getNumberOfItem(At index: IndexPath) -> MessageResponseSubDataModel? {
        return self.messages?.messageList?[index.row]
    }
    
    func getMessageList(page: Int) {
        
        guard !isFetching else { return } // Prevent multiple concurrent requests
        
        // Check if we've reached the end of available pages
        guard paginationParams.totalPage == 0 || paginationParams.page <= paginationParams.totalPage else {
            // If totalPage is known and current page exceeds it, no need to fetch
            return
        }
        
        if getNumberOfRows() == paginationParams.totalPage {
            return
        }
        
        isFetching = true
        
        let endpoint = MessageEndPoints.messageList(.init(page: page,
                                                                   limit: paginationParams.limit))
        Task {
            do {
                stateSubject.send(.loading)

                let response = try await self.httpClient.asyncRequest(
                    endpoint: endpoint,
                    responseModel: MessageResponseModel.self
                )
                handleResponse(response)
                self.paginationParams.page += 1
                isFetching = false
                stateSubject.send(.messageListFetched)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
                isFetching = false

            }
        }
    }
    
    private func handleResponse(_ response: MessageResponseModel) {
        guard let result = response.result else {
//            stateSubject.send(.error(message: "Response result is nil"))
            return
        }
        
        guard let notifications = result.messageList else {
//            stateSubject.send(.error(message: "Notifications list is nil"))
            return
        }
        
        // Append new notifications to the existing list or create a new list if none exists.
        if self.messages == nil {
            self.messages = result
        } else {
            self.messages?.messageList?.append(contentsOf: notifications)
        }
        
        self.paginationParams.totalPage = result.totalPage ?? 1
        stateSubject.send(.success)
    }

    func getReasonListData(type: String) {
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: NotificationEndPoints.rejectReasonList(type: type),
                    responseModel: HelpCenterResponseModel.self
                )
                self.reasonList = response.result
                
                stateSubject.send(.success)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
    
    func acceptRejectRequest(dict:[String:Any]) {
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: NotificationEndPoints.acceptRejectRequest(dict: dict),
                    responseModel: HelpCenterResponseModel.self
                )
                stateSubject.send(.success)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
    
    func uploadChatImage(imageDatas: [Data], fileNames: [String],senderId:String,groupId:String) {
        let multipartRequest = MessageMultipleImageModel(fileDatas: imageDatas, name: "images", fileNames: fileNames, senderId: senderId, groupId: groupId)

        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: MessageEndPoints.uploadChatImage(multipartRequest: multipartRequest),
                    responseModel: UpdateProfileImageResponseModel.self
                )
                
                if let status = response.status, status {
                    self.stateSubject.send(.sendImage)
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
        if error.statusCode == 401,
           error.status == false {
            stateSubject.send(.logout)
        } else {
            stateSubject.send(.error(message: error.message))
        }
    }
}
