//
//  NextPaymentViewModel.swift
//  TAGCreditMerchant
//
//  Created by NIKETAN SHARMA on 08/05/24.
//

import Foundation
import UIKit
import Combine

protocol  CreditDetailsViewModelProtocol {
    var stateSubject: PassthroughSubject< CreditDetailsViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}

final class CreditDetailsViewModel: CreditDetailsViewModelProtocol {
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    
    private var nextPaymentList:NextPaymentResponsDataModel?
    
    enum State {
        case loading
        case success
        case emiPayment(transactionId:String)
        case logout
        case error(message: String)
    }
    
    init(httpClient: HttpClientProtocol = HttpClient()) {
        self.httpClient = httpClient
    }
    
    func getNumberOfRows() -> Int {
        self.nextPaymentList?.emiList?.count ?? .zero
    }
    
    func getNumberOfItem(At index: IndexPath) -> NextPaymentDataModel? {
        return self.nextPaymentList?.emiList?[index.row]
    }
}

extension CreditDetailsViewModel {
    
    func emiList() {
        Task{
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: CreditDetailsEndPoints.emiList,
                    responseModel: NextPaymentResponseModel.self
                )
                
                if response.status ?? false  {
                    nextPaymentList = response.result
                    self.stateSubject.send(.success)
                } 
                else {
                    self.stateSubject.send(.error(message: response.message ?? ""))
                }

            }  catch let error as ApiResponse {
                handleApiError(error)
            }
        }
    }
    
    func emiPayment(emiId:String) {
        Task{
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: CreditDetailsEndPoints.emiPayment(dict:["emiId":emiId]),
                    responseModel: PaymentResponseModel.self
                )
                
                if response.status ?? false  {
                    self.stateSubject.send(.emiPayment(transactionId: response.result?.transactionId ?? ""))
                }
                else {
                    self.stateSubject.send(.error(message: response.message ?? "" ))
                }

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


