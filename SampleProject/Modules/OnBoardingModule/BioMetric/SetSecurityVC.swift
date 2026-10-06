//
//  ThumbVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit
import LocalAuthentication

class SetSecurityVC: BaseNavigationController {

    var isMovingFromParentToVC = true
    var commingFromOTP = true

    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var switch_is: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        if ((AppUserDefaults.shared.UDValue(.isBiometricEnable) as? String) != nil) {
            AppUserDefaults.shared.UDSave("no", forKey: .isBiometricEnable)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func continueAction(_ sender:UIButton) {       
        
        if sender.tag == 0{
            sendToNext(type: "no")
        }
        else{
            authenticateCheck()
        }
    }
    
    func sendToNext(type:String){
        let vc = HomeTabBarController(userContext: UserContext.create(with: UserInformation()))
        AppUserDefaults.shared.UDSave(true, forKey: .isLoggedIn)
        UIApplication.shared.windows.first?.rootViewController = vc
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    func authenticateCheck() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            print("Face Available")
            sendToNext(type: "yes")
        }
        else {
            checkWithPasscodeCheck()
            // Device doesn't support biometrics
        }
    }
    
    func checkWithPasscodeCheck() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Identify yourself!"
            sendToNext(type: "yes")

        } else{
            
            let ac = UIAlertController(title: "Biometry and Passcode unavailable", message: "Your device is not configured for biometry and Passcode authentication. Do you want to setup security?", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Yes", style: .default) { (_) in
                
                if let url1 = URL(string: "App-Prefs:root=TOUCHID_PASSCODE") {
                    guard let url = URL(string: "\(url1)"), !url.absoluteString.isEmpty else {
                          return
                       }
                    self.dismiss(animated: false, completion: nil)
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
            let action1 = UIAlertAction(title: "No", style: .cancel) { (_) in
                self.dismiss(animated: false, completion: nil)
            }
            ac.addAction(action)
            ac.addAction(action1)

            DispatchQueue.main.async {
                self.present(ac, animated: true)
            }
            // no biometry
        }
    }
}
