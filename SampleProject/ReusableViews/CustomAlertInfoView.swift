//
//  CustomAlertInfoView.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 05/02/24.
//

import UIKit

class CustomAlertInfoView: UIViewController {
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDescription:UILabel!
    @IBOutlet weak var imgView:UIImageView!

    var alertConfirm : AlertInfoDelegate!
    var comingTitle = String()
    var comingDescription = String()
    var comingImage = String()

    override func viewDidLoad(){
        super.viewDidLoad()
        initView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
   
    func initView(){
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
            
            if comingTitle == "Failed" {
                alertConfirm.alertInfoAction("Failed")
            }else{
                alertConfirm.alertInfoAction("Done")
            }
            self.dismiss(animated: false)
        }
    }
}
