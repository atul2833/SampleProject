//
//  MoneyDetailsVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 05/02/24.
//

import UIKit

class CreditDetailsVC: BaseNavigationController {
    
    @IBOutlet weak var tblView:UITableView!

    private var transactionViewModel: TransactionViewModel
    private var creditViewModel: CreditViewModel
    private var creditDetailsViewModel: CreditDetailsViewModel
    private var lblUserName: UILabel!
    private var profileImage:UIImageView!

    private var creditData:CreditResponseSubDataModel?
    private var selectedEmiId :String?

    init(transactionViewModel: TransactionViewModel,creditViewModel: CreditViewModel,creditDetailsViewModel:CreditDetailsViewModel,creditData:CreditResponseSubDataModel?) {
       
        self.transactionViewModel = transactionViewModel
        self.creditViewModel = creditViewModel
        self.creditDetailsViewModel = creditDetailsViewModel
        self.creditData = creditData
        
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
        
        self.stateObserverTransaction()
        self.contributionStateObserver()
        self.nextPaymentStateObserver()
        self.navigationItem.title = "Credit Detail"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //initVM()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //NotificationCenter.default.removeObserver(self, name: Notification.Name("BioSuccess"), object: nil)
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
    }
    
    func initView() {
        
        tblView.register(UINib(nibName: "SeeMoreFooterTblCell", bundle: nil), forCellReuseIdentifier: "SeeMoreFooterTblCell")
        tblView.register(UINib(nibName: "CreditDetailsNextTblCell", bundle: nil), forCellReuseIdentifier: "CreditDetailsNextTblCell")
        tblView.register(UINib(nibName: "TitleHeaderTblCell", bundle: nil), forCellReuseIdentifier: "TitleHeaderTblCell")
        tblView.register(UINib(nibName: "TransactionHistoryTblCell", bundle: nil), forCellReuseIdentifier: "TransactionHistoryTblCell")
        tblView.register(UINib(nibName: "CreditTblCell", bundle: nil), forCellReuseIdentifier: "CreditTblCell")

        tblView.tableFooterView = UIView()
        
        self.creditViewModel.merchantLoanDetails(creditRequestId: creditData?.creditData?.creditRequestId ?? "")
        self.creditDetailsViewModel.emiList()
        self.transactionViewModel.getTransactionList(page: "1", limit: "5", type: "creditRequest", blockId: "", creditRequestId: creditData?.creditData?.creditRequestId ?? "")
    }
    
    private func stateObserverTransaction() {
        self.transactionViewModel.stateSubject
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
            .store(in: &self.transactionViewModel.cancellable)
    }
    
    private func contributionStateObserver() {
        self.creditViewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .success:
                    break
                case .creditData:
                    self?.tblView.reloadData()
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
            .store(in: &self.creditViewModel.cancellable)
    }
    
    private func nextPaymentStateObserver() {
        self.creditDetailsViewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .success:
                    self?.tblView.reloadData()
                case .emiPayment(let transactionId):
                    self?.goToTransactionDetail(transactionId:transactionId)
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
            .store(in: &self.creditDetailsViewModel.cancellable)
    }
    
    func handleContributionsData(){
       
    }
    
