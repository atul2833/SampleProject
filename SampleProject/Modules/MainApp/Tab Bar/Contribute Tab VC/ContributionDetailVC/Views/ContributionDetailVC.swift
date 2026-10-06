//
//  MoneyCreditVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 05/02/24.
//

import UIKit

class ContributionDetailVC: BaseNavigationController {
    
    @IBOutlet weak var lblTotalCreditedMoney: UILabel!
    @IBOutlet weak var lblTotalBlockVal: UILabel!
    @IBOutlet weak var lblCurrentBlockVal: UILabel!
    @IBOutlet weak var refreshBtn: ResponsiveButton!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var topView:UIView!
    @IBOutlet weak var viewMyContribution:UIView!
    @IBOutlet weak var heightTblView:NSLayoutConstraint!
    @IBOutlet weak var lblContributedMoney:UILabel!
    
    private var viewModel: ContributionViewModel
    private var walletViewModel: WalletViewModel

    init(viewModel: ContributionViewModel,walletViewModel:WalletViewModel) {
        self.viewModel = viewModel
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

        initView()
        stateObserver()
        walletStateObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        //initVM()
        
        self.viewModel.blockLoansList(page: "1", limit: "10")
        self.walletViewModel.getWalletBalance()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //NotificationCenter.default.removeObserver(self, name: Notification.Name("BioSuccess"), object: nil)
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        
       
        topView.addGradientToViewTopToBottom(colors: [UIColor.subscriptionGredient1,UIColor.subscriptionGredient2])
        
        DispatchQueue.main.async{
            self.heightTblView.constant = self.tblView.contentSize.height + 50
        }
    }
    
    private func stateObserver() {
        self.viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .success:
                    break
                case .listFetched:
                    self?.handleContributionsData()
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
            .store(in: &self.viewModel.cancellable)
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
                    self?.handleWalletData()
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
    
    func initView() {
        
        self.navigationItem.title = "Money Credited"
        tblView.register(UINib(nibName: "MoneyCreditTblCell", bundle: nil), forCellReuseIdentifier: "MoneyCreditTblCell")
        tblView.tableFooterView = UIView()
    }
    
    func handleWalletData(){
    
        let currency = AppUserDefaults.shared.UDValue(.countryCurrency)
        
        self.lblContributedMoney.text = "\(currency as! String)\(self.walletViewModel.getMyContributedMoney() ?? "0.00")"
    }
    
    func handleContributionsData(){
    
        let list = viewModel.getContributionData()
        let currency = AppUserDefaults.shared.UDValue(.countryCurrency)

        self.lblCurrentBlockVal.text = "\(currency as! String)\(list?.currentBlockValue ?? 0.00)"
        self.lblTotalBlockVal.text = "\(currency as! String)\(list?.totalBlockValue ?? 0.00)"
        self.lblTotalCreditedMoney.text = "\(currency as! String)\(list?.totalCreditedMoney ?? 0.00)"
        self.tblView.reloadData()
        
        self.viewDidLayoutSubviews()
    }
    
    @IBAction func myContributionBtnAction(_ sender:ResponsiveButton){
        let vc = TransactionHistoryVC(viewModel: TransactionViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension ContributionDetailVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRowsDetail()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoneyCreditTblCell", for: indexPath) as! MoneyCreditTblCell
        
        let item = viewModel.getNumberOfItemDetail(At: indexPath)
        
        let currency = AppUserDefaults.shared.UDValue(.countryCurrency) as! String

        cell.ViewBack.backgroundColor = UIColor(hex: colorsList.colorsForCollectionView[indexPath.row % 5])
        cell.viewMainBack.backgroundColor = UIColor(hex: colorsList.colorsForCollectionView[indexPath.row % 5])?.withAlphaComponent(0.4)
        cell.typeLbl.textColor =  UIColor(hex: colorsList.textColor[indexPath.row % 5])
        cell.typeLbl.text = item?.userData?.fullName?.prefix(2).uppercased()
        cell.typeNameLbl.text = item?.userData?.fullName
        cell.lblBlockVal.text = "\(currency)\(item?.creditData?.paidAmount ?? 0.0)"
        cell.lblTotalMoney.text = "\(currency)\(item?.creditData?.loanAmount ?? 0.0)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.getNumberOfItemDetail(At: indexPath)

        let vc = CreditDetailsVC(transactionViewModel: TransactionViewModel(), creditViewModel: CreditViewModel(), creditDetailsViewModel: CreditDetailsViewModel(), creditData: CreditResponseSubDataModel(creditData: item?.creditData))
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
