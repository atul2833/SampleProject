//
//  ScanFaceVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 02/02/24.
//

import UIKit

class ScanFaceVC: BaseNavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Scan Your Face"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func scanBtnAction(_ sender:UIButton){
            let vc = SubscriptionVC(viewModel: SubscriptionViewModel())
            self.navigationController?.pushViewController(vc, animated: true)
    }

}
