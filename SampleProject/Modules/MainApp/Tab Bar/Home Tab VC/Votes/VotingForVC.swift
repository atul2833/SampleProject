//
//  VotingForVC.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 19/03/24.
//

import UIKit

class VotingForVC:BaseNavigationController {
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var backView:UIView!
    @IBOutlet weak var lblBottomDescription:UILabel!
    
    var comingFrom = String()
    var navigationTitle = String()
    
    private var viewModel: BlockDetailViewModel
    private var index: String

    init(viewModel: BlockDetailViewModel,index:String){
        self.viewModel = viewModel
        self.index = index
        
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
        
        self.navigationItem.title = "Votes for \(index == "5" ? "" : "Assistant ") Manager"
        
        callAPIAfterVotingCount()
    }
    
    func initView() {
//        self.navigationItem.title = "Votes for Block Manager"
        self.navigationItem.title = viewModel.comingFrom == "memberList" ? "Block Members" : ""
        tblView.register(UINib(nibName: "MemberBlockTblCell", bundle: nil), forCellReuseIdentifier: "MemberBlockTblCell")
        tblView.register(UINib(nibName: "TitleHeaderTblCell", bundle: nil), forCellReuseIdentifier: "TitleHeaderTblCell")
        tblView.register(UINib(nibName: "SeeMoreFooterTblCell", bundle: nil), forCellReuseIdentifier: "SeeMoreFooterTblCell")
        tblView.removeExtraTopPadding()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
       // heightCollView.constant = CGFloat((allSubcriptionViews.count / 2) * 65)
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
                case .detailsFetched:
                    break
                case .membersListFetched:
                    self?.handleData()
               
                case .requestJoinBlock:
                    self?.viewModel.getBlockDetail()
                    break
                case .goForVote:
                    self?.callAPIAfterVotingCount()
                    self?.tblView.reloadData()
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
    
    func handleData(){
        
        lblBottomDescription.text = index == "5" ? viewModel.getMemberExpirtTimeManager() ?? "" : viewModel.getMemberExpirtTimeAsstManager() ?? ""
        
        DispatchQueue.main.async {
            self.tblView.reloadData()
        }
    }
    
    func callAPIAfterVotingCount(){
        viewModel.getBlockMembersList(dict: ["blockId":"","page":"1","limit":"10","type":index == "5" ? "blockManager" : "assistantManager","pollId":index == "5" ? viewModel.getPollIdManager() ?? "0": viewModel.getPollIdAsstManager() ?? "0"])
    }
    
    @IBAction func continueBtnAction(_ sender:ResponsiveButton){
        let vc = AccountActivateVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension VotingForVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return index == "5" ? viewModel.getNumberOfRowsForBlockMembersManager(): viewModel.getNumberOfRowsForBlockMembersAsstManager()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberBlockTblCell", for: indexPath) as! MemberBlockTblCell
        
        let item = index == "5" ? viewModel.getNumberOfItemForBlockMembersManager(At: indexPath) : viewModel.getNumberOfItemForBlockMembersAsstManager(At: indexPath)

        cell.imgUser.sd_setImage(with: item?.profileImageUrl, placeholderImage: .none)

        cell.lblName.text = item?.fullName
        cell.lblVoteCount.text = "\(item?.voteCount ?? "0" == "0" || item?.voteCount ?? "0" == "1" ? "\(item?.voteCount ?? "0") Vote" : "\(item?.voteCount ?? "0") Votes")"
        
        cell.btnForVote.tag = Int(item?.userId ?? "0") ?? 0
        cell.btnForVote.addTarget(self, action: #selector(btnForVoteAction(_:)), for: .touchUpInside)

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleHeaderTblCell") as! TitleHeaderTblCell
        cell.lblTitle.text = "TOP \(index == "5" ? viewModel.getMemberCountMananger() ?? "0": viewModel.getMemberCountAsstManager() ?? "0") MEMBERS"
    //    cell.backView.backgroundColor = UIColor.white
        cell.backLabel.backgroundColor = UIColor.systemGray5
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = index == "5" ? viewModel.getNumberOfItemForBlockMembersManager(At: indexPath) : viewModel.getNumberOfItemForBlockMembersAsstManager(At: indexPath)
        
        if item?.voteCount != "0"{
            let vc = MemberListVC(viewModel: BlockDetailViewModel(blockId: viewModel.blockId,comingFrom: "voterList"), candidateId: item?.userId ?? "0", pollId: (index == "5" ? viewModel.getPollIdManager() : viewModel.getPollIdAsstManager()) ?? "")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            self.view.makeToast("Not voted yet!")
        }

    }
    
    @objc func btnForVoteAction(_ sender: ResponsiveButton) {
        viewModel.goForVote(dict: ["blockId":"","pollId":index == "5" ? viewModel.getPollIdManager() ?? "0": viewModel.getPollIdAsstManager() ?? 0,"candidateId":"\(sender.tag)"])
    }
}
