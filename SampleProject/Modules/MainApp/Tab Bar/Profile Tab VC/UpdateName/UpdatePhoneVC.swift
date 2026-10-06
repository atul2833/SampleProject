//
//  UpdatePhoneVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 05/02/24.
//

import UIKit

class UpdatePhoneVC:  BaseNavigationController{
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var countryCodeBtn: UIButton!
    @IBOutlet weak var countryImage: UIImageView!
    
    var comingFrom = String()
    var accountVC : AccountVC!
    var countryCode: String? = "+1"
    var countryId: String? = "228"

    var phoneNumber = String()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        txtName.text = phoneNumber
    
        let countryManager = CountryManager.shared
        let country = countryManager.getCountryByCountryId(forCode: countryId ?? "")//getCountryByCode(forCode: countryCode ?? "")
        let country1 = CountryManager.shared.getCountryByCode(
            forCode: countryCode ?? ""
        )

        let countryShortName = country1.countryShortName ?? ""
     
        countryCode = country.countryCode
        countryCodeBtn.setTitle(country.countryCode, for: .normal)
        countryImage.image = UIImage(named:countryShortName.lowercased())
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
                self.view.makeToast(Strings().phone_toast)
            }
            else if txtName.text!.count <= 5 || txtName.text!.count >= 15 {
                self.view.makeToast(Strings().valid_phone_toast)
            }
            else{
                if accountVC != nil{
                    self.dismiss(animated: false)
                    print("updatePhone======")
                    print(countryId)
                    self.accountVC.updatePhone(countryCode: countryCode ?? "+1", phone: txtName.text ?? "", countryId: countryId ?? "228")
                }
            }
        }
    }
    
    @IBAction func countryAction(_ sender: UIButton) {
        let countryVC = CountryCodeVC()
            countryVC.delegate = self
       //  let navctrl = UINavigationController(rootViewController: countryVC)
            
        self.present(countryVC, animated: true, completion: nil)
    }
}

extension UpdatePhoneVC:CountryDelegate{
    func didCountryClicked(_ country: Country) {
        countryCode = country.countryCode
        countryCodeBtn.setTitle(country.countryCode!, for: .normal)
        countryImage.image = UIImage(named:country.countryShortName!.lowercased())
//        countryTxt.text = country.countryName!
    }
}
