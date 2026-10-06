//
//  NotificationVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit

class NotificationVC: BaseNavigationController,UISearchBarDelegate {
    
    @IBOutlet weak var tblView:UITableView!

    @IBOutlet weak var srchBar:UISearchBar!
    
    var currentPage = 1
    var isPagingAllowed = true

    var isFetchingData = false
    
    var isDateViewHidden = true
    var selectedIndexMonth = -1
    var filterType = "Month"
    
    var colors = ["BCEEFD","DEE7FF","D8F2E9","FFE5DB","BCDFFD","FFDDE3","ECF2D8","DBF9FF"]

    private let loaderView: UIActivityIndicatorView = {
        let loaderView = UIActivityIndicatorView(style: .medium)
        loaderView.hidesWhenStopped = true
        return loaderView
    }()
    
    private var viewModel: NotificationViewModel

    init(viewModel: NotificationViewModel) {
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

        self.navigationItem.title = "Notification"
        stateObserver()
        initView()
        
       
      // initVM()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        self.viewModel.getReasonListData()
        
        viewModel.clearData()
        viewModel.getNotificationList(page: viewModel.paginationParams.page)
    }

    
    func confirm(reasonId:String,requestId:String,usedFor:String){
        viewModel.acceptRejectRequest(dict: ["requestId":requestId,"type":"reject","rejectId":reasonId,"usedFor":"block"])
    }
    
    private func stateObserver() {
        self.viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    // Show loading indicator
                    if self?.viewModel.paginationParams.page == 1 {
                        ProgressHudWrapper.loadingIndicator()
                    }else {
                        self?.showLoaderView(isShow: true)
                    }
                case .success:
                   // self?.viewModel.getNotificationList(dict: ["limit":20,"page":1])
                    break
                case .acceptReject:
                    self?.viewModel.clearData()
                    self?.viewModel.getNotificationList(page: 1)
                case .notificationListFetched:
                    ProgressHudWrapper.dismiss()
                    self?.loadTableView()
                    self?.showLoaderView(isShow: false)
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
    
    private func showLoaderView(isShow: Bool) {
        loaderView.frame = CGRect(x: 0, y: 0, width: tblView.bounds.width, height: 50) // Adjust height as needed
        loaderView.hidesWhenStopped = true
        if isShow {
            tblView.tableFooterView = loaderView
            self.loaderView.startAnimating()
            
        }else {
            self.loaderView.stopAnimating()
            tblView.tableFooterView = nil
        }
    }
    
    func initView(){
        tblView.register(UINib(nibName: "NotificationTblCell", bundle: nil), forCellReuseIdentifier: "NotificationTblCell")

        tblView.tableFooterView = UIView()
        tblView.tableHeaderView = UIView()
        
    }
    
    private func loadTableView() {
        // >2 as paginationParams.page is updated before this method is called
        if viewModel.paginationParams.page > 2 {
            let currentCount = tblView.numberOfRows(inSection: 0)
            let newCount = viewModel.getNumberOfRows()
            if newCount > currentCount {
                let indexPaths = (currentCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tblView.beginUpdates()
                tblView.insertRows(at: indexPaths, with: .automatic)
                tblView.endUpdates()
            }
            else{
                tblView.reloadData()
            }
        } else {
            tblView.reloadData()
        }
        
    }
}


extension NotificationVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.getNumberOfRows() == 0{
            self.setNoRecordsFoundLabelOnTop(tblView: tableView, lblText: "No data found.")
        }
        else{
            self.tblView.backgroundView = UIView()
        }
        return viewModel.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTblCell", for: indexPath) as! NotificationTblCell
        
        let item = viewModel.getNumberOfItem(At: indexPath)
        cell.ViewBack.backgroundColor = UIColor(hex: colors[indexPath.row % 8])
        cell.viewMainBack.backgroundColor = UIColor(hex: colors[indexPath.row % 8])?.withAlphaComponent(0.4)
        
        cell.lbl_title.text = item?.title
        cell.lbl_detail.text = item?.message
        cell.lbl_date.text = item?.timeDate?.dateStringToDateTimeString()
        cell.lbl_image_title.text = firstLettersOfString(item?.title ?? "").prefix(2).uppercased()
        
        cell.topDate.constant = item?.type == "request" || item?.type == "invitationReceiver" ? 50 : 5
        cell.btnAccept.isHidden = item?.type != "request"
        cell.btnCancel.isHidden = item?.type != "request"
        cell.btnAccept.isUserInteractionEnabled = item?.type == "request"
        cell.btnCancel.isUserInteractionEnabled = item?.type == "request"

        cell.btnJoinBlock.isHidden = item?.type != "invitationReceiver"
        cell.btnJoinBlock.isUserInteractionEnabled = item?.type == "invitationReceiver"

        if item?.type == "request"{
            cell.btnCancel.accessibilityIdentifier = item?.requestData?.requestId
            cell.btnCancel.addTarget(self, action: #selector(rejectBtnAction(_:)), for: .touchUpInside)
            
            cell.btnAccept.accessibilityIdentifier = item?.requestData?.requestId
            cell.btnAccept.addTarget(self, action: #selector(acceptBtnAction(_:)), for: .touchUpInside)
        }
        
        if item?.type == "invitationReceiver"{
            cell.btnJoinBlock.accessibilityIdentifier = item?.requestData?.blockId
            cell.btnJoinBlock.accessibilityHint = item?.requestData?.password
            cell.btnJoinBlock.addTarget(self, action: #selector(joinBlockBtnAction(_:)), for: .touchUpInside)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = viewModel.getNumberOfItem(At: indexPath)

        if item?.type == "invitationReceiver"{
            let vc = JoinBlockVC(viewModel: JoinBlockViewModel(blockId: item?.requestData?.blockId ?? "", password: item?.requestData?.password ?? ""))
           self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func firstLettersOfString(_ input: String) -> String {
        let words = input.components(separatedBy: " ")
        let firstLetters = words.map { String($0.prefix(1)) }
        return firstLetters.joined()
    }
    
    @objc func rejectBtnAction(_ sender:ResponsiveButton){
        let vc = ReasonCancelVC()
            vc.notificationVC = self
            vc.requestId = sender.accessibilityIdentifier ?? ""
            vc.usedFor = "block"
            vc.reasonList = viewModel.getReasonList()
        self.presentOnViewController(with: vc)
    }
    
    @objc func acceptBtnAction(_ sender:ResponsiveButton){
        viewModel.acceptRejectRequest(dict: ["requestId":sender.accessibilityIdentifier ?? "","type":"accept","rejectId":"","usedFor":"block"])
    }
    
    @objc func joinBlockBtnAction(_ sender:ResponsiveButton){
        let vc = JoinBlockVC(viewModel: JoinBlockViewModel(blockId: sender.accessibilityIdentifier ?? "", password: sender.accessibilityHint ?? ""))
       self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension NotificationVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let count = self.viewModel.getNumberOfRows()
        if indexPaths.contains(where: { $0.row >= count - 1 }) {
            viewModel.getNotificationList(page: viewModel.paginationParams.page)
        }
        
    }
}

