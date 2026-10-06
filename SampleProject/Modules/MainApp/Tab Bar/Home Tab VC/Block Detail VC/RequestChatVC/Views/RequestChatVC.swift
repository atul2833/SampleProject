
import UIKit

class RequestChatVC: BaseNavigationController{
    
    @IBOutlet weak var heightTblView:NSLayoutConstraint!

    @IBOutlet weak var tblView:UITableView!
    
    @IBOutlet weak var btnJoin:UIButton!
    
    @IBOutlet weak var leaveDepositHeightCons: NSLayoutConstraint!
    @IBOutlet weak var requestBtnHeightCons: NSLayoutConstraint!
    
    @IBOutlet weak var bottomTblView: NSLayoutConstraint!

    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var viewBtns: UIView!

    var comingFrom = String()
    
    private var viewModel: BlockDetailViewModel
    private var contributionViewModel: ContributionViewModel
    private var requestChatViewModel: RequestChatViewModel
    private var currency = AppUserDefaults.shared.UDValue(.countryCurrency) as? String

    init(viewModel: BlockDetailViewModel,contributionViewModel: ContributionViewModel,requestChatViewModel:RequestChatViewModel){
        self.viewModel = viewModel
        self.contributionViewModel = contributionViewModel
        self.requestChatViewModel = requestChatViewModel

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
        ChatStateObserver()
        initView()
        viewModel.getBlockDetail()
        requestChatViewModel.getRequestChat()
        self.contributionViewModel.blockLoansList(page: "1", limit: "5")
    }
    
