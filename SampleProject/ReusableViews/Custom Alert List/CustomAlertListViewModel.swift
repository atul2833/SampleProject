//
//  CustomAlertListViewModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 25/06/24.
//

import Foundation
import Combine
import UIKit

protocol CustomAlertListViewModelProtocol {
    var stateSubject: PassthroughSubject<CustomAlertListViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}

final class CustomAlertListViewModel: CustomAlertListViewModelProtocol {
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    private var customAlertData: CustomAlertListResponseDataModel?

    var type: String?
    var isTermsSelected = false

    enum State {
        case loading
        case success
        case logout
        case error(message: String)
    }
    
    init(type:String?,httpClient: HttpClientProtocol = HttpClient()
    ) {
        self.type = type
        self.httpClient = httpClient
    }
    
    func getListData()->CustomAlertListResponseDataModel?{
        customAlertData
    }
    
    func getCustomAlertListData(type:String) {
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: CustomAlertListEndPoints.rulesAndConditions(type: type),
                    responseModel: CustomAlertListResponseModel.self
                )
                self.customAlertData = response.result
                
                stateSubject.send(.success)
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
