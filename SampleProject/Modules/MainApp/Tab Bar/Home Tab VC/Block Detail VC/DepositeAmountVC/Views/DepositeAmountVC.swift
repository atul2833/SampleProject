//
//  DepositeAmountVC.swift
//  TAGCredit
//
//  Created by somendra on 26/06/24.
//

import UIKit

class DepositeAmountVC: BaseNavigationController {

    @IBOutlet weak var tblView: UITableView!

    
    
    private var viewModel: BlockDetailViewModel
    private var viewModelDeposit: DepositeAmountViewModel
    var alertConfirm : AlertConfimDelegate!

    
    init(viewModel: BlockDetailViewModel,viewModelDeposit: DepositeAmountViewModel){
        self.viewModel = viewModel
        self.viewModelDeposit = viewModelDeposit
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
       
    }
    
    func initView() {
        stateObserver()
        contributionstateObserver()
        viewModelDeposit.depositDetails()
        tblView.register(UINib(nibName: "DepositeAmtTableViewCell", bundle: nil), forCellReuseIdentifier: "DepositeAmtTableViewCell")
        self.title = "Deposit Amount"
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
//            self.tblViewHeight.constant = self.tblView.contentSize.height
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
                case .payment(let transactionId):
                    self?.goToTransactionDetail(transactionId: transactionId)
                    break
                case .membersListFetched:
                    self?.tblView.reloadData()
                    self?.viewDidLayoutSubviews()
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
    
    private func contributionstateObserver() {
        self.viewModelDeposit.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .success:
                    break
                case .membersListFetched:
                    self?.tblView.reloadData()
                    self?.viewDidLayoutSubviews()
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
            .store(in: &self.viewModelDeposit.cancellable)
    }
   
    @IBAction func depositeBtnPressed(_ sender: ResponsiveButton) {
        viewModel.getBlockDetail()
        viewModel.goForPayment()
    }
    
    func goToTransactionDetail(transactionId:String){
        let vc = TransactionDetailVC(viewModel: TransactionViewModel(transactionId: transactionId))
        self.navigationController?.pushViewController(vc, animated: true)
       
    }
    
}



extension DepositeAmountVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModelDeposit.getNumberOfAmountList() ?? .zero
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "DepositeAmtTableViewCell", for: indexPath) as! DepositeAmtTableViewCell
        let item = viewModelDeposit.getNumberOfItemForAmount(At: indexPath)
        cell.lblTitle.text = item?.title
        cell.lblSubTitle.text = item?.value
        return cell
    }
    
    
}