    func initView() {
        self.title = "Request for Swap"
        self.navigationController?.navigationBar.backgroundColor = .white
        tblView.register(UINib(nibName: "BlockDetailsTblCell", bundle: nil), forCellReuseIdentifier: "BlockDetailsTblCell")
        tblView.register(UINib(nibName: "TitleHeaderTblCell", bundle: nil), forCellReuseIdentifier: "TitleHeaderTblCell")
        tblView.register(UINib(nibName: "TotalValueTblCell", bundle: nil), forCellReuseIdentifier: "TotalValueTblCell")
        tblView.register(UINib(nibName: "AmountTableCellVC", bundle: nil), forCellReuseIdentifier: "AmountTableCellVC")
        tblView.register(UINib(nibName: "TotalAmtTableViewCell", bundle: nil), forCellReuseIdentifier: "TotalAmtTableViewCell")
        tblView.register(UINib(nibName: "SeeMoreFooterTblCell", bundle: nil), forCellReuseIdentifier: "SeeMoreFooterTblCell")
        
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
                    self?.tblView.reloadData()
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
                }
            }
            .store(in: &self.contributionViewModel.cancellable)
    }
    
    private func ChatStateObserver() {
        self.requestChatViewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .success(let groupId):
                    self?.sendToMessageDetail(groupId: groupId)
                    break
                case .leaveMemberDetails:
                    self?.tblView.reloadData()
                    break
                case .error(let message):
                    Log.error(message)
                    self?.view.makeToast(message, position: .bottom)
                case .logout:
                    let tabBar = self?.tabBarController as? HomeTabBarController
                    tabBar?.logout()

                }
            }
            .store(in: &self.requestChatViewModel.cancellable)
    }
    
    func sendToMessageDetail(groupId: String?) {
        var item = MessageResponseSubDataModel()
        var messageData = MessageDataModel()
        messageData.groupId = groupId
        item.blockData = viewModel.getBlockData()
        item.messageData = messageData
        let vc = MessageDetailVC(viewModel: MessageViewModel(), messageData: item, type: item.messageData?.contentType ?? "")
        self.navigationController?.pushViewController(vc, animated: true)
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
        self.tblView.reloadData()
    }
    

    func getBlockMembersList(){
        viewModel.getBlockMembersList(dict: ["blockId":"","page":"1","limit":"10","type":""])
    }
    
   
    @IBAction func depositBtnPressed(_ sender: Any) {
        if requestChatViewModel.isSwapRequest == true {
            requestChatViewModel.swapRequest()
        } else {
            
            let vc = CustomAlertListVC(viewModel: CustomAlertListViewModel(type: "swapBlock"))
            vc.comingImage = "joinBlock"
            vc.alertConfirm = self
            vc.yesBtnTitle = "Yes, Request"
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
    
    private func handleDetailSelection(index: String?,candidateId:String?){
        if index == "0"{
            self.view.makeToast("Not voted yet!")
        }
        else{
            let vc = MemberListVC(viewModel: BlockDetailViewModel(blockId: viewModel.blockId,comingFrom: "voterList"), candidateId: candidateId ?? "0", pollId: "")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func handleViewMoreSelection(index: String?){
        let vc = VotingForVC(viewModel: BlockDetailViewModel(blockId: viewModel.blockId,comingFrom: "voterList"), index: index ?? "5")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension RequestChatVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        else if section == 1{
            return viewModel.blockType == "active" || (contributionViewModel.getContributionData()?.totalBlockValue ?? 0 > 0) ? 1 : 0
        }
        else if section == 2{
            return requestChatViewModel.getNumberOfAmountList() ?? .zero
        } else {
            return 1
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
            cell.lblPrice.text = "\(currency ?? "")\(item?.amount ?? 0)"
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
            
                cell.lblContributedMoney.text = "\(currency ?? "")\(item?.totalContribution ?? 0.00)"
                cell.lblTotalBlockVal.text = "\(currency ?? "")\(item?.totalBlockValue ?? 0.00)"
            
            return cell
        } else if indexPath.section == 2 {
            let cell = tblView.dequeueReusableCell(withIdentifier: "AmountTableCellVC", for: indexPath) as! AmountTableCellVC
            let item = requestChatViewModel.getNumberOfItemForAmount(At: indexPath)
            cell.lblTitle.text = item?.title
            cell.lblSubTitle.text = item?.type == "amount" ? "\(currency ?? "")\(item?.value ?? "")" : item?.type == "date" ? "\((item?.value ?? "").dateStringToString())" : item?.value
            
            return cell
        } else if indexPath.section == 3 {
            let cell = tblView.dequeueReusableCell(withIdentifier: "TotalAmtTableViewCell", for: indexPath) as! TotalAmtTableViewCell
                    
                if let item = requestChatViewModel.getNumberOfItemForAmounts(At: indexPath) {
                    cell.lblSubTitle.text = "\(currency ?? "")\(item.totalAmountPay ?? "")"

                }
                
                return cell
        }
       return UITableViewCell()
    }
    
//        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//            return indexPath.section == 0 || indexPath.section == 2 ? UITableView.automaticDimension
//            : indexPath.section == 3 ? (150 * CGFloat(viewModel.getNumberOfRowsForVotingResult()) + 60) : indexPath.section == 4 ? (200 * CGFloat((((requestChatViewModel.getNumberOfAmountList() ?? 200) + 1) / 2)) + 100) : indexPath.section == 1 ? 80 : (indexPath.section == 5 ? ((viewModel.getNumberOfRowsForBlockMembersManager() ) > 0 ? 440 : 0) : (((viewModel.getNumberOfRowsForBlockMembersAsstManager() ) != 0) ? 440 : 0))
//
//             return indexPath.section == 0 || indexPath.section == 2 ? UITableView.automaticDimension
//            : indexPath.section == 3 ? (150 * CGFloat(viewModel.getNumberOfRowsForVotingResult()) + 60) : indexPath.section == 4 ? (60 * CGFloat(((viewModel.getNumberOfRowsForBlockMembers() + 1) / 2)) + 100) : indexPath.section == 1 ? 80 : 440
//        }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
         if section == 1{
             if viewModel.blockType == "active" || contributionViewModel.getContributionData()?.totalBlockValue ?? 0 > 0{
                 let cell = tableView.dequeueReusableCell(withIdentifier: "TitleHeaderTblCell") as! TitleHeaderTblCell
                 cell.lblTitle.text = "THE TOTAL VALUE OF THE BLOCK"
                 cell.backView.backgroundColor = UIColor.white
                 cell.backLabel.backgroundColor = UIColor.systemGray5
                 return cell.contentView
             }
        }
        else if section == 2{
            if viewModel.blockType == "active"{
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
           if viewModel.blockType == "active"{
               return 30
           }
       }
       return 0
       
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2 {
            if viewModel.blockType == "active"{
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
            if viewModel.blockType == "active"{
                return 30
            }
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

       }
}

extension RequestChatVC:AlertConfimDelegate{
    func alertAction(_ status: String) {
        requestChatViewModel.swapRequest()
    }
}

extension RequestChatVC: AlertInfoDelegate{
    func alertInfoAction(_ status: String) {
        self.navigationController?.popViewController(animated: true)
    }
}





  
