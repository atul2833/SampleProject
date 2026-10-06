//
//  ViewController.swift
//  TAGCreditMerchant
//
//  Created by NIKETAN SHARMA on 25/04/24.
//

import UIKit
import Starscream
import IQKeyboardManagerSwift
import BSImagePicker
import Photos
import DropDown

class MessageDetailVC: BaseNavigationController{
   
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var bottomConstraintMessageView:NSLayoutConstraint!
    @IBOutlet weak var bottomTblView:NSLayoutConstraint!
    @IBOutlet weak var viewEnterMessage:UIView!

    @IBOutlet weak var txtField:UITextField!

    var currentPage = 1
    var isPagingAllowed = true
    var isFetchingData = false
    var isDateViewHidden = true
    var selectedIndexMonth = -1
    var filterType = "Month"
    let dropDown = DropDown()
    
    var colors = ["BCEEFD","DEE7FF","D8F2E9","FFE5DB","BCDFFD","FFDDE3","ECF2D8","DBF9FF"]

    private let loaderView: UIActivityIndicatorView = {
        let loaderView = UIActivityIndicatorView(style: .medium)
        loaderView.hidesWhenStopped = true
        return loaderView
    }()
    
    private lazy var socket: Starscream.WebSocket = {
        let url = URL(string: ServerConfiguration.shared.chatSocketUrl)!
          var request = URLRequest(url: url)
          request.timeoutInterval = 5
          request.setValue(self.userId, forHTTPHeaderField: "senderId")
          request.setValue(self.receiverId, forHTTPHeaderField: "receiverId")
          request.setValue(self.blockId ?? "", forHTTPHeaderField: "blockId")
          request.setValue(self.groupId ?? "", forHTTPHeaderField: "groupId")
          request.setValue(self.propertyId, forHTTPHeaderField: "propertyId")
          let ws = WebSocket(request: request)
          ws.delegate = self
          return ws
      }()
    var isConnected = false
    //let server = WebSocketServer()
    
    private var viewModel: MessageViewModel
    private var type = ""
    private var messageData: MessageResponseSubDataModel?
    private var userId = ""

    private var messagesListData: MessageInnerResponseDataModel?
    private var lblUserName: UILabel!
    private var messageInnerListData: MessageResponseInnerDataModel?
    private var profileImage:UIImageView!
    
    var selectedImages = [UIImage]()
    var selectedImagesWithData = [Data]()
    var selectedImagesWithName = [String]()

    private var propertyData: PropertyDataModel?

    private var receiverId: String?
    private var blockId: String?
    private var groupId: String?
    private var propertyId: String?
    private var currency = AppUserDefaults.shared.UDValue(.countryCurrency) as? String

    init(viewModel: MessageViewModel,messageData:MessageResponseSubDataModel?,type:String) {
        self.viewModel = viewModel
        self.messageData = messageData
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        Log.info("====== \(self) ======")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        stateObserver()
        addNavigationView()
      //  viewModel.getReasonListData(type: type)
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // Adjust the text field's bottom constraint or frame based on keyboard height
            bottomConstraintMessageView.constant = keyboardSize.height - 24
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        // Reset the text field's bottom constraint or frame
        bottomConstraintMessageView.constant = 0 // or any other initial position
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
   
    // MARK: Write Text Action
    

    @IBAction func sendMessage(_ sender: ResponsiveButton) {
        self.view.endEditing(true)
        if txtField.text?.count ?? 0 > 0{
            sendMessage()
        }
    }
    
    @IBAction func sendImage(_ sender: ResponsiveButton) {
        self.view.endEditing(true)
        self.view.endEditing(true)

        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 1
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image, .video]
        imagePicker.settings.selection.unselectOnReachingMax = true

        let start = Date()
        self.presentImagePicker(imagePicker, select: { (asset) in
            print("Selected: \(asset)")
        }, deselect: { (asset) in
            print("Deselected: \(asset)")
        }, cancel: { (assets) in
            print("Canceled with selections: \(assets)")
        }, finish: { (assets) in
            var selectedImages = [UIImage]()
            var selectedImagesWithData = [Data]()
            var selectedImagesWithName = [String]()

            
            let imageManager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .highQualityFormat
            
            for asset in assets {
                imageManager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFit, options: requestOptions) { (image, _) in
                    if let image = image {
                       selectedImages.append(image)
                       selectedImagesWithData.append(image.jpegData(compressionQuality: 0.5)!)
                       selectedImagesWithName.append("image\(NSDate().timeIntervalSince1970).jpg")
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.viewModel.uploadChatImage(imageDatas: selectedImagesWithData, fileNames: selectedImagesWithName,senderId: self.userId,groupId: self.groupId ?? "")

            }
            print("Finished with selections: \(assets)")
        }, completion: {
            let finish = Date()
            print(finish.timeIntervalSince(start))
        })
    }
    

    // MARK: Disconnect Action
    
    @IBAction func disconnect(_ sender: UIBarButtonItem) {
        if isConnected {
            sender.title = "Connect"
            socket.disconnect()
        } else {
            sender.title = "Disconnect"
            socket.connect()
        }
    }
    
    func JSONStringify(_ value: Any, prettyPrinted: Bool = false) -> String {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : []
        if JSONSerialization.isValidJSONObject(value) {
            if let data = try? JSONSerialization.data(withJSONObject: value, options: options) {
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }
        }
        return ""
    }
    
    func addNavigationView(){

        let image = messageData?.propertyData == nil ? messageData?.blockData?.userData?.profileImageUrl : messageData?.propertyData?.userData?.profileImageUrl
        
        let name = messageData?.propertyData == nil ? messageData?.blockData?.blockName : messageData?.propertyData?.title
        
        let middleView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))

