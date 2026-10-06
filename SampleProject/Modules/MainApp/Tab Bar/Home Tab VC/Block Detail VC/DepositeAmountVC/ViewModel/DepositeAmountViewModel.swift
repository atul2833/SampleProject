//
//  EnterAmountViewModel.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 11/01/24.
//

import Foundation
import Combine
import UIKit

protocol DepositeAmountViewModelProtocol {
    var stateSubject: PassthroughSubject<DepositeAmountViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}

final class DepositeAmountViewModel: DepositeAmountViewModelProtocol {
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    
    private var depositeAmtResponse: [DepositeAmountDataModel]?
    private var blockData: BlockDataModel?
    
    var blockId: String
    var blockType = String()
    var comingFrom = String()
    var transactionId = String()

    enum State {
        case loading
        case success
        case detailsFetched
        case membersListFetched
        case requestJoinBlock
        case goForVote
        case leaveBlock(message:String)
        case payment(transactionId : String)
        case logout
        case error(message: String)
    }
    
    init(blockId:String,comingFrom:String? = "",transactionId:String,httpClient: HttpClientProtocol = HttpClient()) {
        self.blockId = blockId
        self.comingFrom = comingFrom ?? ""
        self.transactionId = transactionId
        self.httpClient = httpClient
    }
    
    func getBlockData() -> BlockDataModel? {
        return blockData
    }
    
    func getTransactionId() -> String {
        transactionId
    }
    
  
    
    func getNumberOfAmountList() -> Int? {
        self.depositeAmtResponse?.count
    }
    
    func getNumberOfItemForAmount(At index: IndexPath) -> DepositeAmountDataModel? {
        return self.depositeAmtResponse?[index.row]
    }
    
    func getBlockDetail() {
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: BlockEndPoints.blockDetails(blockId: blockId),
                    responseModel: BlockDetailResponseModel.self
                )
                self.blockData = response.result
                
                stateSubject.send(.detailsFetched)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }

 
    
   
    
    func goForPayment() {
        Task {
            do {
                
                let response = try await self.httpClient.asyncRequest(
                    endpoint: BlockEndPoints.payment(blockId: blockId),
                    responseModel: PaymentResponseModel.self
                )
               // self.blockMembersResponse = response
                
                stateSubject.send(.payment(transactionId: response.result?.transactionId ?? ""))
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
    
    func updateVotingResultSettings() {
        Task {
            do {
                
                let response = try await self.httpClient.asyncRequest(
                    endpoint: BlockEndPoints.updateVotingResultSettings(blockId: blockId),
                    responseModel: BlockMemberResponseModel.self
                )
               // self.blockMembersResponse = response
                
                stateSubject.send(.requestJoinBlock)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
    
    func depositDetails() {
        Task {
            do {
                
                let response = try await self.httpClient.asyncRequest(
                    endpoint: BlockEndPoints.depositDetails(blockId: blockId),
                    responseModel: DepositeAmountResponseModel.self
                )
                self.depositeAmtResponse = response.result
                
                stateSubject.send(.membersListFetched)
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
