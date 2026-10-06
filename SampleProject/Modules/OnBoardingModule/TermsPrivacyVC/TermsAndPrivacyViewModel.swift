//
//  TermsAndPrivacyViewModel.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 05/01/24.
//

import Foundation
import UIKit

class TermsAndPrivacyViewModel {
    
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
    
    var dataDescription: String? {
        didSet {
            self.showDataDescription?()
        }
    }
    
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?
    var showDataDescription: (()->())?

    func getPagesData(comingFrom:String){
  
        isLoading = true
        
       
    }
    
}


