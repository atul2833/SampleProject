//
//  PaymentVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 06/02/24.
//

import UIKit

class PaymentVC: BaseNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Payment"
        // Do any additional setup after loading the view.
    }
    func confimDetails(){
        let vc = TransactionDetailVC(viewModel: TransactionViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func addBtnAction(_ sender:ResponsiveButton){
        let vc = AddBankAccountVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func acceptBtnAction(_ sender: ResponsiveButton) {
//        viewModel.isTermsSelected = !viewModel.isTermsSelected
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func addBankBtnPressed(_ sender: ResponsiveButton) {
        
        let vc = BankDetailConfirmVC()
        vc.payment = self
        vc.commingFrom = "PaymentVC"
        self.presentOnViewController(with: vc)
    }
    
}
