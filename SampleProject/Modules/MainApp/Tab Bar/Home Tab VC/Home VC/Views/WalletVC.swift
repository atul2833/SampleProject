//
//  WalletVC.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 29/07/24.
//

import UIKit

class WalletVC: BaseNavigationController {
    
    @IBOutlet weak var refreshBtn: ResponsiveButton!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var topView:UIView!
    @IBOutlet weak var viewMyContribution:UIView!
    @IBOutlet weak var heightTblView:NSLayoutConstraint!
    @IBOutlet weak var lblContributedMoney:UILabel!
    @IBOutlet weak var lblWalletAmount: UILabel!
    @IBOutlet weak var lblHoldAmount: UILabel!

    private var viewModel: TransactionViewModel
    private var walletViewModel: WalletViewModel

    init(viewModel: TransactionViewModel,walletViewModel:WalletViewModel) {
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

        self.navigationItem.title = "Available Balance"
        initView()
        setNavigationBar()
        stateObserver()
        walletStateObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        //initVM()
        
        self.viewModel.getTransactionList(page: "1", limit: "20", type: "user", blockId: "", creditRequestId: "")
        self.walletViewModel.getWalletBalance()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //NotificationCenter.default.removeObserver(self, name: Notification.Name("BioSuccess"), object: nil)
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        
        //topView.addGradientToViewTopToBottom(colors: [UIColor.subscriptionGredient1,UIColor.subscriptionGredient2])
        
        DispatchQueue.main.async{
            
            let rows = self.viewModel.getNumberOfRows()
            
            self.heightTblView.constant = rows == 0 ? self.screenHeight / 2 : self.tblView.contentSize.height + 50

            self.showHideEmptyState(isShow: rows == 0)
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
                case .transactionListFetched:
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
            .store(in: &self.walletViewModel.cancellable)
    }
    
    func handleContributionsData(){
    
        let currency = AppUserDefaults.shared.UDValue(.countryCurrency)
        
        self.lblWalletAmount.text = "\(currency as! String)\(self.walletViewModel.getTotalCreditedAmount() ?? "")"
        self.lblHoldAmount.text = "\(currency as! String) 0.00"
    }
    
    
    func setNavigationBar(){
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        customView.isUserInteractionEnabled = true // Enable user interaction

           let label = UILabel(frame: CGRect(x: 10, y: 0, width: 160, height: 40))
           label.text = "My contribution"
           label.textColor = .appBase
        label.font = AppFont.bold(.title)
        customView.addSubview(label)
       
   
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(customView: customView)
    }
    
    @IBAction func transactionPressed(_ sender:ResponsiveButton){
        let vc = TransactionHistoryVC(viewModel: TransactionViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func addMoeny(_ sender:ResponsiveButton){
        let vc = AddFundsVC(walletViewModel: WalletViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func initView() {
        
        tblView.register(UINib(nibName: "TransactionHistoryTblCell", bundle: nil), forCellReuseIdentifier: "TransactionHistoryTblCell")
        tblView.tableFooterView = UIView()
    }
}


extension WalletVC:UITableViewDelegate,UITableViewDataSource{
    
    private func showHideEmptyState(isShow: Bool) {
        if isShow {
            self.tblView.setEmptyView(
                image: UIImage(resource: .iconNoData),
                title: ""
            )
        } else {
            self.tblView.restore()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = viewModel.getNumberOfRows()
        
        self.showHideEmptyState(isShow: rows == 0)

        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryTblCell", for: indexPath) as! TransactionHistoryTblCell
        
        let countryCurrency = (AppUserDefaults.shared.UDValue(.countryCurrency) as? String) ?? "$"

        let item = viewModel.getNumberOfItem(At: indexPath)
        cell.lblTitle.text = item?.name
        cell.lblDate.text = item?.timeDate?.dateStringToDateTimeString()
        cell.lblPrice.text = "\(countryCurrency)\(item?.amount ?? 0)"
            
        return cell
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//              if indexPath.row == viewModel.numberOfCells - 1 {
//                  loadNextPage()
//              }
//        }
//
//    func loadNextPage() {
//            // Simulate fetching data from a server or another data source
//            currentPage += 1
//
//            if currentPage <= viewModel.transactionData.totalPage{
//                viewModel.getTransationList(filterType: "", start: "", end: "", page: currentPage, removeData: false)
//                tblView.reloadData()
//            }
//
//        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = viewModel.getNumberOfItem(At: indexPath)

        let vc = TransactionDetailVC(viewModel: TransactionViewModel(transactionId: item?.transactionId ?? ""))
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
