//
//  ContributeTabVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 02/02/24.
//

import UIKit

class ContributeTabVC: BaseSlideViewController {
    
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
        setNavigationBar()
        stateObserver()
        walletStateObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        //initVM()
        
        self.viewModel.getMyContributionList(page: "1", limit: "10")
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
                case .listFetched:
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
    
        let currency = AppUserDefaults.shared.UDValue(.countryCurrency) as? String
        
        self.lblContributedMoney.text = "\(currency ?? "")\(self.walletViewModel.getMyContributedMoney() ?? "0.00")"
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
    
    func initView() {
        
        tblView.register(UINib(nibName: "ContributionTblCell", bundle: nil), forCellReuseIdentifier: "ContributionTblCell")
        tblView.tableFooterView = UIView()
    }
}


extension ContributeTabVC:UITableViewDelegate,UITableViewDataSource{
    
    private func showHideEmptyState(isShow: Bool){
        if isShow {
            self.tblView.setEmptyView(
                image: UIImage(resource: .iconNoData),
                title: "No block"
            )
        } else {
            self.tblView.restore()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rows = viewModel.getNumberOfRows()
        
        self.showHideEmptyState(isShow: rows == 0)
        
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContributionTblCell", for: indexPath) as! ContributionTblCell
        self.viewDidLayoutSubviews()
        
        let item = viewModel.getNumberOfItem(At: indexPath)
        
        
        let currency = AppUserDefaults.shared.UDValue(.countryCurrency) as! String

        cell.ViewBack.backgroundColor = UIColor(hex: colorsList.colorsForCollectionView[indexPath.row % 5])
        cell.viewMainBack.backgroundColor = UIColor(hex: colorsList.colorsForCollectionView[indexPath.row % 5])?.withAlphaComponent(0.4)
        cell.typeLbl.textColor =  UIColor(hex: colorsList.textColor[indexPath.row % 5])
        cell.typeLbl.text = item?.blockData?.blockName?.prefix(2).uppercased()
        cell.typeFullLbl.text = item?.blockData?.blockName
        cell.lblBlockVal.text = "\(currency)\(item?.contributionData?.totalBlockValue ?? 0.0)"
        cell.lblCreditedAmount.text = "\(currency)\(item?.contributionData?.creditedAmount ?? 0.0)"
        cell.lblContributedAmount.text = "\(currency)\(item?.contributionData?.contributedAmount ?? 0.0)"
        cell.lblTotalCreditedMoney.text = "\(currency) \(item?.contributionData?.currentValue ?? 0.0)"
        
//        if indexPath.row % 2 == 0{
//            cell.typeImg.image = UIImage(named: "Group 72428")
//            cell.typeShortLbl.text = "TT"
//            cell.typeFullLbl.text = "The Tree Fellas."
//            cell.typeShortLbl.textColor = .black
//        }else{
//            cell.typeImg.image = UIImage(named: "Group 72429")
//            cell.typeShortLbl.text = "TW"
//            cell.typeFullLbl.text = "The Wine Guys."
//            cell.typeShortLbl.textColor = .white
//        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = viewModel.getNumberOfItem(At: indexPath)

        let vc = ContributionDetailVC(viewModel: ContributionViewModel(blockId: item?.blockData?.blockId), walletViewModel: WalletViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
