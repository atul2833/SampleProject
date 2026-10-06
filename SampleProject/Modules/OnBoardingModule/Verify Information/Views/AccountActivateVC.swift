//
//  AccountActivateVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 05/01/24.
//

import UIKit

class AccountActivateVC: BaseNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
      navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func continueBtnAction(_ sender: ResponsiveButton) {
        let vc = SetSecurityVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
