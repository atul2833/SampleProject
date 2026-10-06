//
//  TransactionViewModel.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 08/01/24.
//

import Foundation
import Combine
import UIKit

protocol TransactionViewModelProtocol {
    var stateSubject: PassthroughSubject<TransactionViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}

final class TransactionViewModel: TransactionViewModelProtocol {
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    private var transactionResponse: TransactionResponseDataModel?
    private var transactionDetail: TransactionDetailDataModel?

    var type: String?
    private var transactionId : String?
    
    enum State {
        case loading
        case success
        case transactionListFetched
        case logout
        case error(message: String)
    }
    
    init(type:String? = "",transactionId:String? = "",httpClient: HttpClientProtocol = HttpClient()
    ) {
        self.type = type
        self.transactionId = transactionId
        self.httpClient = httpClient
    }
    
    func clearData(){
        self.transactionResponse?.transactionList = []
        self.transactionDetail = nil
    }
    
    func getTransactionDetailData()->TransactionDetailDataModel?{
        transactionDetail
    }
    
    func getNumberOfRows() -> Int {
        self.transactionResponse?.transactionList?.count ?? .zero
    }
    
    func getNumberOfItem(At index: IndexPath) -> TransactionDataModel? {
        return index.row < self.transactionResponse?.transactionList?.count ?? 0 ? self.transactionResponse?.transactionList?[index.row] : nil
    }
    
    func getNumberOfRowsDetail() -> Int {
        self.transactionDetail?.dataList?.count ?? .zero
    }
    
    func getNumberOfItemDetail(At index: IndexPath) -> TransactionDetailChildModel? {
        return self.transactionDetail?.dataList?[index.row]
    }
    func getTransectionAmount() -> Double {
        return self.transactionDetail?.amount ?? 0
    }
    func getTransactionList(page: String, limit: String, type: String, blockId: String,creditRequestId:String) {
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: TransactionsEndPoints.transactionList(dict: ["page": page, "limit": limit, "type": type, "blockId": blockId,"creditRequestId":creditRequestId]),
                    responseModel: TransactionResponseModel.self
                )
                self.transactionResponse = response.result
                
                stateSubject.send(.transactionListFetched)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }

    func getTransactionData() {
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: TransactionsEndPoints.transectionDetails(dict: ["transactionId":transactionId ?? ""]),
                    responseModel: TransactionDetailResponseModel.self
                )
                self.transactionDetail = response.result
                
                stateSubject.send(.transactionListFetched)
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
