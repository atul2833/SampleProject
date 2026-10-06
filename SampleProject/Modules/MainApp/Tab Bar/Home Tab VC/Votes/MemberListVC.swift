//
//  VotesVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 05/02/24.
//

import UIKit

class MemberListVC:BaseNavigationController {
    
    @IBOutlet weak var collecView:UICollectionView!
    @IBOutlet weak var lblTotalMembers:UILabel!
    
    var comingFrom = String()
    var navigationTitle = String()
    
    private var viewModel: BlockDetailViewModel
    private var candidateId: String
    private var pollId: String


    init(viewModel: BlockDetailViewModel,candidateId:String,pollId: String){
        self.viewModel = viewModel
        self.candidateId = candidateId
        self.pollId = pollId
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
        
        if viewModel.comingFrom == "memberList"{
            viewModel.getBlockMembersList(dict: ["blockId":"","page":"1","limit":"20","type":""])
        }
        else{
            viewModel.getVotersList(dict: ["candidateId":candidateId,"pollId":pollId,"page":"1","limit":"20"])
        }
    }
    
    func initView() {
//        self.navigationItem.title = "Votes for Block Manager"
        self.navigationItem.title = viewModel.comingFrom == "memberList" ? "Block Members" : "Voted Members"
        collecView.register(UINib(nibName: "MemberCollViewCell", bundle: nil), forCellWithReuseIdentifier: "MemberCollViewCell")

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
        lblTotalMembers.text = "TOTAL MEMBERS (\(viewModel.getMemberCount() ?? ""))"
        DispatchQueue.main.async {
            self.collecView.reloadData()
        }
    }
    
    @IBAction func continueBtnAction(_ sender:ResponsiveButton){
        let vc = AccountActivateVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MemberListVC : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getNumberOfRowsForBlockMembers()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCollViewCell", for: indexPath) as! MemberCollViewCell
          
        let item = viewModel.getNumberOfItemForBlockMembers(At: indexPath)
            cell.imgView.sd_setImage(with: item?.profileImageUrl, placeholderImage: .none)

            cell.lblTitle.text = item?.fullName
            cell.lblStatus.text = ""//list.status
            cell.centerTitle.constant = 0//list.status == "" ? 0 : -10
            
            cell.viewNotification.isHidden = true
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       // sendSwitchAction(slug: slug)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width) / 2, height: 60)
    }
    
}


