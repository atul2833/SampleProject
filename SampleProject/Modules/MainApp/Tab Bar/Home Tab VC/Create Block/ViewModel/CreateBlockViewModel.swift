//
//  CreateBlockViewModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 13/03/24.
//

import Foundation

import UIKit
import Combine

protocol CreateBlockViewModelProtocol {
    var stateSubject: PassthroughSubject<CreateBlockViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}


final class CreateBlockViewModel:CreateBlockViewModelProtocol {
    
    private let userContext: UserContext

    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    
    private var cityList : [HelpCenterModel]?
    private var depositRulesList : [HelpCenterModel]?
    private var durationList : [HelpCenterModel]?
     var blockSegemntList : [HelpCenterModel]?
    
    enum State {
        case loading
        case success(message: String,blockId:String)
        case listFetched

        case logout
        case error(message: String)
    }
    
    init(httpClient: HttpClientProtocol = HttpClient(),userContext: UserContext) {
        self.httpClient = httpClient
        self.userContext = userContext

    }
    
    func getUserContext() -> UserContext {
        self.userContext
    }
    
    func getCityList()->[HelpCenterModel]?{
        cityList
    }
    
    func getDepositRulesList()->[HelpCenterModel]?{
        depositRulesList
    }
    
    func getDurationList()->[HelpCenterModel]?{
        durationList
    }
}

extension CreateBlockViewModel {
   
    func dropDownListData(type:String)  {
        Task{
            do {
                stateSubject.send(.loading)
                
                let model = userContext.getUserInformation().profileModel
                
                let response = try await self.httpClient.asyncRequest(
                    endpoint: BlockEndPoints.dropDownListData(type: type, countryId: model?.countryId ?? "228"),
                    responseModel: HelpCenterResponseModel.self
                )
                
                if response.status ?? false {
                    if type == "city"{
                        self.cityList = response.result
                    }
                    else if type == "blockDuration"{
                        self.durationList = response.result
                    }
                    else if type == "blockDepositRule"{
                        self.depositRulesList = response.result
                    } else if type == "blockHistoryTypes" {
                        self.blockSegemntList = response.result
                    }
                    self.stateSubject.send(.listFetched)
                } else {
                    self.stateSubject.send(.error(message: response.message ?? ""))
                }
                // update and handle the response model
            }  catch let error as ApiResponse {
                handleApiError(error)
            }
        }
    }
    
    func createBlock(dict: [String:Any]) {
        Task{
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: BlockEndPoints.createBlocks(dict: dict),
                    responseModel: CreateBlockResponseModel.self
                )
                if response.status ?? false  {
                    self.stateSubject.send(.success(message: response.message ?? "", blockId: response.result?.blockId ?? ""))
                } else {
                    self.stateSubject.send(.error(message: response.message ?? ""))
                }
                // update and handle the response model
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


