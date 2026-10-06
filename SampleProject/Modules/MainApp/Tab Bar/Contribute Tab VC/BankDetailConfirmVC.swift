//
//  BankDetailConfirmVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 06/02/24.
//

import UIKit

class BankDetailConfirmVC: BaseNavigationController {

    var bankVC:AddBankAccountVC!
    var payment:PaymentVC!
    var commingFrom = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueAction(_ sender:UIButton) {
        
        self.view.endEditing(true)
        
        if sender.tag == 0{
            self.dismiss(animated: false)
        }
        else{
            
            if commingFrom == "PaymentVC"{
                payment.confimDetails()
            }else{
                bankVC.confim()
            }
            
          //  alertConfirm.alertAction("Done")
            self.dismiss(animated: false)
        }
    }
}
