//
//  HomeVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit
import SDWebImage
import CoreLocation
//import DropDown


class HomeTabVC: BaseSlideViewController{

    @IBOutlet weak var refreshBtn: ResponsiveButton!

    @IBOutlet weak var lblWalletAmount: UILabel!
    @IBOutlet weak var lblCurrency: UILabel!

    @IBOutlet weak var tblViewBlocks:UITableView!
    @IBOutlet weak var tblViewProperty:UITableView!

    @IBOutlet weak var tblViewTransactions:UITableView!

    @IBOutlet weak var collecView:UICollectionView!
    @IBOutlet weak var lblContributedMoney:UILabel!
    @IBOutlet weak var lblCurrentValue:UILabel!

    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var heightTblViewBlock: NSLayoutConstraint!
    @IBOutlet weak var heightTblViewTransaction: NSLayoutConstraint!
    @IBOutlet weak var heightTblViewProperty: NSLayoutConstraint!

    @IBOutlet weak var topTransactionLbl: NSLayoutConstraint!
    @IBOutlet weak var topPropertyLbl: NSLayoutConstraint!
    @IBOutlet weak var topBlockLbl: NSLayoutConstraint!
    @IBOutlet weak var bottomBlockTblView: NSLayoutConstraint!

    @IBOutlet weak var viewTitleContribution: UIView!
    @IBOutlet weak var viewTitleBlocks: UIView!
    @IBOutlet weak var viewTitleTransactions: UIView!
    @IBOutlet weak var viewTitleProperties: UIView!

    @IBOutlet weak var btnViewAll: ResponsiveButton!

    private var viewModel: HomeViewModel
    private var blockViewModel: BlockViewModel
    private var transactionViewModel: TransactionViewModel
    private var contributionViewModel: ContributionViewModel
    private var walletViewModel: WalletViewModel
    private var propertyViewModel: RentalViewModel
    private var isHomeCalled = true

    private var lblUserName: UILabel!
    private var profileImage:UIImageView!
    private var currency = AppUserDefaults.shared.UDValue(.countryCurrency) as? String
    
    init(viewModel: HomeViewModel,blockViewModel: BlockViewModel, transactionViewModel: TransactionViewModel,contributionViewModel: ContributionViewModel,walletViewModel:WalletViewModel,propertyViewModel: RentalViewModel) {
        self.viewModel = viewModel
        self.blockViewModel = blockViewModel
        self.transactionViewModel = transactionViewModel
        self.contributionViewModel = contributionViewModel
        self.walletViewModel = walletViewModel
        self.propertyViewModel = propertyViewModel
        
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
        addNavigationView()
        
        self.stateObserver()
        self.stateObserverBlockViewModel()
        self.stateObserverTransaction()
        self.contributionStateObserver()
        self.walletStateObserver()
        self.propertyStateObserver()
        
//        let security = Utilities.shared.UDValue(.security)
//        let notifySecurity = Utilities.shared.UDValue(.notifySecurity)
//
//        if security == "yes" && notifySecurity == "yes"{
//             callBioMetric()
//        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(wokeAPI(_:)), name: Notification.Name("Woke"), object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(nextNotify(_:)), name: Notification.Name("BioSuccess"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isHomeCalled{
            isHomeCalled = false
            let security = AppUserDefaults.shared.UDValue(.isBiometricEnable) as? String

            if security == "yes"{
                callBioMetric()
            }
            else{
                callAPIData()
            }
        }
        else{
            callAPIData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(nextNotify(_:)), name: Notification.Name("BioSuccess"), object: nil)
        
        //initVM()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: Notification.Name("BioSuccess"), object: nil)
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
    
