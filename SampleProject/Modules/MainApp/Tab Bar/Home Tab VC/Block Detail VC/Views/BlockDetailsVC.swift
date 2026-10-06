//
//  BlockDetialsVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 02/02/24.
//

import UIKit

class BlockDetailsVC: BaseNavigationController {
        
    @IBOutlet weak var btnDeposite: UIButton!
    @IBOutlet weak var BtnLeave: UIButton!
    @IBOutlet weak var heightTblView:NSLayoutConstraint!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnJoin:UIButton!
    @IBOutlet weak var leaveDepositHeightCons: NSLayoutConstraint!
    @IBOutlet weak var requestBtnHeightCons: NSLayoutConstraint!
    @IBOutlet weak var bottomTblView: NSLayoutConstraint!
    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var viewBtns: UIView!

    var comingFrom = String()
    var countryCurrency = (AppUserDefaults.shared.UDValue(.countryCurrency) as? String) ?? "$"
    
    private var viewModel: BlockDetailViewModel
    private var contributionViewModel: ContributionViewModel

    init(viewModel: BlockDetailViewModel,contributionViewModel: ContributionViewModel){
        self.viewModel = viewModel
        self.contributionViewModel = contributionViewModel

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
        stateObserver()
        contributionStateObserver()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDataFromAPI()
    }
    
    func getDataFromAPI(){
        viewModel.getBlockDetail()
        self.contributionViewModel.blockLoansList(page: "1", limit: "5")
    }
    func initView() {
        self.navigationItem.title = "Block Details"
        self.navigationController?.navigationBar.backgroundColor = .white
        
        tblView.register(UINib(nibName: "BlockDetailsTblCell", bundle: nil), forCellReuseIdentifier: "BlockDetailsTblCell")
        tblView.register(UINib(nibName: "VoteResultTblCell", bundle: nil), forCellReuseIdentifier: "VoteResultTblCell")
        tblView.register(UINib(nibName: "TitleHeaderTblCell", bundle: nil), forCellReuseIdentifier: "TitleHeaderTblCell")
        tblView.register(UINib(nibName: "SeeMoreFooterTblCell", bundle: nil), forCellReuseIdentifier: "SeeMoreFooterTblCell")
        tblView.register(UINib(nibName: "TotalValueTblCell", bundle: nil), forCellReuseIdentifier: "TotalValueTblCell")
        tblView.register(UINib(nibName: "TotalAmountTblCell", bundle: nil), forCellReuseIdentifier: "TotalAmountTblCell")
        tblView.register(UINib(nibName: "VoteForTblCell", bundle: nil), forCellReuseIdentifier: "VoteForTblCell")
        tblView.register(UINib(nibName: "TotalMembersTblCell", bundle: nil), forCellReuseIdentifier: "TotalMembersTblCell")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
      //  viewVotingResultView.addGradientToViewTopToBottom(colors: [UIColor.subscriptionGredient1,UIColor.subscriptionGredient2])
    }
    
