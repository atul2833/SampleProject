//
//  BioMetricVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit
import LocalAuthentication

class BioMetricVC: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()

        authenticateTapped()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View Will Appear")
    }

    func authenticateTapped(){
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in

                DispatchQueue.main.async {
                    if success {
//                        timer?.invalidate()
//                        //set Timer Ex: 5 Second
//                        //Run timer on touch
//                        timer = Timer.scheduledTimer(timeInterval: 120, target: self!, selector: #selector(self!.update), userInfo: nil, repeats: false)
                        
                        NotificationCenter.default.post(name: Notification.Name("BioSuccess"), object: ["data":"success"])
                        print("Success")
                       // self?.unlockSecretMessage()
                    } else {
                        if authenticationError?.localizedDescription == "Authentication failure."{
                            
                            self!.checkWithPasscode()
                        }
                        else{
                            let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                            
                            let action = UIAlertAction(title: "OK", style: .default) { (_) in
                                //NotificationCenter.default.post(name: Notification.Name("BioSuccess"), object: ["data":"fail"])

                                self?.dismiss(animated: false, completion: nil)
                                
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: Notification.Name("BioSuccess"), object: ["data":"fail"])
                                }
                            }
                            ac.addAction(action)
                            self!.present(ac, animated: true)
                        }
                        
                        // error
                    }
                }
            }
        } else {
            
            self.checkWithPasscode()
            // no biometry
        }
    }
    
    func checkWithPasscode(){
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Identify yourself!"

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                [weak self] success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        NotificationCenter.default.post(name: Notification.Name("BioSuccess"), object: ["data":"success"])
                        print("Success")
                        print("Success")
                       // self?.unlockSecretMessage()
                    } else {
                        
                        let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default) { (_) in
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("BioSuccess"), object: ["data":"fail"])
                            }

                            self?.dismiss(animated: false, completion: nil)
                        }
                        ac.addAction(action)
                        self!.present(ac, animated: true)
                        // error
                    }
                }
            }
        } else {
            
            let ac = UIAlertController(title: "Biometry and Passcode unavailable", message: "Your device is not configured for biometry and Passcode authentication. Do you want to setup security?", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Yes", style: .default) { (_) in
                
              //  Utilities.shared.UDSave("no", forKey: .security_rejected)

                if let url1 = URL(string: "App-Prefs:root=TOUCHID_PASSCODE") {
                    guard let url = URL(string: "\(url1)"), !url.absoluteString.isEmpty else {
                          return
                       }
                    self.dismiss(animated: false, completion: nil)
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
            let action1 = UIAlertAction(title: "No", style: .cancel) { (_) in
                NotificationCenter.default.post(name: Notification.Name("BioSuccess"), object: ["data":"no"])
               // Utilities.shared.UDSave("yes", forKey: .security_rejected)
              //  Utilities.shared.UDSave("no", forKey: .security)

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


