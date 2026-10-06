//
//  NotificationViewModel.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 17/01/24.
//

import Foundation
import Combine
import UIKit

protocol NotificationViewModelProtocol {
    var stateSubject: PassthroughSubject<NotificationViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}

final class NotificationViewModel: NotificationViewModelProtocol {
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    private var notifications: NotificaitonResponseDataModel?
    var type: String?
    
    private var reasonList : [HelpCenterModel]?
    private var isFetching = false
    var paginationParams = NotificationGetRequestParam()

    enum State {
        case loading
        case success
        case acceptReject
        case notificationListFetched
        case logout
        case error(message: String)
    }
    
    init(type:String? = "",httpClient: HttpClientProtocol = HttpClient()
    ) {
        self.type = type
        self.httpClient = httpClient
    }
    
    func clearData() {
        self.notifications?.notificationList = []
        self.notifications = nil
    }
    
    func getReasonList() -> [HelpCenterModel]? {
        self.reasonList
    }
    
    func getNumberOfRows() -> Int {
        self.notifications?.notificationList?.count ?? .zero
    }
    
    func getNumberOfItem(At index: IndexPath) -> NotificationDataModel? {
        return self.notifications?.notificationList?[index.row]
    }
    
    func getNotificationList(page: Int) {
        
        guard !isFetching else { return } // Prevent multiple concurrent requests
        
        // Check if we've reached the end of available pages
//        guard paginationParams.totalPage == 0 || paginationParams.page <= paginationParams.totalPage else {
//            // If totalPage is known and current page exceeds it, no need to fetch
//            return
//        }
        
//        if getNumberOfRows() == paginationParams.totalPage {
//            return
//        }
        
        isFetching = true
        
        let endpoint = NotificationEndPoints.notificationsList(.init(page: page,
                                                                   limit: paginationParams.limit))
        Task {
            do {
                stateSubject.send(.loading)

                let response = try await self.httpClient.asyncRequest(
                    endpoint: endpoint,
                    responseModel: NotificationResponseModel.self
                )
                handleResponse(response)
                self.paginationParams.page += 1
                isFetching = false
                stateSubject.send(.notificationListFetched)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
                isFetching = false

            }
        }
    }
    
    private func handleResponse(_ response: NotificationResponseModel) {
        guard let result = response.result else {
//            stateSubject.send(.error(message: "Response result is nil"))
            return
        }
        
        guard let notifications = result.notificationList else {
//            stateSubject.send(.error(message: "Notifications list is nil"))
            return
        }
        
        // Append new notifications to the existing list or create a new list if none exists.
        if self.notifications == nil {
            self.notifications = result
        } else {
            self.notifications?.notificationList?.append(contentsOf: notifications)
        }
        
        self.paginationParams.totalPage = result.totalPage
        stateSubject.send(.success)
    }

    func getReasonListData() {
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: NotificationEndPoints.rejectReasonList(type: "block"),
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
                stateSubject.send(.acceptReject)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
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
