//
//  EnterAmountViewModel.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 11/01/24.
//

import Foundation
import Combine
import UIKit

protocol BlockDetailViewModelProtocol {
    var stateSubject: PassthroughSubject<BlockDetailViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}

final class BlockDetailViewModel: BlockDetailViewModelProtocol {
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    
    private var blockData: BlockDataModel?
    private var blockMembersResponse: BlockMemberResponseModel?
    private var blockMembersResponseManager: BlockMemberResponseModel?
    private var blockMembersResponseAsstManager: BlockMemberResponseModel?
    private var blockMembersVotingResultResponse: [BlockMembersDataModel]?
    private var PaymentResponse: PaymentResponseModel?
 

    var blockId: String
    var blockType = String()
    var comingFrom = String()
 

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
    
    init(blockId:String,comingFrom:String? = "",httpClient: HttpClientProtocol = HttpClient()) {
        self.blockId = blockId
        self.comingFrom = comingFrom ?? ""
        self.httpClient = httpClient
    }
    
    func getBlockData() -> BlockDataModel? {
        return blockData
    }
    
    
    func getMemberId(At index: IndexPath) -> BlockMembersDataModel? {
        return blockMembersVotingResultResponse?[index.row]
    }
    
    func getMemberCount() -> String? {
        return self.blockMembersResponse?.result?.count
    }
    
    func getMemberExpirtTime() -> String? {
        return self.blockMembersResponse?.result?.expireTime
    }

    func getPollIdManager() -> String? {
        return self.blockMembersResponseManager?.result?.pollId
    }
    
    func getNumberOfRowsForBlockMembers() -> Int {
        self.blockMembersResponse?.result?.memberList?.count ?? .zero
    }
    
    func getNumberOfItemForBlockMembers(At index: IndexPath) -> BlockMembersDataModel? {
        return self.blockMembersResponse?.result?.memberList?[index.row]
    }
    
    func getMemberCountMananger() -> String? {
        return self.blockMembersResponseManager?.result?.count
    }
    
    func getMemberExpirtTimeManager() -> String? {
        return self.blockMembersResponseManager?.result?.expireTime
    }

    func getPollIdAsstManager() -> String? {
        return self.blockMembersResponseAsstManager?.result?.pollId
    }
    
    func getNumberOfRowsForBlockMembersManager() -> Int {
        self.blockMembersResponseManager?.result?.memberList?.count ?? .zero
    }
    
    func getNumberOfItemForBlockMembersManager(At index: IndexPath) -> BlockMembersDataModel? {
        return self.blockMembersResponseManager?.result?.memberList?[index.row]
    }
    
    func getMemberCountAsstManager() -> String? {
        return self.blockMembersResponseAsstManager?.result?.count
    }

    func getMemberExpirtTimeAsstManager() -> String? {
        return self.blockMembersResponseAsstManager?.result?.expireTime
    }
    
    func getNumberOfRowsForBlockMembersAsstManager() -> Int {
        self.blockMembersResponseAsstManager?.result?.memberList?.count ?? .zero
    }
    
    func getNumberOfItemForBlockMembersAsstManager(At index: IndexPath) -> BlockMembersDataModel? {
        return self.blockMembersResponseAsstManager?.result?.memberList?[index.row]
    }
    
    func getNumberOfRowsForVotingResult() -> Int {
        self.blockMembersVotingResultResponse?.count ?? .zero
    }
    
    func getNumberOfItemForVotingResult(At index: IndexPath) -> BlockMembersDataModel? {
        return self.blockMembersVotingResultResponse?[index.row]
    }
    
     
    func getNumberOfTransactionId() -> String? {
        return self.PaymentResponse?.result?.transactionId
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

    func getBlockMembersList(dict:[String:String]) {
        Task {
            do {
                var newDict = dict
                newDict["blockId"] = blockId
                let response = try await self.httpClient.asyncRequest(
                    endpoint: BlockEndPoints.blockMembersList(dict: newDict),
                    responseModel: BlockMemberResponseModel.self
                )
                if dict["type"]! == ""{
                    self.blockMembersResponse = response
                }
                else if dict["type"]! == "blockManager"{
                    self.blockMembersResponseManager = response
                }
                else if dict["type"]! == "assistantManager"{
                    self.blockMembersResponseAsstManager = response
                }
                
                stateSubject.send(.membersListFetched)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
    
    func getVotersList(dict:[String:Any]) {
        Task {
            do {
                var newDict = dict
                let response = try await self.httpClient.asyncRequest(
                    endpoint: BlockEndPoints.voterList(dict: newDict),
                    responseModel: BlockMemberResponseModel.self
                )
                self.blockMembersResponse = response
                
                stateSubject.send(.membersListFetched)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
    
    func requestJoinBlock() {
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: BlockEndPoints.requestJoinBlock(blockId: blockId),
                    responseModel: BlockMemberResponseModel.self
                )
               // self.blockMembersResponse = response
                
                stateSubject.send(.requestJoinBlock)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
    
    func goForVote(dict:[String:Any]) {
        Task {
            do {
                
                var newDict = dict
                newDict["blockId"] = blockId
                let response = try await self.httpClient.asyncRequest(
                    endpoint: BlockEndPoints.vote(dict: newDict),
                    responseModel: BlockMemberResponseModel.self
                )
               // self.blockMembersResponse = response
                
                stateSubject.send(.goForVote)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
    
    func leaveBlock(dict:[String:Any]) {
        Task {
            do {
                
                var newDict = dict
                newDict["blockId"] = blockId
                let response = try await self.httpClient.asyncRequest(
                    endpoint: BlockEndPoints.leaveBlock(dict: newDict),
                    responseModel: ApiResponse.self
                )
               // self.blockMembersResponse = response
                
                stateSubject.send(.leaveBlock(message: response.message))
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
   
    func getVotingResult() {
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: BlockEndPoints.voteResult(blockId: blockId),
                    responseModel: BlockMemberVotingResponseModel.self
                )
                self.blockMembersVotingResultResponse = response.result
                
                stateSubject.send(.membersListFetched)
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
                self.PaymentResponse = response
                
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
    
//    func depositDetails() {
//        Task {
//            do {
//                
//                let response = try await self.httpClient.asyncRequest(
//                    endpoint: BlockEndPoints.depositDetails(blockId: blockId),
//                    responseModel: DepositeAmountResponseModel.self
//                )
//                self.depositeAmtResponse = response.result
//                
//                stateSubject.send(.membersListFetched)
//            } catch let error as ApiResponse {
//                stateSubject.send(.error(message: error.message))
//            }
//        }
//    }
    
    private func handleApiError(_ error: ApiResponse) {
        if error.statusCode == 401,
           error.status == false {
            stateSubject.send(.logout)
        } else {
            stateSubject.send(.error(message: error.message))
        }
    }
}
