//
//  AboutAppVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 05/02/24.
//

import UIKit

class AboutAppVC: BaseNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "About TAG Credit"
    }
    
    @IBAction func termsAndPrivacyBtnAction(_ sender:ResponsiveButton){
//        let vc = TermsAndPrivacyVC()
//            vc.coming_from = sender.tag == 0 ? "terms" : "privacy"
//         self.navigationController?.pushViewController(vc, animated: true)
        if sender.tag == 0 {
            let URLString = ServerConfiguration.shared.termsOfServiceURL
                    openURLInSafari(urlString: URLString)
                } else {
                    let URLString = ServerConfiguration.shared.privacyPolicyURL
                    openURLInSafari(urlString: URLString)
                }
            
            
            func openURLInSafari(urlString: String) {
                guard let url = URL(string: urlString) else {
                    print("Invalid URL")
                    return
                }
                guard UIApplication.shared.canOpenURL(url) else {
                    print("Safari cannot be opened with this URL")
                    return
                }
                UIApplication.shared.open(url)
            }
    }

}
