//
//  UpdateEmailVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 05/02/24.
//

import UIKit

class UpdateEmailVC: BaseNavigationController{
    
    @IBOutlet weak var txtName: UITextField!

    var comingFrom = String()
    var accountVC : AccountVC!
    var comingEmail = String()

    override func viewDidLoad(){
        super.viewDidLoad()
        
        txtName.text = comingEmail
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
                self.view.makeToast(Strings().email_toast)
            }
            else if !ValidationClass().isValidEmail(txtName.text ?? ""){
                self.view.makeToast(Strings().valid_email_toast)
            }
            else{
                if accountVC != nil{
                    self.dismiss(animated: false)
                    self.accountVC.updateEmail(email: txtName.text!)
                }
            }
        }
    }
}


