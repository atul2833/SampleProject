//
//  WalkThroughViewModel.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 09/01/2024.
//

import Foundation
import Combine

protocol WalkThroughViewModelProtocol {
    var cancellable: Set<AnyCancellable>{ get set }
    var stateSubject: PassthroughSubject<WalkThroughViewModel.State, Never> { get set }
    func getNumberOfRows() -> Int
    func getNumberOfItem(At index: IndexPath) -> WalkThroughModel?
}

final class WalkThroughViewModel: WalkThroughViewModelProtocol {
    enum State {
        case reloadView
        case error(message: String)
    }
    
    private var httpClient: HttpClientProtocol
    private var walkThroughList: [WalkThroughModel]?
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()

    init(httpClient: HttpClientProtocol = HttpClient()) {
        self.httpClient = httpClient
        self.getWalkThroughList()
    }
    
    func getNumberOfRows() -> Int {
        self.walkThroughList?.count ?? .zero
    }
    
    func getNumberOfItem(At index: IndexPath) -> WalkThroughModel? {
        return self.walkThroughList?[index.row]
    }
    
    private func getWalkThroughList() {
        Task {
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: WalkThroughEndPoints.getWalkThrough,
                    responseModel: WalkThroughResponseModel.self
                )
                self.walkThroughList = response.walkThroughItems
                stateSubject.send(.reloadView)
            } catch let error as ApiResponse {
                stateSubject.send(.error(message: error.message))
            }
        }
    }
}
