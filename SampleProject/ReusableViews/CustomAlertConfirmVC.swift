//
//  VerifyPINVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 11/01/24.
//

import UIKit

protocol AlertConfimDelegate {
    func alertAction(_ status:String)
}

protocol AlertInfoDelegate {
    func alertInfoAction(_ status:String)
}

class CustomAlertConfirmVC: BaseNavigationController{
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDescription:UILabel!
    @IBOutlet weak var imgView:UIImageView!

    @IBOutlet weak var cancelBtn: ResponsiveButton!
    @IBOutlet weak var yesBtn: ResponsiveButton!
    var alertConfirm : AlertConfimDelegate!
    var comingTitle = String()
    var comingDescription = String()
    var comingImage = String()
    var yesBtnTitle = String()
    override func viewDidLoad(){
        super.viewDidLoad()
        initView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
   
    func initView(){
        
        if yesBtnTitle.count != 0{
            yesBtn.setTitle(yesBtnTitle, for: .normal)
        }else{
            yesBtn.setTitle("Yes", for: .normal)
        }
        lblTitle.text = comingTitle
        lblDescription.text = comingDescription
        imgView.image = UIImage(named: comingImage)
    }
    
    @IBAction func continueAction(_ sender:UIButton) {
        
        self.view.endEditing(true)
        
        if sender.tag == 0{
            self.dismiss(animated: false)
        }
        else{     
            alertConfirm.alertAction(comingTitle)
            self.dismiss(animated: false)
        }
    }
}

