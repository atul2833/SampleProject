//
//  HomeTabBarController.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 10/01/2024.
//

import UIKit

final class HomeTabBarController: UITabBarController {
    
    private enum HomeTabBarItem: CaseIterable {
        case home, block, contribution,message, profile
        
        var title: String {
            switch self  {
            case .home:
                return NSLocalizedString("Home", comment: "")
            case .block:
                return NSLocalizedString("Blocks", comment: "")
            case .contribution:
                return NSLocalizedString("Contribution", comment: "")
            case .message:
                return NSLocalizedString("Message", comment: "")
            case .profile:
                return NSLocalizedString("Profile", comment: "")
            }
        }
        
        var icon: UIImage {
            switch self  {
            case .home:
                return UIImage(resource: .iconHomeUnselected)
            case .block:
                return UIImage(resource: .iconBlockUnselected)
            case .contribution:
                return UIImage(resource: .iconContributionUnselected)
            case .message:
                return UIImage(resource: .iconMessageUnselected)
            case .profile:
                return UIImage(resource: .iconProfileUnselected)
            }
        }
        
        var selectedIcon: UIImage {
            switch self  {
            case .home:
                return UIImage(resource: .iconHomeSelected)
            case .block:
                return UIImage(resource: .iconBlockSelected)
            case .contribution:
                return UIImage(resource: .iconContributionSelected)
            case .message:
                return UIImage(resource: .iconMessageSelected)
            case .profile:
                return UIImage(resource: .iconProfileSelected)
            }
        }
        
        var item: UITabBarItem {
            let tabbarItem = UITabBarItem(title: self.title,
                                          image: self.icon,
                                          selectedImage: self.selectedIcon)
            tabbarItem.accessibilityIdentifier = self.title
            return tabbarItem
        }
    }
    
    var isNeedToCheckAuth = false
    
    private let userContext: UserContext
    
    init(userContext: UserContext) {
        self.userContext = userContext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
       // UserDefaults.standard.setValue(true, forKey: UserDefaults.Keys.isLoggedIn.rawValue)
        let homeVC = makeViewController(for: .home)
        let blockVC = makeViewController(for: .block)
        let contributionVC = makeViewController(for: .contribution)
        let messageVC = makeViewController(for: .message)
        let profileVC = makeViewController(for: .profile)
        homeVC.tabBarItem = HomeTabBarItem.home.item
        blockVC.tabBarItem = HomeTabBarItem.block.item
        contributionVC.tabBarItem = HomeTabBarItem.contribution.item
        messageVC.tabBarItem = HomeTabBarItem.message.item
        profileVC.tabBarItem = HomeTabBarItem.profile.item
        tabBar.tintColor = .appBase
        
        viewControllers = [homeVC, blockVC, contributionVC,messageVC, profileVC]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    /**
     let homeVC = UINavigationController(rootViewController: HomeTabVC())
         homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home_un"), selectedImage:UIImage(named: "home"))
     
     let blockVC = UINavigationController(rootViewController: BlockTabVC())
         blockVC.tabBarItem = UITabBarItem(title: "Blocks", image: UIImage(named: "block_un"), selectedImage: UIImage(named: "block"))
     
     let contributionVC = UINavigationController(rootViewController: ContributeTabVC())
         contributionVC.tabBarItem = UITabBarItem(title: "Contribution", image: UIImage(named: "contribution_un"), selectedImage: UIImage(named: "contribution"))

     let messageVC = UINavigationController(rootViewController: MessageTabVC())
         messageVC.tabBarItem = UITabBarItem(title: "Message", image: UIImage(named: "chat_un"), selectedImage: UIImage(named: "chat"))
 
     let profileVC = UINavigationController(rootViewController:ProfileTabVC())
         profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile_un"), selectedImage:UIImage(named: "profile"))
     */
    private func makeViewController(for item: HomeTabBarItem) -> UIViewController {
        switch item {
        case .home:
            let nvc = UINavigationController(rootViewController: HomeTabVC(viewModel: HomeViewModel(userContext: userContext, delegate: nil), blockViewModel: BlockViewModel(), transactionViewModel: TransactionViewModel(), contributionViewModel: ContributionViewModel(), walletViewModel: WalletViewModel(), propertyViewModel: RentalViewModel()))
            nvc.navigationBar.prefersLargeTitles = false
            return nvc
        case .block:
            let nvc = UINavigationController(rootViewController: BlockTabVC(viewModel: BlockViewModel()))
            nvc.navigationBar.prefersLargeTitles = false
            return nvc
        case .contribution:
            let nvc = UINavigationController(rootViewController: ContributeTabVC(viewModel: ContributionViewModel(), walletViewModel: WalletViewModel()))
            nvc.navigationBar.prefersLargeTitles = false
            return nvc
        case .message:
            let nvc = UINavigationController(rootViewController: MessageTabVC(viewModel: MessageViewModel()))
            nvc.navigationBar.prefersLargeTitles = false
            return nvc
        case .profile:
            let nvc = UINavigationController(rootViewController: ProfileTabVC(viewModel: ProfileViewModel(userContext: userContext)))
            nvc.navigationBar.prefersLargeTitles = false
            return nvc
        }
    }
    
    func logout() {
        DispatchQueue.main.async {
            AppUserDefaults().clearAllUD()
            KeychainWrapper.shared.clearAllKeychain()
            let loginVC = LoginVC(viewModel: RegisterViewModel())
            let navigationController = UINavigationController(rootViewController: loginVC)
            navigationController.setNavigationBarHidden(false, animated: true)
            UIApplication.shared.windows.first?.rootViewController = navigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()            
        }
    }
}