    private func stateObserver(){
        self.viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .success:
                    break
                case .detailsFetched:
                    self?.handleData()
                case .membersListFetched:
                    self?.tblView.reloadData()
                case .requestJoinBlock:
                    self?.viewModel.getBlockDetail()
                    break
                case .goForVote:
                    self?.getDataFromAPI()
                    self?.callAPIAfterVotingCount()
                    self?.tblView.reloadData()
                    break
                case .leaveBlock(let message):
                    self?.showAlert(message: message)
                    break
                case .payment(let transactionId):
                    self?.goToTransactionDetail(transactionId: transactionId)
                    break
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
            .store(in: &self.contributionViewModel.cancellable)
    }
    
    
    func goToTransactionDetail(transactionId:String){
        let vc = TransactionDetailVC(viewModel: TransactionViewModel(transactionId: transactionId))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleContributionsData(){
        self.tblView.reloadData()
    }
    func handleData(){
        
        let blockData = viewModel.getBlockData()
        
        let blockType = blockData?.statusStage
        viewModel.blockType = blockType ?? ""
        
        if blockType == "globleBlock"{
            requestBtn.isHidden = false
            requestBtn.isEnabled = true
            bottomTblView.constant = 75
            
            getBlockMembersList()
        }
        else if blockType == "requestedBlock"{
            requestBtn.isHidden = false
            requestBtn.setTitle("Requested to Join", for: .normal)
            requestBtn.backgroundColor = UIColor.appGrayBackground
            requestBtn.isEnabled = false
            bottomTblView.constant = 75
            getBlockMembersList()
        }
        else if blockType == "active"{
            
            if viewModel.getBlockData()?.isVotingResultComing ?? false{
                viewModel.getVotingResult()
            }
            getBlockMembersList()
            bottomTblView.constant = 75
            viewBtns.isHidden =  false
            requestBtn.isHidden = true
    
        }
        else if blockType == "inActiveWithVotingCount"{
            requestBtn.isHidden = false
            requestBtn.setTitle("Leave Block", for: .normal)
            requestBtn.isEnabled = true
            bottomTblView.constant = 75
            
            callAPIAfterVotingCount()
        }
        else{
            getBlockMembersList()
        }
        
        if viewModel.getBlockData()?.canSendInvitation ?? false{
            requestBtn.isHidden = false
            requestBtn.setTitle("Invite", for: .normal)
            requestBtn.isEnabled = true
            bottomTblView.constant = 75
        }
        self.tblView.reloadData()
    }
    
    func callAPIAfterVotingCount(){
        viewModel.getBlockMembersList(dict: ["blockId":"","page":"1","limit":"4","type":"blockManager"])
        viewModel.getBlockMembersList(dict: ["blockId":"","page":"1","limit":"4","type":"assistantManager"])
    }
    
    func getBlockMembersList(){
        viewModel.getBlockMembersList(dict: ["blockId":"","page":"1","limit":"10","type":""])
    }
    
    @IBAction func requestBtnAction(_ sender:ResponsiveButton){
        let blockData = viewModel.getBlockData()
        
        let blockType = blockData?.statusStage
        
        if viewModel.getBlockData()?.canSendInvitation ?? false{
            let vc = MyContactsVC(viewModel: MyContactsViewModel(blockId: viewModel.blockId))
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if blockType == "inActiveWithVotingCount"{
            showLeavePopup()
        }
        else{
            viewModel.requestJoinBlock()
        }
    }
    
    @IBAction func viewDetailMoneyBtnAction(_ sender:ResponsiveButton){
//        let vc = ContributionDetailVC()
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func leaveBtnPressed(_ sender: UIButton) {
        showLeavePopup()
    }
   
    func showAlert(message:String){
        let vc = CustomAlertInfoView()
            vc.comingTitle = "Successfull"
            vc.comingDescription = message
            vc.comingImage = "Group 71526"
            vc.alertConfirm = self
        self.presentOnViewController(with: vc)
    }
   
    func showLeavePopup(){
        let vc = CustomAlertListVC(viewModel: CustomAlertListViewModel(type: "leaveBlock"))
            vc.comingImage = "Group 71527"
            vc.alertConfirm = self
            vc.yesBtnTitle = "Yes, Leave"
        self.navigationController?.pushViewController(vc, animated: true)
        //self.presentOnViewController(with: vc)
    }
    
    @IBAction func depositBtnPressed(_ sender: Any) {
        
        if viewModel.getBlockData()?.isLateChargeAplied == false {
            let vc = CustomAlertConfirmVC()
            vc.comingTitle = "Deposit \(viewModel.getBlockData()?.amount ?? 0)"
            vc.comingDescription = "Are you sure you want to deposit to \(viewModel.getBlockData()?.blockName ?? "")?"
            vc.comingImage = "Group 71530"
            vc.alertConfirm = self
            vc.yesBtnTitle = "Deposit"
            self.presentOnViewController(with: vc)
        } else {
            let vc = DepositeAmountVC(viewModel: BlockDetailViewModel(blockId: viewModel.blockId), viewModelDeposit: DepositeAmountViewModel(blockId: viewModel.blockId, transactionId: viewModel.getNumberOfTransactionId() ?? ""))
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @objc func seeMoreMembersAction(_ sender: ResponsiveButton) {
        let vc = MemberListVC(viewModel: BlockDetailViewModel(blockId: viewModel.blockId,comingFrom: "memberList"), candidateId: "0", pollId: "")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func footerButtonTapped1(sender: ResponsiveButton) {
        let vc = ContributionDetailVC(viewModel: ContributionViewModel(blockId: viewModel.blockId), walletViewModel: WalletViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func btnVoteResultCancelTapped(_ sender: ResponsiveButton) {
        viewModel.updateVotingResultSettings()
    }
    
    private func handleVoteCountSelection(index: String?,candidateId:String?){
        viewModel.goForVote(dict: ["blockId":"","pollId":index == "5" ? viewModel.getPollIdManager() ?? "0": viewModel.getPollIdAsstManager() ?? "0","candidateId":candidateId ?? "0"])
    }
    
    private func handleDetailSelection(index: String?,candidateId:String?,pollId: String?){
        if index == "0"{
            self.view.makeToast("Not voted yet!")
        }
        else{
            let vc = MemberListVC(viewModel: BlockDetailViewModel(blockId: viewModel.blockId,comingFrom: "voterList"), candidateId: candidateId ?? "0", pollId: pollId ?? "")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func handleViewMoreSelection(index: String?){
        let vc = VotingForVC(viewModel: BlockDetailViewModel(blockId: viewModel.blockId,comingFrom: "voterList"), index: index ?? "5")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension BlockDetailsVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
        }
        else if section == 1{
            let contributionData = contributionViewModel.getContributionData()
            
            return (viewModel.blockType == "active") ? 1 : (viewModel.blockType == "globleBlock" && contributionData?.totalBlockValue ?? 0 > 0) ?  1 : (contributionData?.totalBlockValue ?? 0 > 0) ?  1 : 0
        }
        else if section == 2{
            return viewModel.blockType == "active" && contributionViewModel.getNumberOfRowsDetail() != 0 ? 1 : 0
        }
        else if section == 3{
            return viewModel.getBlockData()?.isVotingResultComing ?? false ? 1 : 0
        }
        else if section == 4{
            return viewModel.blockType != "inActiveWithVotingCount" ? 1 : 0
        }
        else{
            return viewModel.blockType == "inActiveWithVotingCount" ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlockDetailsTblCell", for: indexPath) as! BlockDetailsTblCell
            
            let item = viewModel.getBlockData()
            
            let isActivated = item?.status == "active" && (item?.isABlockMember ?? false)
            
            cell.lblTitle.text = item?.blockName
            cell.lblCode.text = item?.referenceCode
            cell.statusLbl.text = item?.statusText
            cell.lblPrice.text = "\(countryCurrency)\(item?.amount ?? 0)"
            cell.lblDuration.text = item?.duration
            cell.lblDescription.text = item?.description
            cell.lblLocation.text = item?.city
            cell.lblDepositRules.text = item?.depositRules
            cell.lblTime.text = ""//item?.createdAt
            cell.lblCreatedDate.text = item?.status == "active" ? item?.dateOfActivation?.dateStringToDateString() : item?.createdAt?.dateStringToDateString()
            cell.lblPaymentDue.text = item?.paymentDueDate
            cell.lblUnit.text = "\(item?.totalNumberOfUnit ?? 1)"
            cell.lblMode.text = item?.statusStage == "leaved" ? "Available for SWAP" : item?.statusStage == "left" ? "Available for SWAP" : ""

            cell.viewMode.isHidden = item?.statusStage == "leaved" ? false : item?.statusStage == "left" ? false : true
            cell.lblDateTitle.text = item?.status == "active" ? "Activation Date" : "Creation Date"

            cell.viewPayment.isHidden = !isActivated
            cell.viewUnit.isHidden = !isActivated
            
            cell.viewMembersCount.isHidden = Int(item?.blockMemberData?.count ?? "0") ?? 0 <= 3
    //        cell.lblMembersCount.text = "\(Int(item?.blockMemberData?.count ?? "0") ?? 0 - 3)+"
            cell.lblMembersCount.text = "\((Int(item?.blockMemberData?.count ?? "0") ?? 0 - 3) - 3 )+"
            cell.bottomFromPayment.constant = isActivated ? 110 : 10
            for i in 0..<(item?.blockMemberData?.memberList?.count ?? 0){
                cell.imgMembers[i].isHidden = false
                cell.imgMembers[i].sd_setImage(with: item?.blockMemberData?.memberList?[i].profileImageUrl, placeholderImage: .none)
            }
            
            cell.statusView.backgroundColor = item?.status == "active" ? .appGreen : .appDarkPink
            cell.viewMode.backgroundColor = item?.statusStage == "leaved" ? .appLightRed : item?.statusStage == "left" ? .appLightRed : .clear
            cell.lblMode.textColor = item?.statusStage == "leaved" ? .appDarkPink : item?.statusStage == "left" ? .appDarkPink : .clear
            
            return cell
        }
        else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TotalValueTblCell", for: indexPath) as! TotalValueTblCell
            let item = contributionViewModel.getContributionData()
            
                cell.lblContributedMoney.text = "\(countryCurrency)\(item?.totalContribution ?? 0.00)"
                cell.lblTotalBlockVal.text = "\(countryCurrency)\(item?.totalBlockValue ?? 0.00)"
            
            return cell
        }
        else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TotalAmountTblCell", for: indexPath) as! TotalAmountTblCell
            cell.viewModel = contributionViewModel
            DispatchQueue.main.async {
                cell.reloadData()
            }

            return cell
        }
        else if indexPath.section == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: "VoteResultTblCell", for: indexPath) as! VoteResultTblCell
            
            cell.backView.addGradientToViewTopToBottom(colors: [UIColor.subscriptionGredient1,UIColor.subscriptionGredient2])
            cell.itemActionDetail =  handleDetailSelection(index:candidateId:pollId:)
            cell.btnCancel.addTarget(self, action: #selector(btnVoteResultCancelTapped(_:)), for: .touchUpInside)

            cell.viewModel = viewModel

            cell.reloadData()

            return cell
        }
        else if indexPath.section == 4{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TotalMembersTblCell", for: indexPath) as! TotalMembersTblCell
            let item = viewModel.getNumberOfRowsForBlockMembers()
            if item > 10 {
                cell.seeMoreMembers.isHidden = false
                cell.lblSeeMore.isHidden = false
                cell.seeMoreMembers.addTarget(self, action: #selector(seeMoreMembersAction(_:)), for: .touchUpInside)
            } else {
                cell.lblSeeMore.isHidden = true
                cell.seeMoreMembers.isHidden = true
            }
            cell.viewModel = viewModel
            cell.reloadData()

            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "VoteForTblCell", for: indexPath) as! VoteForTblCell
            
            cell.itemActionVoteCount =  handleVoteCountSelection(index:candidateId:)
            cell.itemActionDetail =  handleDetailSelection(index:candidateId:pollId:)
            cell.itemActionViewMore =  handleViewMoreSelection(index:)

            cell.index = indexPath.section
            cell.viewModel = viewModel
            cell.reloadData()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 || indexPath.section == 2 ? UITableView.automaticDimension
        : indexPath.section == 3 ? (150 * CGFloat(viewModel.getNumberOfRowsForVotingResult()) + 60) : indexPath.section == 4 ? (60 * CGFloat(((viewModel.getNumberOfRowsForBlockMembers() + 1) / 2)) + 100) : indexPath.section == 1 ? 80 : (indexPath.section == 5 ? ((viewModel.getNumberOfRowsForBlockMembersManager() ) > 0 ? 440 : 0) : (((viewModel.getNumberOfRowsForBlockMembersAsstManager() ) != 0) ? 440 : 0))
        
        // return indexPath.section == 0 || indexPath.section == 2 ? UITableView.automaticDimension
       // : indexPath.section == 3 ? (150 * CGFloat(viewModel.getNumberOfRowsForVotingResult()) + 60) : indexPath.section == 4 ? (60 * CGFloat(((viewModel.getNumberOfRowsForBlockMembers() + 1) / 2)) + 100) : indexPath.section == 1 ? 80 : 440
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
         if section == 1{
             if viewModel.blockType == "active"{
                 let cell = tableView.dequeueReusableCell(withIdentifier: "TitleHeaderTblCell") as! TitleHeaderTblCell
                 cell.lblTitle.text = "THE TOTAL VALUE OF THE BLOCK"
                 cell.backView.backgroundColor = UIColor.white
                 cell.backLabel.backgroundColor = UIColor.systemGray5
                 return cell.contentView
             }
        }
        else if section == 2{
            if viewModel.blockType == "active" && contributionViewModel.getNumberOfRowsDetail() != 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "TitleHeaderTblCell") as! TitleHeaderTblCell
                cell.lblTitle.text =  "TOTAL CREDITED AMOUNT"
                cell.backView.backgroundColor = UIColor.white
                cell.backLabel.backgroundColor = UIColor.systemGray5
                return cell.contentView
            }
        }
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            if viewModel.blockType == "active"{
                return 30
            }
       }
       else if section == 2{
           if viewModel.blockType == "active" && contributionViewModel.getNumberOfRowsDetail() != 0{
               return 30
           }
       }
       return 0
       
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2 {
            if viewModel.blockType == "active" && contributionViewModel.getNumberOfRowsDetail() != 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreFooterTblCell") as! SeeMoreFooterTblCell
                cell.backView.backgroundColor = UIColor.white
                cell.btnSeeMore.addTarget(self, action: #selector(footerButtonTapped1), for: .touchUpInside)
                return cell.contentView
            }
        }
        return UIView(frame: .zero)
    }
  
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            if viewModel.blockType == "active" && contributionViewModel.getNumberOfRowsDetail() != 0{
                return 30
            }
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //   let cellVM = viewModel.transactionViewModel.getCellViewModel( at: indexPath )

//           let vc = VotesVC()
//           //    vc.transactionId = cellVM.transactionId
//           self.navigationController?.pushViewController(vc, animated: true)
       }
}


extension BlockDetailsVC:AlertConfimDelegate{
    func alertAction(_ status: String) {
        if status.contains("Deposit"){
            viewModel.goForPayment()
        }
        else{
            viewModel.leaveBlock(dict: ["blockId":viewModel.blockId])

//            let vc = BlockTabVC(viewModel: BlockViewModel())
//                    vc.transactionId = cellVM.transactionId
//self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension BlockDetailsVC: AlertInfoDelegate{
    func alertInfoAction(_ status: String) {
        self.navigationController?.popViewController(animated: true)
    }
}

struct UserData: Decodable {
    var id: Int = 0
    var name:String = ""
    var countryCode: String = ""
    var phoneNumber: String = ""
    var emailAddress: String = ""
    var profileImage: String = ""
    var deviceToken: String = ""
    var deviceType: String = ""
    var isPINDone: String = ""
    var notificationEnabled:String = ""
    var QRCode : String = ""
    var isEmailVerify: String = ""
    var isKYCDone: String = ""
    var slug: String = ""
    var status: String = ""
    var kyc_info: [KYCDetailList] = []
}

struct OpponentData: Decodable {
    let id: Int
    let name:String
    let countryCode: String
    let phoneNumber: String
    let emailAddress: String
    let profileImage: String
    let amount: String
    let notes: String
    var QRCode : String
 //   let lean_info: lean_info
}
