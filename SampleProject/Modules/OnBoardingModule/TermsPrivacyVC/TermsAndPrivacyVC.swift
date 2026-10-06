//
//  AboutAndHelpVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit

class TermsAndPrivacyVC:  BaseNavigationController {
    
    @IBOutlet weak var txt_view: UITextView!
    
    var coming_from = String()

    lazy var viewModel: TermsAndPrivacyViewModel = {
        return TermsAndPrivacyViewModel()
    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()

        self.navigationItem.title = coming_from == "terms" ? "Terms & Conditions" : "Privacy Policy"
        
        self.txt_view.attributedText = "Lorem ipsum dolor sit amet. Est minus blanditiis aut sint autem est dicta molestiae aut nemo cumque aut quam error? Est quas pariatur in atque ipsum qui rerum dolore non quae provident sed accusantium rerum ut labore iusto et voluptatem autem. \nId ducimus natus quo architecto voluptatem et nisi eius et quia corrupti sed praesentium soluta! Et odio officia hic fuga minus in sunt dolore.\n Aut architecto fugiat qui omnis maxime ut voluptate sapiente est doloribus sint. Et quia vero et incidunt dolores et omnis consequatur. Lorem ipsum dolor sit amet. Est minus blanditiis aut sint autem est dicta molestiae aut nemo cumque aut quam error? Est quas pariatur in atque ipsum qui rerum dolore non quae provident sed accusantium rerum ut labore iusto et voluptatem autem. \nId ducimus natus quo architecto voluptatem et nisi eius et quia corrupti sed praesentium soluta! Et odio officia hic fuga minus in sunt dolore.\n Aut architecto fugiat qui omnis maxime ut voluptate sapiente est doloribus sint. Et quia vero et incidunt dolores et omnis consequatur. Lorem ipsum dolor sit amet. Est minus blanditiis aut sint autem est dicta molestiae aut nemo cumque aut quam error? Est quas pariatur in atque ipsum qui rerum dolore non quae provident sed accusantium rerum ut labore iusto et voluptatem autem. \nId ducimus natus quo architecto voluptatem et nisi eius et quia corrupti sed praesentium soluta! Et odio officia hic fuga minus in sunt dolore.\n Aut architecto fugiat qui omnis maxime ut voluptate sapiente est doloribus sint. Et quia vero et incidunt dolores et omnis consequatur.".loadHTMLText()//self?.viewModel.dataDescription!.loadHTMLText()

       // initVM()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
}
