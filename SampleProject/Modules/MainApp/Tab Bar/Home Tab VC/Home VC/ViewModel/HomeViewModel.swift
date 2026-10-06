//
//  HomeViewModel.swift
//  ComeraMoney
//
//  Created by NIKETAN SHARMA on 12/02/24.
//

import Foundation
import Combine
import UIKit

protocol HomeViewModelProtocol {
    var stateSubject: PassthroughSubject<HomeViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
    func getUserContext() -> UserContext
    func getNumberOfRowsForBlocks() -> Int
    func getNumberOfItemForBlocks(At index: IndexPath) -> BlockDataModel?
}


final class HomeViewModel: HomeViewModelProtocol {
    
    private let userContext: UserContext
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    private var blockList: [BlockDataModel]?

    var delegate: HomeViewModelProtocol?

    enum State {
        case loading
        case showMessage(message:String?,emailMessage:String?)
        case profileLoaded(model: ProfileInfoModel)

        case success
        case blockListFetched
        case logout
        case error(message: String)
    }
    
    init(userContext: UserContext,
        delegate: HomeViewModelProtocol?,
        httpClient: HttpClientProtocol = HttpClient()
    ) {
        self.httpClient = httpClient
        self.delegate = delegate
        self.userContext = userContext
        self.observerProfileInfoChanges()
    }
    
    func observerProfileInfoChanges() {
        self.userContext.observeUserInformation()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                if let profile = info.profileModel {
                    self?.stateSubject.send(.success)
                }
            }.store(in: &self.cancellable)
    }
    
    func getUserContext() -> UserContext {
        self.userContext
    }
    
    func getNumberOfRowsForBlocks() -> Int {
        self.blockList?.count ?? .zero
    }
    
    func getNumberOfItemForBlocks(At index: IndexPath) -> BlockDataModel? {
        return self.blockList?[index.row]
    }
    

//    func getBlockList(dict:[String:Any]) {
//        Task {
//            do {
//                let response = try await self.httpClient.asyncRequest(
//                    endpoint: HomeEndPoints.blockList(dict: dict),
//                    responseModel: BlockResponseModel.self
//                )
//                self.blockList = response.result?.blockList
//                stateSubject.send(.blockListFetched)
//            } catch let error as ApiResponse {
//                stateSubject.send(.error(message: error.message))
//            }
//        }
//    }
    
    func getProfileInfo()  {
        Task{
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: HomeEndPoints.getProfile,
                    responseModel: ProfileInfoResponseModel.self
                )
                if response.status ?? false,
                   let user = response.user {
                    self.userContext.update { $0.updateProfileModel(user) }
                    self.stateSubject.send(.profileLoaded(model: user))
                }
            }  catch let error as ApiResponse {
                handleApiError(error)
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
