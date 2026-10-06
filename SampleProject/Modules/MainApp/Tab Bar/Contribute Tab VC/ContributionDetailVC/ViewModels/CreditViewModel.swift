//
//  MyContributionViewModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 27/03/24.
//

import Foundation
import Combine
import UIKit

protocol CreditViewModelProtocol {
    var stateSubject: PassthroughSubject<CreditViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}

final class CreditViewModel: CreditViewModelProtocol {
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    private var creditResponse: CreditResponseDataModel?
    private var creditData: CreditResponseSubDataModel?

    
    enum State {
        case loading
        case success
        case listFetched
        case creditData

        case logout
        case error(message: String)
    }
    
    init(httpClient: HttpClientProtocol = HttpClient()
    ) {
        self.httpClient = httpClient
    }
    
    func getCreditCount() -> String {
        self.creditResponse?.count ?? ""
    }
    
    func getCreditData()->CreditResponseSubDataModel?{
        creditData
    }
    
    func getNumberOfRows() -> Int {
        self.creditResponse?.creditList?.count ?? .zero
    }
    
    func getNumberOfItem(At index: IndexPath) -> CreditResponseSubDataModel? {
        return self.creditResponse?.creditList?[index.row]
    }
        
    func merchantBlockLoanList(page: String, limit: String) {
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: CreditEndPoints.merchantBlockLoanList(page: page, limit: limit),
                    responseModel: CreditResponseModel.self
                )
                self.creditResponse = response.result
                
                stateSubject.send(.listFetched)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
    
    func merchantLoanDetails(creditRequestId: String) {
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: CreditEndPoints.merchantLoanDetails(creditRequestId: creditRequestId),
                    responseModel: CreditDetailResponseModel.self
                )
                self.creditData = response.result
                
                stateSubject.send(.creditData)
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
