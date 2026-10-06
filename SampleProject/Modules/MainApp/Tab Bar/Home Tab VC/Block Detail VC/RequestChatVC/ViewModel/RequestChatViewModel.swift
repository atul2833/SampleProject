//
//  EnterAmountViewModel.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 11/01/24.
//

import Foundation
import Combine
import UIKit

protocol RequestChatViewModelProtocol {
    var stateSubject: PassthroughSubject<RequestChatViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}

final class RequestChatViewModel: RequestChatViewModelProtocol {
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    
    private var requestChatResponse: RequestChatResponsiveModel?
    private var blockMembersVotingResultResponse: [BlockMembersDataModel]?
    private var blockData: BlockDataModel?
    private var SwapRequestResponse: SwapRequestResponsiveModel?
    
    var blockId: String
    var memberId: String
    var blockType = String()
    var comingFrom = String()
    var isSwapRequest = Bool()

    enum State {
        case loading
        case success(groupId: String?)
        case leaveMemberDetails
        case logout
        case error(message: String)
    }
    
    init(blockId:String,comingFrom:String? = "",memberId: String,isSwapRequest: Bool,httpClient: HttpClientProtocol = HttpClient()) {
        self.blockId = blockId
        self.comingFrom = comingFrom ?? ""
        self.memberId = memberId
        self.isSwapRequest = isSwapRequest
        self.httpClient = httpClient
    }
    
    func getBlockData() -> BlockDataModel? {
        return blockData
    }
    
    func getNumberOfAmountList() -> Int? {
        self.requestChatResponse?.result?.amountList.count
    }
    
    func getNumberOfItemForAmount(At index: IndexPath) -> AmountList? {
        return self.requestChatResponse?.result?.amountList[index.row]
    }
    
    func getNumberOfItemForAmounts(At index: IndexPath) -> RequestChatDataModel? {
        return self.requestChatResponse?.result
    }
    
  


 
    func getRequestChat() {
        Task {
            do {
                
                let response = try await self.httpClient.asyncRequest(
                    endpoint: BlockEndPoints.leaveMemberDetails(blockId: blockId, memberId: memberId),
                    responseModel: RequestChatResponsiveModel.self
                )
                self.requestChatResponse = response
                
                stateSubject.send(.leaveMemberDetails)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
    
    func swapRequest() {
        Task {
            do {
                
                let response = try await self.httpClient.asyncRequest(
                    endpoint: BlockEndPoints.swapRequest(blockId: self.blockId, receiverId: memberId),
                    responseModel: SwapRequestResponsiveModel.self
                )
                self.SwapRequestResponse = response
                stateSubject.send(.success(groupId: response.result?.groupId))
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
