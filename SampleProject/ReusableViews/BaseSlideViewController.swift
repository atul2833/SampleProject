//
//  BaseSlideViewController.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit
import SDWebImage

class BaseSlideViewController: UIViewController,UITextFieldDelegate{
    
    /** Variable Intailization **/
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    let label = UILabel()
    var screenName = String()

    var languageBtn = ResponsiveButton()
    var title_lbl = UILabel()
    var languageSignDataArr = ["ckb-IQ","ar-IQ","en"]
    var languageDataArr = [String]()

    var profileBtn = UIImageView()
    var profileBtn1 = ResponsiveButton()

  //  var notificationBtn = ResponsiveButton()
    
    private var notificationBtn = ResponsiveButton()
    private var notificationBadge = UIView()

    /** View Controllers Life Cycle Methods **/
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        
          self.tabBarController?.tabBar.isHidden = false

          self.navigationController?.navigationBar.tintColor = .white
          self.navigationController?.navigationBar.barTintColor =  UIColor.white
    //
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:AppFont.semi(.title),NSAttributedString.Key.foregroundColor: UIColor.appBase]
    //
               // self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    //
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
                self.navigationController?.navigationBar.shadowImage = UIImage()
        //  self.navigationController?.navigationBar.isTranslucent = false
          self.navigationController?.view.backgroundColor = UIColor.white
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

       //   self.navigationController?.navigationBar.setGradientBackground(colors: [.appBaseStartColor, .appBaseEndColor], startPoint: .topLeft, endPoint: .bottomRight)

     
       // viewL.dropShadow(.appBase)
//        let notificationBtn = UIButton(frame: CGRect(x: 0, y: 0,width: 44,height: 44))
//        notificationBtn.backgroundColor = UIColor.clear
//        notificationBtn.setImage(UIImage(named: "Group 72383"), for: .normal)
//        notificationBtn.contentMode = .center
//        notificationBtn.addTarget(self, action: #selector(notifiactionBtnAction(_:)), for: .touchUpInside)
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: notificationBtn)
        
        setupNotificationButton(isUnread: true)
        
    
    }
    
     func setupNotificationButton(isUnread: Bool) {

      //  notificationBtn = UIButton(type: .custom)

        notificationBtn.frame = CGRect(
            x: 0,
            y: 0,
            width: 44,
            height: 44
        )

        // Circular light gray background
        notificationBtn.backgroundColor = UIColor(
            red: 0.96,
            green: 0.96,
            blue: 0.96,
            alpha: 1.0
        )

        notificationBtn.layer.cornerRadius = 22
        notificationBtn.clipsToBounds = false

        // Bell icon
//        let bellImage = UIImage(
//            named: "Group 72383"
//        )?.withTintColor(
//            .white,
//            renderingMode: .alwaysOriginal
//        )

        notificationBtn.setImage(UIImage(named: "Group 72383"), for: .normal)

        notificationBtn.addTarget(
            self,
            action: #selector(notifiactionBtnAction(_:)),
            for: .touchUpInside
        )

        // Add unread badge
        notificationBadge = UIView()

        notificationBadge.backgroundColor = .systemRed

        notificationBadge.layer.cornerRadius = 4
        notificationBadge.layer.borderWidth = 1
        notificationBadge.layer.borderColor = UIColor.white.cgColor

        notificationBtn.addSubview(notificationBadge)

        notificationBadge.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            notificationBadge.widthAnchor.constraint(equalToConstant: 8),
            notificationBadge.heightAnchor.constraint(equalToConstant: 8),

            notificationBadge.topAnchor.constraint(
                equalTo: notificationBtn.topAnchor,
                constant:13
            ),

            notificationBadge.trailingAnchor.constraint(
                equalTo: notificationBtn.trailingAnchor,
                constant: -12
            )
        ])

        // Hide badge if notification is read
        notificationBadge.isHidden = !isUnread

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: notificationBtn
        )
    }
    
    private func setNotificationUnread(_ isUnread: Bool) {
        notificationBadge.isHidden = !isUnread
    }
    
    @objc func notifiactionBtnAction(_ sender:ResponsiveButton){
        setNotificationUnread(false)
        let vc = NotificationVC(viewModel: NotificationViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
   }
}

extension UIViewController {
    func reloadViewFromNib() {
        let parent = view.superview
        view.removeFromSuperview()
        view = nil
        parent?.addSubview(view) // This line causes the view to be reloaded
    }
}
