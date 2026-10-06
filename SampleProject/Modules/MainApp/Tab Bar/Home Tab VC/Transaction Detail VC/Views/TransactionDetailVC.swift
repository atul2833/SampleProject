//
//  TransactionDetailVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit



class TransactionDetailVC:BaseNavigationController {
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var imgViewStatus:UIImageView!
    @IBOutlet weak var lblStatus:UILabel!
    @IBOutlet weak var lblAmount:UILabel!
    @IBOutlet weak var lblNotes:UILabel!
    @IBOutlet weak var viewNotes:UIView!
    @IBOutlet weak var tblViewHeight:NSLayoutConstraint!
    @IBOutlet weak var tblViewTop:NSLayoutConstraint!
    @IBOutlet weak var viewBack:UIView!

    @IBOutlet weak var doneBtn: UIButton!
    var alertConfirm : AlertConfimDelegate!
    private var viewModel: TransactionViewModel
    private var currency  = AppUserDefaults.shared.UDValue(.countryCurrency) as? String

    var transactionId = String()
    init(viewModel: TransactionViewModel) {
        self.viewModel = viewModel
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
        print("TransactionDetailVC")
        
        self.navigationItem.title = "Transaction Details"
        //initVM()
        initView()
        stateObserver()
    
        viewModel.getTransactionData()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.tblViewHeight.constant = self.tblView.contentSize.height
        }
    }
    
    @IBAction func tryAgainBtnAction(_ sender: ResponsiveButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneBtnAction(_ sender: ResponsiveButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func initView() {
        
        tblView.register(UINib(nibName: "TransactionDetailDataTblCell", bundle: nil), forCellReuseIdentifier: "TransactionDetailDataTblCell")
//        imgViewStatus.image  = UIImage(named: comingFrom == "Failed" ? "Group 72374" : "Group 72340")
//        
//        if comingFrom == "PaymentVC" {
//            doneBtn.isHidden = false
//            lblNotes.textColor = .appGray
//            lblNotes.text = "Transaction successful"
//            self.navigationItem.title = "Success"
//        }else{
//            doneBtn.isHidden = true
//            self.navigationItem.title = "Transaction Details"
//            lblNotes.text = comingFrom == "Failed" ? "Unsuccessful Transaction" : "Transaction successful"
//            lblNotes.textColor = comingFrom == "Failed" ? .appRed : .appGreen
//        }
        
        //viewBack.dropShadow(.appGray)
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
                    self?.manageTransactionData()
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
    
    func manageTransactionData(){
        self.tblView.reloadData()
        
        let data = viewModel.getTransactionDetailData()
            let curency = AppUserDefaults.shared.UDValue(.countryCurrency)
        self.lblStatus.text = "\(curency as! String)\(data?.amount ?? 0)"
        self.lblNotes.textColor = data?.status == "success" ? .appGreen : .appRed
        self.lblNotes.text = data?.statusText
        
        DispatchQueue.main.async {
            self.viewDidLayoutSubviews()
        }
    }
}

extension TransactionDetailVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRowsDetail()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionDetailDataTblCell", for: indexPath) as! TransactionDetailDataTblCell
        
        let item = viewModel.getNumberOfItemDetail(At: indexPath)//viewModel.getCellViewModel( at: indexPath )
        cell.lblTitle.text = item?.title
        cell.lblDescription.text = item?.type == "date" ? item?.value?.dateStringToTimeString() : item?.value
        cell.seperationLine.isHidden = false
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}
