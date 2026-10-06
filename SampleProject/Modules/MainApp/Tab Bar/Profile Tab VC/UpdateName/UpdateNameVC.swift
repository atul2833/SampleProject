//
//  VerifyPINVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 11/01/24.
//

import UIKit

class UpdateNameVC: BaseNavigationController{
    
    @IBOutlet weak var txtName: UITextField!

    var comingFrom = String()
    var comingName = String()

    var editProfileVC : EditProfileVC!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        txtName.delegate = self
        txtName.text = comingName
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
   
    @IBAction func continueAction(_ sender:UIButton) {
        
        self.view.endEditing(true)
       
        if sender.tag == 0{
            self.dismiss(animated: false)
        }
        else{
            if ValidationClass().isBlank(txtName){
                self.view.makeToast("Please enter name!")
            }
            else{
                if editProfileVC != nil{
                    self.dismiss(animated: false)
                    self.editProfileVC.updatedName(name: txtName.text!)
                }
            }
        }
    }
}


extension UpdateNameVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           // Check if the new text length will exceed 6 characters
           let currentText = textField.text ?? ""
           let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
           
           return newText.count <= 20 // Allow editing only if the new length is less than or equal to 6
       }
}
