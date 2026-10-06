//
//  UpdataNameViewModel.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 16/01/24.
//

import Foundation

class UpdataNameViewModel {
            
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    var showAlertClosure: (()->())?
    var updateSuccessStatus: (()->())?
    var updateLoadingStatus: (()->())?

    func callDeleteDataAPI(){
     
    
    }
    
}