    func goToTransactionDetail(transactionId:String){
        let vc = TransactionDetailVC(viewModel: TransactionViewModel(transactionId: transactionId))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func seeMoreNextPayments(sender: ResponsiveButton) {
//        let vc = AllBlockVC(viewModel: BlockViewModel(type:"all"))
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func seeMoreTransections(sender: ResponsiveButton) {
        let vc = TransactionHistoryVC(viewModel: TransactionViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CreditDetailsVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        else if section == 1{
            return creditDetailsViewModel.getNumberOfRows() > 0 ? 1 : 0
        }
        else{
            return transactionViewModel.getNumberOfRows()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreditTblCell", for: indexPath) as! CreditTblCell
            
            let item = creditViewModel.getCreditData()//creditViewModel.getNumberOfItem(At: indexPath)
            
            cell.ViewBack.backgroundColor = UIColor(hex: colorsList.colorsForCollectionView[indexPath.row % 5])
            cell.viewMainBack.backgroundColor = UIColor(hex: colorsList.colorsForCollectionView[indexPath.row % 5])?.withAlphaComponent(0.4)
            cell.typeLbl.textColor =  UIColor(hex: colorsList.textColor[indexPath.row % 5])
            cell.typeLbl.text = item?.blockData?.blockName?.prefix(2).uppercased()
            cell.typeFullLbl.text = item?.blockData?.blockName

            cell.lblHeaderBlockVal.text = "Loan Balance at \(item?.creditData?.interestRate ?? 0)% interest"
            cell.lblBlockVal.text = "\(item?.creditData?.loanAmount ?? 0)"
            cell.lblContributedAmount.text = "\(item?.creditData?.dueAmount ?? 0)"
            cell.lblTotalCreditedMoney.text = "\(item?.creditData?.paidAmount ?? 0)"
            
            return cell
        }
        else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreditDetailsNextTblCell", for: indexPath) as! CreditDetailsNextTblCell
            
            let item = creditDetailsViewModel.getNumberOfItem(At: indexPath)
            let currency  = AppUserDefaults.shared.UDValue(.countryCurrency) as? String
            cell.lblTitle.text = "\(currency ?? "")\(item?.dueAmount ?? 0.00)"
            cell.lblDate.text = "Next due \(item?.timeDate?.dateStringToString() ?? "")"
                
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryTblCell", for: indexPath) as! TransactionHistoryTblCell
            
            let countryCurrency = (AppUserDefaults.shared.UDValue(.countryCurrency) as? String) ?? "$"

            let item = transactionViewModel.getNumberOfItem(At: indexPath)
            cell.lblTitle.text = item?.name
            cell.lblDate.text = item?.timeDate?.dateStringToDateTimeString()

            cell.lblPrice.text = "\(countryCurrency)\(item?.amount ?? 0)"
                
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var item : NextPaymentDataModel?//
                                 
        if section == 1{
            item = creditDetailsViewModel.getNumberOfItem(At: IndexPath(row: section, section: 0))
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleHeaderTblCell") as! TitleHeaderTblCell
        cell.lblTitle.text = section == 1 ? "REPAYMENT AMOUNT(\(item?.rePaymentDurationRule?.uppercased() ?? ""))" : "TOTAL TRANSACTIONS"
        cell.backView.backgroundColor = UIColor.white
        cell.backLabel.backgroundColor = UIColor.systemGray5
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : section == 1 ? (creditDetailsViewModel.getNumberOfRows() > 0 ? 30 : 0) : (transactionViewModel.getNumberOfRows() > 0 ? 30 : 0)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreFooterTblCell") as! SeeMoreFooterTblCell
        cell.backView.backgroundColor = .white

        if section == 0{
            cell.btnSeeMore.addTarget(self, action: #selector(seeMoreNextPayments), for: .touchUpInside)
        }else{
            cell.btnSeeMore.addTarget(self, action: #selector(seeMoreTransections), for: .touchUpInside)
            
        }
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2{
            return transactionViewModel.getNumberOfRows() > 3 ? 44 : 0
        }
       return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1{
            
            let item = creditDetailsViewModel.getNumberOfItem(At: indexPath)

            selectedEmiId = item?.emiId
            
//            let vc = RepaymentPopupVC()
//                vc.alertConfirm = self
//            self.presentOnViewController(with: vc)
        }
        else{
            //let cellVM = viewModel.transactionViewModel.getCellViewModel( at: indexPath )

            let item = transactionViewModel.getNumberOfItem(At: indexPath)

            let vc = TransactionDetailVC(viewModel: TransactionViewModel(transactionId: item?.transactionId ?? "0"))
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension CreditDetailsVC:AlertConfimDelegate{
    func alertAction(_ status: String) {
        creditDetailsViewModel.emiPayment(emiId: selectedEmiId ?? "")
    }
}
