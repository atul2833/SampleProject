//
//  WalletViewModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 02/05/24.
//

import Foundation
import UIKit
import Combine

protocol WalletViewModelProtocol {
    var stateSubject: PassthroughSubject<WalletViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}

final class WalletViewModel:WalletViewModelProtocol {
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    
    private var walletBalanceData:WalletBalanceModel?
    private var walletResponse:[WalletBalanceResponseModel]?
    private var bankData:BankDataResponseModel?
     var paymentMethodData: [PaymentMethod]?

    enum State {
        case loading
        case success
        case paymentMethodFetched
        case addFund(transactionId:String?, url:String?)
        case logout
        case error(message: String)
    }
    
    init(httpClient: HttpClientProtocol = HttpClient()) {
        self.httpClient = httpClient
    }
    
    func getMyContributedMoney()->String?{
        "\(self.walletBalanceData?.totalContribution ?? 0.0)"
    }
    
    func getTotalCreditedAmount()->String?{
        "\(self.walletBalanceData?.totalCreditedAmount ?? 0.0)"
    }
    
    func getBankPaymentData() -> BankDataResponseModel? {
       bankData
    }
    
}

extension WalletViewModel {
    
    
    
    func checkPaymentStatusApi(transactionId:String) {
        Task{
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: HomeEndPoints.paymentStatus(transactionId: transactionId),
                    responseModel: PaymentMethodResponse.self
                )
                if response.status ?? false  {
                    
                    self.stateSubject.send(.success)
                } else {
                    self.stateSubject.send(.error(message: response.message ?? ""))
                }

            }  catch let error as ApiResponse {
                handleApiError(error)
            }
        }
    }
    
    
    func paymentMethodListApi() {
        Task{
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: HomeEndPoints.paymentMethodList,
                    responseModel: PaymentMethodResponse.self
                )
                if response.status ?? false  {
                    paymentMethodData = response.result
                    self.stateSubject.send(.success)
                } else {
                    self.stateSubject.send(.error(message: response.message ?? ""))
                }

            }  catch let error as ApiResponse {
                handleApiError(error)
            }
        }
    }
    
    
    func getWalletBalance() {
        Task{
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: HomeEndPoints.walletBalance,
                    responseModel: WalletBalanceResponseModel.self
                )
                if response.status ?? false  {
                    walletBalanceData = response.result
                    self.stateSubject.send(.success)
                } else {
                    self.stateSubject.send(.error(message: response.message ?? ""))
                }

            }  catch let error as ApiResponse {
                handleApiError(error)
            }
        }
    }
    
    func getPaymentMethod(type:String) {
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: HomeEndPoints.getPaymentMethod(type:type),
                    responseModel: FundTransferResponseModel.self
                )
                
                if response.status ?? false  {
                    self.bankData = response.result
                    self.stateSubject.send(.paymentMethodFetched)
                } else {
                    self.stateSubject.send(.error(message: response.message ?? ""))
                }
            } catch let error as ApiResponse {
                handleApiError(error)
            }
        }
    }
    
    
    func addFund(dict:[String:Any]) {
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: HomeEndPoints.addFund(dict: dict),
                    responseModel: PayPalRedirectResponse.self
                )
                
                if response.status ?? false  {
                    self.stateSubject.send(.addFund(transactionId: response.result?.transactionId, url: response.result?.redirectUrl))
                } else {
                    self.stateSubject.send(.error(message: response.message ?? ""))
                }
            } catch let error as ApiResponse {
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


