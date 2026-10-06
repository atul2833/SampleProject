//
//  MessageTabVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 02/02/24.
//

import UIKit

class MessageTabVC:  BaseSlideViewController {
    
    @IBOutlet weak var tblView:UITableView!
    
    var currentPage = 1
    var isPagingAllowed = true

    var isFetchingData = false
    
    var isDateViewHidden = true
    var selectedIndexMonth = -1
    var filterType = "Month"
    
    var colors = ["BCEEFD","DEE7FF","D8F2E9","FFE5DB","BCDFFD","FFDDE3","ECF2D8","DBF9FF"]

    private var viewModel: MessageViewModel
    private var countryCurrency = AppUserDefaults.shared.UDValue(.countryCurrency) as? String
    
    init(viewModel: MessageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        Log.info("====== \(self) ======")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let loaderView: UIActivityIndicatorView = {
        let loaderView = UIActivityIndicatorView(style: .medium)
        loaderView.hidesWhenStopped = true
        return loaderView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        stateObserver()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.clearData()
        viewModel.paginationParams.totalPage = 1
        viewModel.paginationParams.page = 1
        viewModel.getMessageList(page: viewModel.paginationParams.page)

    }
    
    func setNavigationBar(){
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        customView.isUserInteractionEnabled = true // Enable user interaction

           let label = UILabel(frame: CGRect(x: 10, y: 0, width: 160, height: 40))
           label.text = "Message"
           label.textColor = .appBase
           label.font = AppFont.bold(.title)
        customView.addSubview(label)
       
   
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(customView: customView)
    }
    
    func confirm(){
        
    }
    
    func initView(){
        tblView.register(UINib(nibName: "MessageTblCell", bundle: nil), forCellReuseIdentifier: "MessageTblCell")

        tblView.tableFooterView = UIView()
        setNavigationBar()
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
                case .messageListFetched:
                    ProgressHudWrapper.dismiss()
                    self?.loadTableView()
                    self?.showLoaderView(isShow: false)
                case .error(let message):
                    Log.error(message)
                    self?.view.makeToast(message, position: .bottom)
                    ProgressHudWrapper.dismiss()
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
        } else {
            tblView.reloadData()
        }
        
    }
}


extension MessageTabVC:UITableViewDelegate,UITableViewDataSource{
    
    private func showHideEmptyState(isShow: Bool) {
        if isShow {
            self.tblView.setEmptyView(
                image: UIImage(resource: .iconNoData),
                title: "No block"
            )
        } else {
            self.tblView.restore()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = viewModel.getNumberOfRows()
        
        self.showHideEmptyState(isShow: rows == 0)
        
        return viewModel.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTblCell", for: indexPath) as! MessageTblCell
        
        let item = viewModel.getNumberOfItem(At: indexPath)
        
        cell.ViewBack.backgroundColor = UIColor(hex: colors[indexPath.row % 8])
        cell.viewMainBack.backgroundColor = UIColor(hex: colors[indexPath.row % 8])?.withAlphaComponent(0.4)
        cell.imageMessageView.isHidden = true
        cell.lbl_detail.attributedText = concatTwoStrings(firstString: item?.messageData?.title ?? "", secondString: item?.messageData?.content ?? "")
        cell.lbl_date.text = (item?.messageData?.timeDate ?? "").dateStringToString()
        cell.viewBottom.isHidden = true
        cell.bottomDescription.constant = 7
        if item?.messageData?.contentType == "creditRequest" {
            
            cell.lbl_title.text = item?.blockData?.blockName
            cell.lbl_image_title.text = firstLettersOfString(item?.blockData?.blockName ?? "").prefix(2).uppercased()
                        
            let creditRequestData = item?.messageData?.creditRequestData
            cell.bottomDescription.constant = creditRequestData != nil ? 77 : 7
            cell.viewBottom.isHidden = creditRequestData == nil
            
            if creditRequestData != nil{
                cell.lblTotalAmount.text = "\(countryCurrency ?? "")\(item?.messageData?.creditRequestData?.totalAmount ?? 0)"
                cell.lblInterestRate.text = "\(item?.messageData?.creditRequestData?.interestRate ?? 0)%"
            }
        }
        else if item?.messageData?.contentType == "swapRequest" {
            
            cell.lbl_title.text = item?.blockData?.blockName
            cell.lbl_image_title.text = firstLettersOfString(item?.blockData?.blockName ?? "").prefix(2).uppercased()
            
            let swapRequestData = item?.messageData?.swapRequestData
            
            cell.bottomDescription.constant = swapRequestData != nil ? 77 : 7
            cell.viewBottom.isHidden = swapRequestData == nil
            if swapRequestData != nil{
                cell.lblTitle.text = "Total Block Amount"
                cell.lblIntrest.text = "Duration"
                cell.lblTotalAmount.text = "\(countryCurrency ?? "")\(item?.messageData?.swapRequestData?.amount ?? 0)"
                cell.lblInterestRate.text = "\(item?.messageData?.swapRequestData?.duration ?? "")"
            }
        }
        else if item?.messageData?.contentType == "propertyRequest" {
            
            cell.lbl_title.text = item?.messageData?.propertyData?.title
            cell.lbl_image_title.text = firstLettersOfString(item?.blockData?.blockName ?? "").prefix(2).uppercased()
            
            let swapRequestData = item?.messageData?.propertyRequestData
            
            cell.bottomDescription.constant = swapRequestData != nil ? 77 : 7
            cell.viewBottom.isHidden = swapRequestData == nil
            if swapRequestData != nil{
                cell.lblTitle.text = "Total Rent Amount"
                cell.lblIntrest.text = "Duration"
                cell.lblTotalAmount.text = "\(countryCurrency ?? "")\(item?.messageData?.propertyRequestData?.amount ?? 0)"
                cell.lblInterestRate.text = "\(item?.messageData?.propertyData?.rentType ?? "")"
            }
        }else if item?.messageData?.contentType == "image" {
            cell.imageMessageView.isHidden = false
            cell.imageMessage.sd_setImage(with: item?.messageData?.propertyData?.propertyImageURL)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.getNumberOfItem(At: indexPath)

        let vc = MessageDetailVC(viewModel: MessageViewModel(), messageData: item,type: item?.messageData?.contentType ?? "")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func firstLettersOfString(_ input: String) -> String {
        let words = input.components(separatedBy: " ")
        let firstLetters = words.map { String($0.prefix(1)) }
        return firstLetters.joined()
    }
}