        DispatchQueue.main.async {
            
            let rowsContribution = self.contributionViewModel.getNumberOfRows()
            self.viewTitleContribution.isHidden = rowsContribution == 0
            self.collecView.isHidden =  rowsContribution == 0
            self.topBlockLbl.constant = rowsContribution == 0 ? 28 : 176
            
            self.heightTblViewBlock.constant =  self.tblViewBlocks.contentSize.height

            DispatchQueue.main.async {
                let rowsBlocks = self.blockViewModel.getNumberOfRows()
                self.viewTitleBlocks.isHidden = rowsBlocks == 0
                self.tblViewBlocks.isHidden = rowsBlocks == 0
                self.topPropertyLbl.constant = (self.topBlockLbl.constant  + self.tblViewBlocks.contentSize.height + 28)
                
                self.heightTblViewProperty.constant = self.tblViewProperty.contentSize.height
                
                DispatchQueue.main.async {
                    
                    let rowsProperties = self.propertyViewModel.getNumberOfRows()
                    self.viewTitleProperties.isHidden = rowsProperties == 0
                    self.tblViewProperty.isHidden = rowsProperties == 0
                    self.topTransactionLbl.constant = (self.topPropertyLbl.constant  + self.tblViewProperty.contentSize.height + 28)
                    
                    self.heightTblViewTransaction.constant = self.tblViewTransactions.contentSize.height
                    
                    DispatchQueue.main.async {
                        let rowsTransactions = self.transactionViewModel.getNumberOfRows()
                        self.viewTitleTransactions.isHidden = rowsTransactions == 0
                        
                    }
                }
            }
            
           // self.bottomBlockTblView.constant = rowsTransactions > 0 ? (self.tblViewTransactions.contentSize.height + 50) : 0
        
        }
    }
    
    func initView() {
        
        collecView.register(UINib(nibName: "HomeCollecCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollecCell")
        
        tblViewBlocks.register(UINib(nibName: "BlockTblViewCell", bundle: nil), forCellReuseIdentifier: "BlockTblViewCell")
        tblViewBlocks.register(UINib(nibName: "SeeMoreFooterTblCell", bundle: nil), forCellReuseIdentifier: "SeeMoreFooterTblCell")

        tblViewTransactions.register(UINib(nibName: "TransactionHistoryTblCell", bundle: nil), forCellReuseIdentifier: "TransactionHistoryTblCell")
        tblViewTransactions.register(UINib(nibName: "SeeMoreFooterTblCell", bundle: nil), forCellReuseIdentifier: "SeeMoreFooterTblCell")

        tblViewProperty.register(UINib(nibName: "RentalPropertiesTableCell", bundle: nil), forCellReuseIdentifier: "RentalPropertiesTableCell")

        tblViewProperty.register(UINib(nibName: "SeeMoreFooterTblCell", bundle: nil), forCellReuseIdentifier: "SeeMoreFooterTblCell")

        tblViewBlocks.removeExtraTopPadding()
        tblViewProperty.removeExtraTopPadding()
        tblViewTransactions.removeExtraTopPadding()
        
        tblViewBlocks.tableFooterView = UIView()
        tblViewTransactions.tableFooterView = UIView()
        tblViewProperty.tableFooterView = UIView()
    }
    
    func callAPIData(){
        self.viewModel.getProfileInfo()
        
        blockViewModel.clearBlockData()
        var model = blockViewModel.paginationParams
            model.page = 1
            model.limit = 4
            model.type = "popularBlocks"
        blockViewModel.paginationParams = model
        self.blockViewModel.getBlockList()

        self.transactionViewModel.clearData()
        self.transactionViewModel.getTransactionList(page: "1", limit: "5", type: "user", blockId: "", creditRequestId: "")
        
        self.contributionViewModel.clearData()
        self.contributionViewModel.getMyContributionList(page: "1", limit: "4")
        
        propertyViewModel.clearRenatalData()
        var model1 = propertyViewModel.paginationParams
            model1.page = 1
            model1.limit = 2
            model1.type = "all"
        propertyViewModel.paginationParams = model1
        
        propertyViewModel.getPropertyList()
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
                case .blockListFetched:
                    self?.tblViewBlocks.reloadData()
                case .profileLoaded(let model):
                    self?.updateProfileInfo(model: model)
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
    
    private func stateObserverBlockViewModel() {
        self.blockViewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .success:
                    break
                case .blockListFetched:
                    self?.tblViewBlocks.reloadData()
                case .error(let message):
                    Log.error(message)
                    self?.view.makeToast(message, position: .bottom)
                case .logout:
                    let tabBar = self?.tabBarController as? HomeTabBarController
                    tabBar?.logout()
                }
            }
            .store(in: &self.blockViewModel.cancellable)
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
                    self?.tblViewTransactions.reloadData()
                case .error(let message):
                    Log.error(message)
                    self?.view.makeToast(message, position: .bottom)
                case .logout:
                    let tabBar = self?.tabBarController as? HomeTabBarController
                    tabBar?.logout()
                }
            }
            .store(in: &self.transactionViewModel.cancellable)
    }
    
    private func contributionStateObserver() {
        self.contributionViewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .success:
                    break
                case .listFetched:
                    DispatchQueue.main.async {
                        self?.collecView.reloadData()
                    }
                case .error(let message):
                    Log.error(message)
                    self?.view.makeToast(message, position: .bottom)
                case .logout:
                    let tabBar = self?.tabBarController as? HomeTabBarController
                    tabBar?.logout()
                }
            }
            .store(in: &self.contributionViewModel.cancellable)
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
    
    private func propertyStateObserver() {
        self.propertyViewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .listFetched:
                    self?.tblViewProperty.reloadData()
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
            .store(in: &self.propertyViewModel.cancellable)
    }
    
    func handleContributionsData(){
        
        let userContext = self.viewModel.getUserContext()
        let model = userContext.getUserInformation().profileModel
        
        self.lblContributedMoney.text = "\(model?.countryCurrency ?? "")\(self.walletViewModel.getMyContributedMoney() ?? "0.00")"
        self.lblCurrentValue.text = "\(model?.countryCurrency ?? "")\(self.walletViewModel.getMyContributedMoney() ?? "0.00")"
        
        self.lblWalletAmount.text = "\(model?.countryCurrency ?? "")\(self.walletViewModel.getTotalCreditedAmount() ?? "0.00")"
    }
    
    func addNavigationView(){

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        profileImage = UIImageView(frame: CGRect(x: 2, y: 2, width: 40, height: 40))
        profileImage.isUserInteractionEnabled = true // Enable user interaction

        profileImage.image = UIImage(named: "profileImg")
             //imageView.imageFromServerURL( APIServiceBaseURLType.image.rawValue + UserDataManager.userData.profileImage,placeHolder: UIImage(named: "placeholder"))
        profileImage.layer.cornerRadius = 20
        profileImage.clipsToBounds = true
        view.addSubview(profileImage)
       // Set the custom view as the left navigation item's titleView
   
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.profileAction(_:)))
        profileImage.addGestureRecognizer(tapGesture)

            let middleView = UIView(frame: CGRect(x: 0, y: 0, width: 130, height: 44))

               let label = UILabel(frame: CGRect(x: 0, y: 0, width: 130, height: 18))
               label.text = greetingForTimeOfDay()

               label.textColor = .appGray
                label.textAlignment = .center
                label.font = AppFont.medium(.description)
            
         lblUserName = UILabel(frame: CGRect(x: 0, y: 20, width: 130, height: 20))
        lblUserName.text = "Christina sam"
        lblUserName.textColor = .appBlack
        lblUserName.textAlignment = .center
        lblUserName.font = AppFont.semi(.title)
        middleView.addSubview(label)
        middleView.addSubview(lblUserName)
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(customView: view)
        self.navigationItem.titleView = middleView

    }
    
    func updateProfileInfo(model: ProfileInfoModel) {

        self.lblUserName.text = model.fullName
        
        AppUserDefaults.shared.UDSave(model.userId, forKey: .userId)
        AppUserDefaults.shared.UDSave(model.countryCurrency, forKey: .countryCurrency)

        self.profileImage.sd_setImage(with: model.profileImageUrl, placeholderImage: .none)
        self.contributionViewModel.getMyContributionList(page: "1", limit: "4")
        self.walletViewModel.getWalletBalance()
    }
    
    @objc func profileAction(_ sender: Any) {
        let vc = EditProfileVC(viewModel: ProfileViewModel(userContext: viewModel.getUserContext()), viewModelInfo: VerifyIdentityViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func wokeAPI(_ notification:Notification){
        
        let security = AppUserDefaults.shared.UDValue(.isBiometricEnable) as? String

        if security == "yes"{
            callBioMetric()
        }
    }
    
    @objc func nextNotify(_ notification:Notification){

        let object_dict = notification.object as? NSDictionary
        
        if object_dict != nil{
            
            let data = object_dict!["data"] as? String
            
            if data == "success"{
             
                isInBackground = false
                callAPIData()

                self.dismiss(animated: false, completion: nil)
            }
            else if data == "fail"{
                callBioMetric()
            }
            else{
            }
        }
    }
    
    func callBioMetric(){
        let vc = BioMetricVC()
        self.present(vc, animated: false, completion:nil )
    }
    
    @IBAction func transactionPressed(_ sender:ResponsiveButton){
        let vc = TransactionHistoryVC(viewModel: TransactionViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func walletPressed(_ sender:ResponsiveButton){
        let vc = WalletVC(viewModel: transactionViewModel, walletViewModel: walletViewModel)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func createBlockBtnAction(_ sender: ResponsiveButton) {
        let vc = CreateBlockVC(viewModel: CreateBlockViewModel(userContext: viewModel.getUserContext()))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func joinBlockVCBtnAction(_ sender: ResponsiveButton) {
        let vc = JoinBlockVC(viewModel: JoinBlockViewModel(blockId: "", password: ""))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func showHideBalanceAction(_ sender: ResponsiveButton) {
//        sender.isSelected = !sender.isSelected
//        
        
    }
    
    @IBAction func depositBtnAction(_ sender: ResponsiveButton) {
//        let vc = DepositVC()
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func withdrowBtnAction(_ sender: ResponsiveButton) {
       
//        let vc = EnterAmountVC()
//            vc.comingFrom = "Withdraw"
//        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func viewMoreTransactionsBtnAction(_ sender: ResponsiveButton) {
        let vc = TransactionHistoryVC(viewModel: TransactionViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func SeeMoreBlocks(sender: ResponsiveButton) {
        let vc = AllBlockVC(viewModel: BlockViewModel(type:"all"))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func SeeMoreProperties(sender: ResponsiveButton) {
        let vc = RentalPropertiesVC(viewModel: RentalViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func SeeMoreTransections(sender: ResponsiveButton) {
        let vc = TransactionHistoryVC(viewModel: TransactionViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func greetingForTimeOfDay() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good morning!"
        case 12..<18:
            return "Good afternoon!"
        default:
            return "Good evening!"
        }
    }
}

extension HomeTabVC : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewDidLayoutSubviews()
        return contributionViewModel.getNumberOfRows()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollecCell", for: indexPath) as! HomeCollecCell
          
        let item = contributionViewModel.getNumberOfItem(At: indexPath)
        
            cell.ViewBack.backgroundColor = UIColor(hex: colorsList.colorsForCollectionView    [indexPath.row % 5])
            cell.viewMainBack.backgroundColor = UIColor(hex: colorsList.colorsForCollectionView[indexPath.row % 5])?.withAlphaComponent(0.4)
            cell.lblImg.textColor =  UIColor(hex: colorsList.textColor[indexPath.row % 5])
            cell.lblImg.text = item?.blockData?.blockName?.prefix(2).uppercased()
            cell.lblTitle.text = item?.blockData?.blockName
            cell.lblAmount.text = "\(currency ?? "")\(item?.contributionData?.contributedAmount ?? 0.0)"
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == collecView{
            return CGSize(width: collectionView.frame.size.width / 2.2, height: 100)
        }
        else{
            return CGSize(width: 110, height: 110)
        }
    }
}

extension HomeTabVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblViewBlocks{
            self.viewDidLayoutSubviews()
            return blockViewModel.getNumberOfRows()
        }
        else if tableView == tblViewProperty{
            return propertyViewModel.getNumberOfRows()
        }
        else{
            return transactionViewModel.getNumberOfRows()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tblViewBlocks{
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlockTblViewCell", for: indexPath) as! BlockTblViewCell
            cell.backView.backgroundColor = UIColor(hex: colorsList.colors[indexPath.row % 4])

            let item = blockViewModel.getNumberOfItem(At: indexPath)

            cell.lblTitle.text = item?.blockName
            cell.lblCode.text = item?.referenceCode
            cell.statusLbl.text = item?.statusText
            cell.lblPrice.text = "\((currency ?? ""))\(item?.amount ?? 0)"
            cell.lblDuration.text = item?.depositRules
            cell.lblDescription.text = item?.description
            if !((item?.designation?.isEmpty) != nil) {
                cell.lblDesignation.isHidden = true
                cell.designationView.isHidden = true
            } else {
                cell.lblDesignation.isHidden = false
                cell.lblDesignation.text = item?.designation
            }            
            cell.viewMembersCount.isHidden = Int((item?.blockMemberData?.count ?? "0")) ?? 0 <= 3
            cell.lblMembersCount.text = "\((Int(item?.blockMemberData?.count ?? "0") ?? 0 - 3) - 3 )+"
            
            for i in 0..<(item?.blockMemberData?.memberList?.count ?? 0){
                cell.imgMembers[i].isHidden = false
                cell.imgMembers[i].sd_setImage(with: item?.blockMemberData?.memberList?[i].profileImageUrl, placeholderImage: .none)
            }
            
            cell.statusView.backgroundColor = item?.status == "active" ? .appGreen : .appDarkPink
            
            self.viewDidLayoutSubviews()

            return cell
        }
        else if tableView == tblViewProperty{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RentalPropertiesTableCell", for: indexPath) as! RentalPropertiesTableCell
            
            let item = propertyViewModel.getNumberOfItem(At: indexPath)
            cell.imgView.sd_setImage(with: item?.propertyImageURL)
            cell.lblTitle.text = item?.title
            cell.lblDuration.text = "/\(item?.rentType ?? "")"
            cell.lblDescription.text = item?.description
            cell.lblPrice.text = "\(currency ?? "")\(item?.price ?? "")"
            cell.selectionStyle = .default
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreFooterTblCell") as! SeeMoreFooterTblCell
        
        if tableView == tblViewBlocks{
            cell.btnSeeMore.addTarget(self, action: #selector(SeeMoreBlocks), for: .touchUpInside)
        }
        else if tableView == tblViewProperty{
            cell.btnSeeMore.addTarget(self, action: #selector(SeeMoreProperties), for: .touchUpInside)
        }
        else{
            cell.btnSeeMore.addTarget(self, action: #selector(SeeMoreTransections), for: .touchUpInside)
            
        }
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == tblViewBlocks{
            return blockViewModel.getNumberOfRows() > 3 ? 44 : 0
        }
        else if tableView == tblViewProperty{
            return propertyViewModel.getNumberOfRows() > 1 ? 44 : 0
        }
        else{
            return transactionViewModel.getNumberOfRows() > 3 ? 44 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tblViewBlocks{
            //   let cellVM = viewModel.transactionViewModel.getCellViewModel( at: indexPath )
            
            let item = blockViewModel.getNumberOfItem(At: indexPath)
            
            let vc = BlockDetailsVC(viewModel: BlockDetailViewModel(blockId: item?.blockId ?? "0"), contributionViewModel:  ContributionViewModel(blockId: item?.blockId ?? "0"))
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if tableView == tblViewProperty{
            let item = propertyViewModel.getNumberOfItem(At: indexPath)

            let vc = PropertyDetailsVC(viewModel: RentalViewModel(), propertyId: item?.propertyId ?? "", propertyStatus: "")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            //let cellVM = viewModel.transactionViewModel.getCellViewModel( at: indexPath )

            let item = transactionViewModel.getNumberOfItem(At: indexPath)

            let vc = TransactionDetailVC(viewModel: TransactionViewModel(transactionId: item?.transactionId ?? "0"))
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
