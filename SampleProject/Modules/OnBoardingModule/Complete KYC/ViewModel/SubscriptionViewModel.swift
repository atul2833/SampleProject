//
//  SubscriptionViewModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 12/03/24.
//

import Foundation
import Combine

protocol SubscriptionViewModelProtocol {
    var stateSubject: PassthroughSubject<SubscriptionViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable>{ get set }
    func getPlans()
    func getNumberOfRows() -> Int
    func getItem(At indexPath: IndexPath) -> SubscriptionInfoModel?
    func getNumberOfRowsForDescription() -> Int
    func getItemForDescription(At indexPath: IndexPath) -> String?
    func updatePlan(planId:String)
}

class SubscriptionViewModel: SubscriptionViewModelProtocol {
    enum State {
        case loading
        case successList
        case success
        case kycConfirmSuccess
        case logout
        case error(message: String)
    }

    private var httpClient: HttpClientProtocol
    
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    
    var subscriptionModel: [SubscriptionInfoModel] = []
    var descriptionList: [String?] = []


    init(
        httpClient: HttpClientProtocol = HttpClient()
    ) {
        self.httpClient = httpClient
    }
    
    func getNumberOfRows() -> Int {
        self.subscriptionModel.count
    }
    
    func getItem(At indexPath: IndexPath) -> SubscriptionInfoModel? {
        self.subscriptionModel[indexPath.row]
    }
    
    func getNumberOfRowsForDescription() -> Int {
        self.descriptionList.count
    }
    
    func getItemForDescription(At indexPath: IndexPath) -> String? {
        self.descriptionList[indexPath.row]
    }
    
    func getPlans() {
        Task {
            do {
                stateSubject.send(.loading)
                let response = try await httpClient.asyncRequest(endpoint: OnBoardingEndPoints.plans, responseModel: SubscriptionResponseModel.self)
                if response.status ?? false {
                    self.subscriptionModel = response.result ?? []
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
    
    func updatePlan(planId:String) {
        Task {
            stateSubject.send(.loading)
            do {
                let model = try await self.httpClient.asyncRequest(
                    endpoint: OnBoardingEndPoints.updatePlan(planId: planId),
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
}
