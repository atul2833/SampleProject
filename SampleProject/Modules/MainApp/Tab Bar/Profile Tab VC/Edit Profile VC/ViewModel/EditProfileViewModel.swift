//
//  AccountInfoViewModel.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 14/01/24.
//

import Foundation
import UIKit

class EditProfileViewModel {
       
   // var userData = UserDataManager.userData

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
    var updateSuccessStatus: ((String)->())?
    var updateLoadingStatus: (()->())?

    func updateName(name:String){
         isLoading = true
      
    }
        
    func updateImage(selectedImage:UIImage?){
       
        let imageDataProfile  = selectedImage?.jpegData(compressionQuality: 0.5)
        
        isLoading = true

    }
}

