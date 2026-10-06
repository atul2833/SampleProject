//
//  SubscriptionVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 02/02/24.
//

import UIKit

class SubscriptionVC: BaseNavigationController {

    @IBOutlet weak var backView:UIView!
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var heightCollView:NSLayoutConstraint!
    @IBOutlet weak var heightTblView:NSLayoutConstraint!

    @IBOutlet weak var collecView:UICollectionView!
    @IBOutlet weak var lblListTitle:UILabel!

    private var viewModel: SubscriptionViewModel
    
    init(viewModel: SubscriptionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log.info("====== \(self) ======")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        stateObserver()
        self.viewModel.getPlans()
        isBackToPreviousScreen = true
        // Do any additional setup after loading the view.
    }
    
    func initView() {
        
        collecView.register(UINib(nibName: "SubscriptionCollCell", bundle: nil), forCellWithReuseIdentifier: "SubscriptionCollCell")
        
        tblView.register(UINib(nibName: "SubscriptionTblCell", bundle: nil), forCellReuseIdentifier: "SubscriptionTblCell")

        tblView.tableFooterView = UIView()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let numberOfItems = viewModel.getNumberOfRows()
        let numberOfRows = (numberOfItems + 1) / 2

        let cellWidth = (collecView.bounds.width) / 2
        let cellHeight = (collecView.bounds.width - 30) / 2

        heightCollView.constant = CGFloat(numberOfRows) * cellHeight

        heightTblView.constant = tblView.contentSize.height

        backView.addGradientToViewTopToBottom(
            colors: [
                UIColor.subscriptionGredient1,
                UIColor.subscriptionGredient2
            ]
        )
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        heightCollView.constant = CGFloat((((self.viewModel.getNumberOfRows() + 1) / 2) * 180) )
//        heightTblView.constant = tblView.contentSize.height
//        backView.addGradientToViewTopToBottom(
//            colors: [
//                UIColor.subscriptionGredient1,
//                UIColor.subscriptionGredient2
//            ]
//        )
//    }
    
    private func stateObserver() {
        viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &viewModel.cancellable)
    }
    
    private func handleState(_ state: SubscriptionViewModel.State) {
        
        switch state {
            case .loading:
                ProgressHudWrapper.loadingIndicator()
            case .successList:
                ProgressHudWrapper.succeed()
                handleSuccessList()
            case .success:
                ProgressHudWrapper.dismiss()
                handleSuccess()
            case .error(let message):
                ProgressHudWrapper.dismiss()
                view.makeToast(message, position: .bottom)
            default:
                ProgressHudWrapper.dismiss()
        }
    }
    
    private func handleSuccessList(){
        if viewModel.getNumberOfRows() > 0{
            self.viewModel.subscriptionModel[0].selected = true
            self.viewModel.descriptionList = self.viewModel.subscriptionModel[0].descriptionList ?? []
            self.lblListTitle.text = self.viewModel.subscriptionModel[0].name
        }
        
        self.collecView.reloadData()
        self.tblView.reloadData()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        self.viewDidLayoutSubviews()
        
    }
    
    private func handleSuccess() {
        ProgressHudWrapper.succeed()
        
        let vc = AccountActivateVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func continueBtnAction(_ sender:ResponsiveButton){
        
        for i in 0..<self.viewModel.getNumberOfRows() {
            if self.viewModel.subscriptionModel[i].selected ?? false{
                self.viewModel.updatePlan(planId: self.viewModel.subscriptionModel[i].id ?? "")
                break
            }
        }
        
    }
}

extension SubscriptionVC : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.getNumberOfRows()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubscriptionCollCell", for: indexPath) as! SubscriptionCollCell
          
        let list = self.viewModel.getItem(At: indexPath)
            cell.imgView.image = UIImage(resource: list?.selected ?? false ? .iconTicked : .iconTick)
            cell.lblTitle.text = list?.name
            cell.lblType.text = list?.duration
            cell.lblPrice.text = list?.price
            cell.backView.backgroundColor = list?.selected ?? false ? .white : .clear
            cell.lblPrice.textColor = list?.selected ?? false ? .black : .appBase
            cell.lblType.textColor = list?.selected ?? false ? .black : .appBase
            cell.lblTitle.textColor = list?.selected ?? false ? .black : .appGray
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        for i in 0..<self.viewModel.getNumberOfRows() {
            self.viewModel.subscriptionModel[i].selected = false
        }
        
        self.viewModel.subscriptionModel[indexPath.row].selected = !(self.viewModel.subscriptionModel[indexPath.row].selected ?? false)
        
        self.viewModel.descriptionList = self.viewModel.subscriptionModel[indexPath.row].descriptionList ?? []
        self.lblListTitle.text = self.viewModel.subscriptionModel[indexPath.row].name
        self.collecView.reloadData()
        self.tblView.reloadData()
       // sendSwitchAction(slug: slug)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (collectionView.frame.size.width) / 2, height: (collectionView.frame.size.width - 30) / 2)
    }
    
}

extension SubscriptionVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel.getNumberOfRowsForDescription() == 0{
            self.setNoRecordsFoundLabelOnTop(tblView: tableView, lblText: "No data found.")
        }
        else{
            self.tblView.backgroundView = UIView()
        }
        return self.viewModel.getNumberOfRowsForDescription()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionTblCell", for: indexPath) as! SubscriptionTblCell
        
        let cellVM = self.viewModel.getItemForDescription(At: indexPath)
    
        cell.lblTitle.text = cellVM

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
