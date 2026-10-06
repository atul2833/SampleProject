//
//  MyContributionViewModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 27/03/24.
//

import Foundation
import Combine
import UIKit

protocol ContributionViewModelProtocol {
    var stateSubject: PassthroughSubject<ContributionViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}

final class ContributionViewModel: ContributionViewModelProtocol {
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    private var contributionResponse: ContributionResponseDataModel?
    private var contributionDetailResponse: ContributionDetailResponseDataModel?

    private var blockId: String?

    enum State {
        case loading
        case success
        case listFetched
        case logout
        case error(message: String)
    }
    
    init(blockId:String? = "",httpClient: HttpClientProtocol = HttpClient()
    ) {
        self.blockId = blockId
        self.httpClient = httpClient
    }
    
    func clearData(){
        self.contributionResponse?.contributionList = []
        self.contributionResponse = nil
    }
    func getMyContributedMoney() -> String {
       "0" //"\(self.myContributionResponse?.totalContribution ?? 0.0)"
    }
    
  
        
    func getContributionData() -> ContributionDetailDataModel? {
        self.contributionDetailResponse?.contributionData
    }
    
    func getNumberOfRows() -> Int {
        self.contributionResponse?.contributionList?.count ?? .zero
    }
    
    func getNumberOfItem(At index: IndexPath) -> ContributionResponseInnerDataModel? {
        return self.contributionResponse?.contributionList?[index.row]
    }
    
    func getNumberOfRowsDetail() -> Int {
        self.contributionDetailResponse?.blockLoansList?.count ?? .zero
    }
    
    func getNumberOfItemDetail(At index: IndexPath) -> BlockLoansListModel? {
        return self.contributionDetailResponse?.blockLoansList?[index.row]
    }
        
    func getMyContributionList(page: String, limit: String) {
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: ContributionEndPoints.userContributionList(page: page, limit: limit),
                    responseModel: ContributionResponseModel.self
                )
                self.contributionResponse = response.result
                
                stateSubject.send(.listFetched)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
 
    func blockLoansList(page: String, limit: String) {
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: ContributionEndPoints.blockLoansList(page: page, limit: limit,blockId:blockId ?? "" ),
                    responseModel: ContributionDetailResponseModel.self
                )
                self.contributionDetailResponse = response.result
                
                stateSubject.send(.listFetched)
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