        profileImage = UIImageView(frame: CGRect(x: -30, y: 2, width: 40, height: 40))
        profileImage.isUserInteractionEnabled = true // Enable user interaction

        self.profileImage.sd_setImage(with: image, placeholderImage: .none)
        profileImage.layer.cornerRadius = 20
        profileImage.clipsToBounds = true
            
        lblUserName = UILabel(frame: CGRect(x: 20, y: 2, width: 160, height: 40))
        lblUserName.text = name
        lblUserName.textColor = .appBlack
        lblUserName.textAlignment = .left
        lblUserName.font = AppFont.semi(.title)
        middleView.addSubview(profileImage)
        middleView.addSubview(lblUserName)
        self.navigationItem.titleView = middleView

    }
    
    func addRightNavigationButton(){
        let optionImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        optionImageView.image = UIImage(named: "threeDot")
        optionImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionImageTapped))
        optionImageView.addGestureRecognizer(tapGesture)
        let optionBarButton = UIBarButtonItem(customView: optionImageView)
        navigationItem.rightBarButtonItem = optionBarButton
        dropDown.anchorView = optionImageView
        dropDown.bottomOffset = CGPoint(x: 0, y: optionImageView.bounds.height)
        dropDown.backgroundColor = .white
    }
    
    func setDropDownData() {
            dropDown.dataSource = (messagesListData?.isBlocked ?? false) ? ["Unblock", "Clear Chat"] : ["Block", "Clear Chat"]
            dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            self?.handleSelection(item)
        }
    }
    
    @objc func optionImageTapped(_ sender: UIButton) {
        
        dropDown.show()
    }
    
    func handleSelection(_ item: String) {
            if item == "Block" || item == "Unblock" {
                blockUnblock()
            } else if item == "Clear Chat" {
                clearChat()
            }
      }
    
    
    @objc func optionBtnAction(_ sender:UIBarButtonItem){
        
    }
    
    
    func initView(){
        
        tblView.register(UINib(nibName: "MessageInnerTblCell", bundle: nil), forCellReuseIdentifier: "MessageInnerTblCell")
        tblView.register(UINib(nibName: "MessageDateTblCell", bundle: nil), forCellReuseIdentifier: "MessageDateTblCell")
        tblView.register(UINib(nibName: "MyMessageInnerTblCell", bundle: nil), forCellReuseIdentifier: "MyMessageInnerTblCell")
        tblView.register(UINib(nibName: "ChatImageReceivedTblCell", bundle: nil), forCellReuseIdentifier: "ChatImageReceivedTblCell")
        tblView.register(UINib(nibName: "ChatImageSendTblCell", bundle: nil), forCellReuseIdentifier: "ChatImageSendTblCell")
        tblView.tableFooterView = UIView()
       
    }
    
    private func stateObserver() {
        
        userId = AppUserDefaults.shared.UDValue(.userId) as? String ?? ""
        receiverId = messageData?.propertyData == nil ? messageData?.blockData?.userData?.userId : messageData?.propertyData?.userData?.userId
        blockId = messageData?.blockData?.blockId
        groupId = messageData?.messageData?.groupId
        propertyId = messageData?.propertyData?.propertyId
        
        var request = URLRequest(url: URL(string: ServerConfiguration.shared.chatSocketUrl)!) //"ws://65.0.15.221:8000/ws/chat/"//"ws://162.241.71.136:7081/ws/chat/"
        request.timeoutInterval = 5
        
        request.setValue(userId, forHTTPHeaderField: "senderId")
        request.setValue(receiverId, forHTTPHeaderField: "receiverId")
        request.setValue(blockId ?? "", forHTTPHeaderField: "blockId")
        request.setValue(groupId ?? "", forHTTPHeaderField: "groupId")
        request.setValue(propertyId, forHTTPHeaderField: "propertyId")

        socket = WebSocket(request: request)
        socket.callbackQueue = .main
        socket.delegate = self
        socket.connect()
        
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
                    //self?.acceptRejectRequest()
                    break
                case .sendImage:
                    self?.sendImage()
                case .messageListFetched:
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
    
    func confirm(reasonId:String,requestId:String,usedFor:String){
        viewModel.acceptRejectRequest(dict: ["requestId":requestId,"type":"reject","rejectId":reasonId,"usedFor":usedFor])
    }
    
    //***************oldcode*********************
    
//    private func loadTableView() {
//        // >2 as paginationParams.page is updated before this method is called
//        if viewModel.paginationParams.page > 2 {
//            let currentCount = tblView.numberOfRows(inSection: 0)
//            let newCount = viewModel.getNumberOfRows()
//            if newCount > currentCount {
//                let indexPaths = (currentCount..<newCount).map { IndexPath(row: $0, section: 0) }
//                tblView.beginUpdates()
//                tblView.insertRows(at: indexPaths, with: .automatic)
//                tblView.endUpdates()
//            }
//        } else {
//            tblView.reloadData()
//        }
//
//        DispatchQueue.main.async {
//            let lastRowIndex = self.tblView.numberOfRows(inSection: 0) - 1
//            if lastRowIndex >= 0 {
//                let lastIndexPath = IndexPath(row: lastRowIndex, section: 0)
//                self.tblView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
//            }
//        }
//    }
    
    //***********oldcode******************
    
    
    private func loadTableView() {
        let currentCount = tblView.numberOfRows(inSection: 0)
        let newCount = self.getNumberOfRows()   // FIXED: was viewModel.getNumberOfRows()

        if viewModel.paginationParams.page > 2, newCount > currentCount {
            let indexPaths = (currentCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tblView.performBatchUpdates {
                tblView.insertRows(at: indexPaths, with: .none)
            }
        } else {
            tblView.reloadData()
        }

        DispatchQueue.main.async { [weak self] in
            guard let self, self.tblView.numberOfRows(inSection: 0) > 0 else { return }
            let lastIndexPath = IndexPath(row: self.tblView.numberOfRows(inSection: 0) - 1, section: 0)
            self.tblView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        }
    }
    
    func clearChatData(){
        self.messagesListData?.messageList = []
        self.messagesListData = nil
    }
    func getNumberOfRows() -> Int {
        self.messagesListData?.messageList?.count ?? .zero
    }
    
    func getNumberOfItem(At index: IndexPath) -> MessageDataModel? {
        return self.messagesListData?.messageList?[index.row]
    }
    
    func getContentType() -> String {
        return self.messagesListData?.messageList?[0].contentType ?? ""
    }
}


extension MessageDetailVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if getNumberOfRows() == 0{
           // self.setNoRecordsFoundLabel(tblView: tableView, lblText: "No data found.")
        }
        else{
            self.tblView.backgroundView = UIView()
        }
        return getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = getNumberOfItem(At: indexPath)

        if item?.contentType == "date"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageDateTblCell", for: indexPath) as! MessageDateTblCell
            
                cell.lbl.text = item?.content ?? ""
                    
            return cell
        }
        else if item?.contentType == "image"{

            if item?.senderId == userId{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatImageSendTblCell", for: indexPath) as! ChatImageSendTblCell
                cell.imgView.image = nil
                cell.timeLbl.text = (item?.timeDate ?? "").dateStringToTimeString()
                
                //*******oldcode*****************
                
//                if item?.imagesData?.count ?? 0  > 0{
//                    let imageUrl: URL? = URL(string: String(format: "%@%@", ServerConfiguration.shared.baseImageURL, item?.imagesData?[0] ?? ""))
//
//                    cell.imgView.sd_setImage(with: imageUrl, placeholderImage: .none)
//                }
              //********************oldcode******************
                if let path = item?.imagesData?.first, !path.isEmpty,
                   let imageUrl = URL(string: ServerConfiguration.shared.baseImageURL + path) {
                    cell.imgView.sd_setImage(
                        with: imageUrl,
                        placeholderImage: UIImage(named: "chatImagePlaceholder"),
                        options: [.retryFailed, .continueInBackground]
                    ) { [weak self, weak cell] image, error, cacheType, url in
                        guard let self = self, let cell = cell, error == nil, image != nil else {
                            if let error = error {
                                print("⚠️ SDWebImage failed for \(String(describing: url)): \(error.localizedDescription)")
                            }
                            return
                        }
                        print("✅ loaded (\(cacheType.rawValue)) \(String(describing: url)) size=\(image?.size ?? .zero)")

                        DispatchQueue.main.async {
                            // Re-measure just this row's height now that the image exists
                            guard let indexPath = self.tblView.indexPath(for: cell) else { return }
                            self.tblView.beginUpdates()
                            self.tblView.endUpdates()
                            
                            // If this was the last row, re-scroll to the (now-correct) bottom
                            let lastRow = self.tblView.numberOfRows(inSection: 0) - 1
                            if indexPath.row == lastRow {
                                self.tblView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                            }
                        }
                    }
                } else {
                    cell.imgView.image = UIImage(named: "chatImagePlaceholder")
                }
                //        cell.imgView.image = UIImage(named: list.notificationType)
                
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatImageReceivedTblCell", for: indexPath) as! ChatImageReceivedTblCell
                
                cell.timeLbl.text = (item?.timeDate ?? "").dateStringToTimeString()
                
                if item?.imagesData?.count ?? 0  > 0{
                    let imageUrl: URL? = URL(string: String(format: "%@%@", ServerConfiguration.shared.baseImageURL, item?.imagesData?[0] ?? ""))

                    cell.imgView.sd_setImage(with: imageUrl, placeholderImage: .none)
                }
                
                return cell
            }
         }
         else if item?.contentType == "creditRequest"{
            
                if item?.senderId == userId{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageInnerTblCell", for: indexPath) as! MyMessageInnerTblCell
                    
                    cell.lbl_date.text = (item?.timeDate ?? "").dateStringToTimeString()
                    
                    let creditRequestData = item?.creditRequestData
                    
                    cell.bottomDescription.constant = creditRequestData != nil ? 50 : 7
                    cell.viewBottom.isHidden = creditRequestData == nil
                    cell.lblStatus.text = item?.creditRequestData?.statusText
                    cell.lblStatus.textColor = item?.creditRequestData?.status == "pending" ? .appYellow : item?.creditRequestData?.status == "approved" ? .appGreen : .appRed
                    if creditRequestData != nil{
                        cell.lbl_detail.attributedText = concatTwoStrings(firstString: item?.title ?? "", secondString: item?.content ?? "")//item?.content ?? ""

                        cell.lblTotalAmount.text = "\(currency ?? "")\(item?.creditRequestData?.totalAmount ?? 0)"
                        cell.lblInterestRate.text = "\(item?.creditRequestData?.interestRate ?? 0)%"
                    }
                    else{
                        cell.lbl_detail.text = item?.content ?? ""

                    }
                    //        cell.imgView.image = UIImage(named: list.notificationType)
                    
                    return cell
                }
                else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MessageInnerTblCell", for: indexPath) as! MessageInnerTblCell
                    
                                        
                    cell.lbl_date.text = (item?.timeDate ?? "").dateStringToTimeString()
                    
                    let creditRequestData = item?.creditRequestData
                    
                    cell.bottomDescription.constant = creditRequestData != nil ? ((item?.creditRequestData?.isRequestApproved ?? false) ? 110 : 120) : 7
                    cell.viewBottom.isHidden = creditRequestData == nil
                    cell.lblStatus.text = item?.creditRequestData?.statusText
                    cell.lblStatus.textColor = item?.creditRequestData?.status == "pending" ? .appYellow : item?.creditRequestData?.status == "approved" ? .appGreen : .appRed
                    
                    let items = MessageInnerResponseModel().result
                     let responseData = items?.createGroup?.canSendMessage
                        cell.btnAccept.isHidden = !(responseData ?? false)
                        cell.btnReject.isHidden = !(responseData ?? false)
                    self.bottomTblView.constant = (responseData ?? false) ? 40 : 0

                    
                    if creditRequestData != nil{
                        cell.lbl_detail.attributedText = concatTwoStrings(firstString: item?.title ?? "", secondString: item?.content ?? "")//item?.content ?? ""

                        cell.btnReject.isHidden = item?.creditRequestData?.isRequestApproved ?? false
                        cell.btnAccept.isHidden = item?.creditRequestData?.isRequestApproved ?? false
                        cell.lblTotalAmount.text = "\(currency ?? "")\(item?.creditRequestData?.totalAmount ?? 0)"
                        cell.lblInterestRate.text = "\(item?.creditRequestData?.interestRate ?? 0)%"
                    
                        
                        cell.btnReject.addTarget(self, action: #selector(rejectBtnAction(_:)), for: .touchUpInside)
                        cell.btnAccept.addTarget(self, action: #selector(acceptBtnAction(_:)), for: .touchUpInside)
                        cell.btnReject.accessibilityIdentifier = item?.creditRequestData?.creditRequestId
                        cell.btnAccept.accessibilityIdentifier = item?.creditRequestData?.creditRequestId
                        
                       
                        
                    }
                    else{
                        cell.lbl_detail.text = item?.content ?? ""
                    }
                    //        cell.imgView.image = UIImage(named: list.notificationType)
                    
                    return cell
                
            }
         } else if item?.contentType == "swapRequest" {
             if item?.senderId == userId{
                 let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageInnerTblCell", for: indexPath) as! MyMessageInnerTblCell
                 
                 cell.lbl_date.text = (item?.timeDate ?? "").dateStringToTimeString()
                 
                 let swapRequestData = item?.swapRequestData
                 
                 cell.bottomDescription.constant = swapRequestData != nil ? 120 : 7
                 cell.viewBottom.isHidden = swapRequestData == nil
                 cell.lblStatus.text = item?.swapRequestData?.statusText
                 cell.lblStatus.textColor = item?.swapRequestData?.status == "pending" ? .appYellow : item?.swapRequestData?.status == "approved" ? .appGreen : .appRed
                 if swapRequestData != nil{
                     cell.lblCreditChange.text = "Total Block Amount"
                     cell.lblIntrestChange.text = "Duration"
                     
                     cell.lbl_detail.attributedText = concatTwoStrings(firstString: item?.title ?? "", secondString: item?.content ?? "")//item?.content ?? ""
                     cell.lblTotalAmount.text = "\(currency ?? "")\(item?.swapRequestData?.amount ?? 0)"
                     cell.lblInterestRate.text = "\(item?.swapRequestData?.duration ?? "")"
                 }
                 else{
                     cell.lbl_detail.text = item?.content ?? ""

                 }
                 //        cell.imgView.image = UIImage(named: list.notificationType)
                 
                 return cell
             }
             else{
                 let cell = tableView.dequeueReusableCell(withIdentifier: "MessageInnerTblCell", for: indexPath) as! MessageInnerTblCell
                 
                 cell.lbl_date.text = (item?.timeDate ?? "").dateStringToTimeString()
                 
                 let swapRequestData = item?.swapRequestData
                 
                 cell.bottomDescription.constant = swapRequestData != nil ? ((item?.swapRequestData?.isRequestApproved ?? false) ? 200 : 120) : 7
                 cell.viewBottom.isHidden = swapRequestData == nil
                 
                 
                 cell.lblStatus.text = item?.swapRequestData?.statusText
                 cell.lblStatus.textColor = item?.swapRequestData?.status == "pending" ? .appYellow : item?.swapRequestData?.status == "approved" ? .appGreen : .appRed

                 
                 if swapRequestData != nil{
                     cell.lblCreditChange.text = "Total Block Amount"
                     cell.lblIntrestChange.text = "Duration"
                     cell.lbl_detail.attributedText = concatTwoStrings(firstString: item?.title ?? "", secondString: item?.content ?? "")//item?.content ?? ""

                     cell.btnReject.isHidden = item?.swapRequestData?.isRequestApproved ?? false
                     cell.btnAccept.isHidden = item?.swapRequestData?.isRequestApproved ?? false
                     cell.lblTotalAmount.text = "\(currency ?? "")\(item?.swapRequestData?.amount ?? 0)"
                     cell.lblInterestRate.text = "\(item?.swapRequestData?.duration ?? "")"
                     
                     cell.btnReject.addTarget(self, action: #selector(rejectBtnAction(_:)), for: .touchUpInside)
                     cell.btnAccept.addTarget(self, action: #selector(acceptBtnAction(_:)), for: .touchUpInside)
                     cell.btnReject.accessibilityIdentifier = item?.swapRequestData?.swapRequestId
                     cell.btnAccept.accessibilityIdentifier = item?.swapRequestData?.swapRequestId
              
                 }
                 else{
                     cell.lbl_detail.text = item?.content ?? ""
                 }
                 //        cell.imgView.image = UIImage(named: list.notificationType)
                 
                 return cell
             }
         }
         else if item?.contentType == "propertyRequest"{
             if item?.senderId == userId{
                 let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageInnerTblCell", for: indexPath) as! MyMessageInnerTblCell
                 
                 cell.lbl_date.text = (item?.timeDate ?? "").dateStringToTimeString()
                 
                 let swapRequestData = item?.propertyRequestData
                 
                 cell.bottomDescription.constant = swapRequestData != nil ? 120 : 7
                 cell.viewBottom.isHidden = swapRequestData == nil
                 cell.lblStatus.text = item?.swapRequestData?.statusText
                 cell.lblStatus.textColor = item?.swapRequestData?.status == "pending" ? .appYellow : item?.swapRequestData?.status == "approved" ? .appGreen : .appRed
                 
                 if swapRequestData != nil{
                     cell.lblCreditChange.text = "Total Rent Amount"
                     cell.lblIntrestChange.text = "Duration"
                     
                     cell.lbl_detail.attributedText = concatTwoStrings(firstString: item?.title ?? "", secondString: item?.content ?? "")//item?.content ?? ""
                     cell.lblTotalAmount.text = "\(currency ?? "")\(item?.propertyRequestData?.amount ?? 0)"
                     cell.lblInterestRate.text = "\(item?.propertyData?.rentType ?? "")"
                 }
                 else{
                     cell.lbl_detail.text = item?.content ?? ""

                 }
                 //        cell.imgView.image = UIImage(named: list.notificationType)
                 
                 return cell
             }
             else{
                 let cell = tableView.dequeueReusableCell(withIdentifier: "MessageInnerTblCell", for: indexPath) as! MessageInnerTblCell
                 
                 cell.lbl_date.text = (item?.timeDate ?? "").dateStringToTimeString()
                 
                 let swapRequestData = item?.swapRequestData
                 
                 cell.bottomDescription.constant = swapRequestData != nil ? ((item?.swapRequestData?.isRequestApproved ?? false) ? 200 : 110) : 7
                 cell.viewBottom.isHidden = swapRequestData == nil
                 
                 
                 cell.lblStatus.text = item?.swapRequestData?.statusText
                 cell.lblStatus.textColor = item?.swapRequestData?.status == "pending" ? .appYellow : item?.swapRequestData?.status == "approved" ? .appGreen : .appRed

                 if swapRequestData != nil{
                     cell.lblCreditChange.text = "Total Block Amount"
                     cell.lblIntrestChange.text = "Duration"
                     cell.lbl_detail.attributedText = concatTwoStrings(firstString: item?.title ?? "", secondString: item?.content ?? "")//item?.content ?? ""

                     cell.btnReject.isHidden = item?.swapRequestData?.isRequestApproved ?? false
                     cell.btnAccept.isHidden = item?.swapRequestData?.isRequestApproved ?? false
                     cell.lblTotalAmount.text = "\(currency ?? "")\(item?.swapRequestData?.amount ?? 0)"
                     cell.lblInterestRate.text = "\(item?.swapRequestData?.duration ?? "")"
                     
                     cell.btnReject.addTarget(self, action: #selector(rejectBtnAction(_:)), for: .touchUpInside)
                     cell.btnAccept.addTarget(self, action: #selector(acceptBtnAction(_:)), for: .touchUpInside)
                     cell.btnReject.accessibilityIdentifier = item?.swapRequestData?.swapRequestId
                     cell.btnAccept.accessibilityIdentifier = item?.swapRequestData?.swapRequestId
                 }
                 else{
                     cell.lbl_detail.text = item?.content ?? ""
                 }
                 //        cell.imgView.image = UIImage(named: list.notificationType)
                 
                 return cell
             }
         }
        else{
            if item?.senderId == userId{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageInnerTblCell", for: indexPath) as! MyMessageInnerTblCell
                
                cell.lbl_date.text = (item?.timeDate ?? "").dateStringToTimeString()
                
                
                cell.bottomDescription.constant =  7
                cell.viewBottom.isHidden = true
                                
                cell.lbl_detail.text = item?.content ?? ""

                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageInnerTblCell", for: indexPath) as! MessageInnerTblCell
                
                cell.lbl_date.text = (item?.timeDate ?? "").dateStringToTimeString()
                
                
                cell.bottomDescription.constant =  7
                cell.viewBottom.isHidden = true
                                
                cell.lbl_detail.text = item?.content ?? ""

                return cell
            }
        }
    }

    @objc func rejectBtnAction(_ sender:ResponsiveButton){
        guard let requestId = sender.accessibilityIdentifier else {
               return
           }
        let vc = ReasonCancelVC()
        vc.messageDetailVC = self
        vc.usedFor = type
        vc.requestId = requestId
        vc.reasonList = viewModel.getReasonList()
        self.presentOnViewController(with: vc)
        
    }
    
    @objc func acceptBtnAction(_ sender:ResponsiveButton){
        guard let requestId = sender.accessibilityIdentifier else {
                return
            }
        viewModel.acceptRejectRequest(dict: ["requestId":requestId ,"type":"accept","rejectId":"","usedFor":type])
        
    }
    
    func firstLettersOfString(_ input: String) -> String {
        let words = input.components(separatedBy: " ")
        let firstLetters = words.map { String($0.prefix(1)) }
        return firstLetters.joined()
    }
}

extension MessageDetailVC:WebSocketDelegate{

    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            createGroup()
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let jsonStr):
         //***********old code****************
            
//            if let jsonData = jsonStr.data(using: .utf8) {
//                do {
//                    let decoder = JSONDecoder()
//                    let messageResponse = try decoder.decode(MessageInnerResponseModel.self, from: jsonData)
//                    print(messageResponse)
//                    self.getResponse(response: messageResponse)
//
//                } catch {
//                    print("Error decoding JSON: \(error)")
//                }
//            } else {
//                print("Invalid JSON string")
//            }
           //********old code*************
          
            guard let jsonData = jsonStr.data(using: .utf8) else {
                   print("Invalid JSON string")
                   return
               }
               do {
                   let messageResponse = try JSONDecoder().decode(MessageInnerResponseModel.self, from: jsonData)
                   // callbackQueue is now .main, but stay defensive:
                   DispatchQueue.main.async { [weak self] in
                       self?.getResponse(response: messageResponse)
                   }
               } catch {
                   print("Error decoding JSON: \(error)")
               }
            
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(let data):
            if let pingString = String(data: data ?? Data(), encoding: .utf8) {
                        print("Received ping message: \(pingString)")
                        // Now you have the ping message data as a string (pingString)
                        // You can process it further or handle it as needed
                    } else {
                        print("Failed to convert ping data to string")
                    }
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
//        case .peerClosed:
//            break
        }
    }
    
    func createGroup(){
        let jsonString = JSONStringify(["action":"createGroup","blockId":blockId,"senderId":userId,"receiverId":receiverId ?? "","groupId":groupId ?? "","propertyId":propertyId ?? ""])
        print("jsonString:::::::::::->         \(jsonString)")
        socket.write(string: jsonString)
    }
    
    func sendMessage(){
        
        let jsonString = JSONStringify(["action":"sendMessage","groupId":groupId ?? "","senderId":userId,"receiverId":receiverId ?? "","message":txtField.text ?? "","propertyId":propertyId ?? ""])
        print("jsonString:::::::::::->         \(jsonString)")
        socket.write(string: jsonString)
        
        self.txtField.text = ""
    }
    
    
    func sendImage(){
        
        let jsonString = JSONStringify(["action":"sendImage","groupId":groupId ?? "","senderId":userId,"receiverId":receiverId ?? ""])
        print("jsonString:::::::::::->         \(jsonString)")
        socket.write(string: jsonString)
        
        self.txtField.text = ""
    }
    
    func clearChat(){
        
        let jsonString = JSONStringify(["action":"clearChat","groupId":groupId ?? "","senderId":userId,"receiverId":receiverId ?? ""])
        print("jsonString:::::::::::->         \(jsonString)")
        socket.write(string: jsonString)
        
        self.txtField.text = ""
    }
    
    func blockUnblock(){
        
        
        let jsonString = JSONStringify(["action":"blockUser","groupId":groupId ?? "","senderId":userId,"receiverId":receiverId ?? "","type": (messagesListData?.isBlocked ?? false) ? "unblock" : "block"])
        print("jsonString:::::::::::->         \(jsonString)")
        socket.write(string: jsonString)
        
        self.txtField.text = ""
    }
    
    func acceptRejectRequest(){
        
        let jsonString = JSONStringify(["action":"updateRequest","groupId":groupId ?? "","senderId":userId,"receiverId":receiverId ?? "","blockId":blockId, "messageId":messageData?.messageData?.messageId,"propertyId":propertyId ?? ""])
        print("jsonString:::::::::::->         \(jsonString)")
        socket.write(string: jsonString)
        
    }
    
    func getResponse(response:MessageInnerResponseModel){
        print(response)
        if response.result?.action == "createGroup" {
            let responseData = response.result?.createGroup
            self.messagesListData = responseData
            ProgressHudWrapper.dismiss()
            self.loadTableView()
            self.showLoaderView(isShow: false)
            self.addRightNavigationButton()
            self.setDropDownData()
            
            self.bottomTblView.constant = (responseData?.canSendMessage ?? false) ? 60 : 0
            self.viewEnterMessage.isHidden = !(responseData?.canSendMessage ?? false)
         
        }
        else if response.result?.action == "newMessage" {
            
            for list in response.result?.newMessage ?? []{
                self.messagesListData?.messageList?.append(list)
            }
            ProgressHudWrapper.dismiss()
            
            self.showLoaderView(isShow: false)
            
            DispatchQueue.main.async {
                self.loadTableView()
            }
        } else if response.result?.action == "blockUser" {
            
            if let newMessageData = self.messagesListData{
                self.messagesListData?.isBlocked = !(newMessageData.isBlocked ?? false)
            }
            
            DispatchQueue.main.async {
                self.setDropDownData()
            }
        } else if response.result?.action == "clearChat" {
            
            self.clearChatData()
            DispatchQueue.main.async {
                self.loadTableView()
            }
        } else if response.result?.action == "updateMessage" {
            if let updateMessages = response.result?.updateMessage {
                       for updatedMessage in updateMessages {
                           if let messageIdToRemove = messageInnerListData?.removeMessageId {
                               self.messagesListData?.messageList = self.messagesListData?.messageList?.filter { $0.messageId != messageIdToRemove }
                           } else {
                               if let index = self.messagesListData?.messageList?.firstIndex(where: { $0.messageId == updatedMessage.messageId }) {
                                   self.messagesListData?.messageList?[index] = updatedMessage
                               } else {
                                   self.messagesListData?.messageList?.append(updatedMessage)
                               }
                           }
                       }
                   }
                   ProgressHudWrapper.dismiss()
                   self.showLoaderView(isShow: false)
                   DispatchQueue.main.async {
                       self.loadTableView()
                   }
        }
        else{
            self.view.makeToast(response.message)
        }
    }
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
}


