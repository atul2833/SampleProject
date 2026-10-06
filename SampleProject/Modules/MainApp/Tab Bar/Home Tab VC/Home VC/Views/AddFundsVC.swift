//
//  AddFundsVC.swift
//  MoneyMoov
//
//  Created by somendra on 09/07/24.
//

import UIKit

class AddFundsVC: BaseNavigationController {
    
    @IBOutlet weak var tblView: UITableView!
    private var selectedCurrency : String?
    
    var arr = [(title: "Bank Account",image: "Group 73889"),(title: "Debit/Credit Card",image: "Group 73890")]

    let dataArr = [(title:"David",image:"david"),(title:"Netflix",image:"netflix"),(title:"Amazon",image:"amazon"),(title:"Jessica",image:"jessica")]
           
    var headerDataArr = [(title:"",slug:"wallet"),(title:"CATEGORIES",slug:"categories"),(title:"",slug:"currency"),(title:"",slug:"payment"),(title:"TRANSACTION HISTORY",slug:"transaction")]
            
    private var lblUserName: UILabel!
    private var profileImage:UIImageView!
    
    private var walletViewModel: WalletViewModel

    var isUserLoggedIn = AppUserDefaults.shared.UDValue(.isLoggedIn) as? Bool ?? false
    
    init(walletViewModel:WalletViewModel) {
        self.walletViewModel = walletViewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    deinit {
        Log.info("====== \(self) ======")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Wallet Money"
        tblView.register(UINib(nibName: "AddFundsTableViewCell", bundle: nil), forCellReuseIdentifier: "AddFundsTableViewCell")
                
        tblView.register(UINib(nibName: "HomeTabFirstCell", bundle: nil), forCellReuseIdentifier: "HomeTabFirstCell")
        
        self.walletStateObserver()
        self.walletViewModel.paymentMethodListApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    private func walletStateObserver() {
        self.walletViewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .success:
                    self?.tblView.reloadData()
                
                case .error(let message):
                    Log.error(message)
                    self?.view.makeToast(message, position: .bottom)
                case .logout:
                    let tabBar = self?.tabBarController as? HomeTabBarController
                    tabBar?.logout()
                default:
                    break
                }
            }
            .store(in: &self.walletViewModel.cancellable)
    }
}

extension AddFundsVC: UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletViewModel.paymentMethodData?.count ?? 0
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "AddFundsTableViewCell",
            for: indexPath
        ) as! AddFundsTableViewCell
        
        guard let paymentMethod = walletViewModel.paymentMethodData?[indexPath.row] else {
            return cell
        }
        
        cell.imgView.sd_setImage(with: paymentMethod.payImageUrl, placeholderImage: .none)
        cell.lblTitle.text = paymentMethod.title
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard let paymentMethod = walletViewModel.paymentMethodData?[indexPath.row] else {
            return
        }

        let vc = SendMoneyVC(
            walletViewModel: WalletViewModel(),
            comingFrom: paymentMethod.value, paymentMethod: paymentMethod
        )

        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = SendMoneyVC(walletViewModel: WalletViewModel(),comingFrom: indexPath.row == 0 ? "bank" : "card")
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
}
