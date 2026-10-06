//
//  JoinBlockViewModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 14/03/24.
//

import Foundation
import UIKit
import Combine

protocol JoinBlockViewModelProtocol {
    var stateSubject: PassthroughSubject<JoinBlockViewModel.State, Never> { get set }
    var cancellable: Set<AnyCancellable> { get set }
}


final class JoinBlockViewModel:JoinBlockViewModelProtocol {
    
    private var httpClient: HttpClientProtocol
    var stateSubject = PassthroughSubject<State, Never>()
    var cancellable = Set<AnyCancellable>()
    
    var blockId :String
    var password :String
    
    enum State {
        case loading
        case success(message: String)
        case listFetched

        case logout
        case error(message: String)
    }
    
    init(blockId:String,password:String,httpClient: HttpClientProtocol = HttpClient()) {
        self.httpClient = httpClient
        self.blockId = blockId
        self.password = password
    }

}

extension JoinBlockViewModel {
   
    func joinBlock(dict: [String:Any]) {
        Task{
            do {
                let response = try await self.httpClient.asyncRequest(
                    endpoint: BlockEndPoints.joinBlock(dict: dict),
                    responseModel: ApiResponse.self
                )
                if response.status  {
                    self.stateSubject.send(.success(message: response.message))
                } else {
                    self.stateSubject.send(.error(message: response.message))
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

