//
//  AddBankAccountVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 06/02/24.
//

import UIKit

struct SelectionData: Decodable {
    let id: Int
    let name: String
    let status: String
}

struct SelectedBankData:Decodable{
    
    let fee: String
    let speed: String
    let banks: [SelectionData]
}
class AddBankAccountVC: BaseNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Bank Account"
    }
    
    func confim(){
        let vc = TransactionDetailVC(viewModel: TransactionViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func bankListBtnAction(_ sender:ResponsiveButton){
        let vc = SelectionDataVC()
            vc.comingFrom = "supportedBank"
            vc.delegate = self
        self.present(vc, animated: true)
    }
        
    @IBAction func addBtnAction(_ sender:ResponsiveButton){
        
        let vc = BankDetailConfirmVC()
            vc.bankVC = self
        self.presentOnViewController(with: vc)
    }
    
    @IBAction func acceptBtnAction(_ sender: ResponsiveButton) {
//        viewModel.isTermsSelected = !viewModel.isTermsSelected
        sender.isSelected = !sender.isSelected
    }
}

extension AddBankAccountVC:SelectionDataProtocol{
    func selectedIndexData(_ comingFrom: String, _ data: SelectionData) {
//        lblOccupation.text = data.name
//        selectedOccupation = data
    }

    
}
