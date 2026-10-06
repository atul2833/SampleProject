//
//  TransactionHistoryVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit

class TransactionHistoryVC: BaseNavigationController,UISearchBarDelegate {

    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var srchBar:UISearchBar!
    @IBOutlet weak var lblShowDate:UILabel!
    @IBOutlet weak var viewShowDate:UIView!

    var currentPage = 1
    var isPagingAllowed = true

    var isFetchingData = false
    
    var isDateViewHidden = true
    var selectedIndexMonth = -1
    var filterType = "Month"
    private var currency  = AppUserDefaults.shared.UDValue(.countryCurrency) as? String

    private var viewModel: TransactionViewModel

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
        
       initView()
        stateObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.getTransactionList(page: "1", limit: "20", type: "user", blockId: "", creditRequestId: "")

    }
    
    func initView(){
        
        self.navigationItem.title = "Transactions"

       // viewShowDate.isHidden = true
        tblView.register(UINib(nibName: "TransactionHistoryTblCell", bundle: nil), forCellReuseIdentifier: "TransactionHistoryTblCell")

        tblView.tableFooterView = UIView()
        
      //  srchBar.searchTextField.font = Utilities.shared.AppFont(14, fontType: .medium)
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
}

extension TransactionHistoryVC:UITableViewDelegate,UITableViewDataSource{
    
    private func showHideEmptyState(isShow: Bool) {
        if isShow {
            self.tblView.setEmptyView(
                image: UIImage(resource: .iconNoData),
                title: ""
            )
        } else {
            self.tblView.restore()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = viewModel.getNumberOfRows()
        
        self.showHideEmptyState(isShow: rows == 0)

        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryTblCell", for: indexPath) as! TransactionHistoryTblCell
        

        let item = viewModel.getNumberOfItem(At: indexPath)
        cell.lblTitle.text = item?.name
        cell.lblDate.text = item?.timeDate?.dateStringToDateTimeString()
        cell.lblPrice.text = "\(currency ?? "")\(item?.amount ?? 0)"
            
        return cell
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//              if indexPath.row == viewModel.numberOfCells - 1 {
//                  loadNextPage()
//              }
//        }
//    
//    func loadNextPage() {
//            // Simulate fetching data from a server or another data source
//            currentPage += 1
//        
//            if currentPage <= viewModel.transactionData.totalPage{
//                viewModel.getTransationList(filterType: "", start: "", end: "", page: currentPage, removeData: false)
//                tblView.reloadData()
//            }
//         
//        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = viewModel.getNumberOfItem(At: indexPath)

        let vc = TransactionDetailVC(viewModel: TransactionViewModel(transactionId: item?.transactionId ?? ""))
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



