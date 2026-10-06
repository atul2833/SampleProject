//
//  BaseSlideViewController.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit

class BaseNavigationController: UIViewController{
    
    /** Variable Intailization **/
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    let label = UILabel()
    var isBackToPreviousScreen: Bool = false
    var isBackToPreviousScreenFromOTP: Bool = false
    var languageSignDataArr = ["ckb-IQ","ar-IQ","en"]
    var languageDataArr = [String]()

    /** View Controllers Life Cycle Methods **/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
          self.navigationController?.navigationBar.tintColor = .white
          self.navigationController?.navigationBar.barTintColor =  UIColor.white
    //
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:AppFont.semi(.title),NSAttributedString.Key.foregroundColor: UIColor.appBase]
    //
               // self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    //
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
                self.navigationController?.navigationBar.shadowImage = UIImage()
                self.navigationController?.navigationBar.isTranslucent = true
                self.navigationController?.view.backgroundColor = UIColor.white
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

       //   self.navigationController?.navigationBar.setGradientBackground(colors: [.appBaseStartColor, .appBaseEndColor], startPoint: .topLeft, endPoint: .bottomRight)

        
          let menuBtn = ResponsiveButton(frame: CGRect(x: -10, y: 0,width: 40,height: 40))
          menuBtn.setImage(UIImage(named: "Group 72229"), for: .normal)
          menuBtn.addTarget(self, action: #selector(backBtnAction(_:)), for: .touchUpInside)
      
      
          self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuBtn)
    }

    @objc func backBtnAction(_ sender:ResponsiveButton){
        let loginVal = AppUserDefaults.shared.UDValue(.isLoggedIn) as? Bool
        
        if (self.navigationController?.viewControllers.first(where: { $0 is TermsAndPrivacyVC })) != nil {
            self.navigationController?.popViewController(animated: true)
        }
        else if isBackToPreviousScreen {
            isBackToPreviousScreen = false
            self.navigationController?.popToRootViewController(animated: true)
        }else if isBackToPreviousScreenFromOTP {
            isBackToPreviousScreenFromOTP = false
            if let loginVC = self.navigationController?.viewControllers.first(where: {
                $0 is LoginVC
            }) {
                self.navigationController?.popToViewController(loginVC, animated: true)
            }
        } else{
            self.navigationController?.popViewController(animated: true)
//            if loginVal ?? false{
//                self.navigationController?.popViewController(animated: true)
//            }
//            else{
//                self.navigationController?.popToRootViewController(animated: true)
//            }
        }
    }
    
    @objc func menuBtnAction(_ sender:ResponsiveButton){
        
        
    }
    
    @objc func languageBtnAction(_ sender:ResponsiveButton){
    }
    
    @objc func cartBtnAction(_ sender:Any){
    }
    
}
