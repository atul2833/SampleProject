//
//  EditProfileVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit
import SDWebImage

class EditProfileVC: BaseNavigationController,UITextFieldDelegate, AlertInfoDelegate {
    
    
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var tblViewHeight:NSLayoutConstraint!

    var imagePicker = UIImagePickerController()
            
    var img_1_data : Data?
     
    private var viewModel: ProfileViewModel
    private var viewModelInfo: VerifyIdentityViewModelProtocol

    init(viewModel: ProfileViewModel,viewModelInfo: VerifyIdentityViewModelProtocol) {
        self.viewModel = viewModel
        self.viewModelInfo = viewModelInfo

        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        Log.info("====== \(self) ======")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var allViews = [String]()
    var selectedDataArr = [Bool]()
 
    override func viewDidLoad() {
        super.viewDidLoad()

        stateObserver()
        stateObserverInfo()
        self.navigationItem.title = "My Profile"
        initView()
        self.viewModelInfo.getUserKycInfo()
        setData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async{
           self.tblViewHeight.constant = self.tblView.contentSize.height + 50
        }
    }
    
    func initView() {
        tblView.register(UINib(nibName: "VerifiedItemsTblCell", bundle: nil), forCellReuseIdentifier: "VerifiedItemsTblCell")
        
      //  profileImage.imageFromServerURL( APIServiceBaseURLType.image.rawValue + UserDataManager.userData.profileImage,placeHolder: UIImage(named: "placeholder"))
       // lblName.text = viewModel.userData.name
    }
    
    private func stateObserver() {
        self.viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .success(let message):
                    self?.view.makeToast(message, position: .bottom)
                    break
                    
                case .updateSuccess(let message):
                    self?.showAlert(message: message)
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
    
    private func stateObserverInfo() {
        viewModelInfo.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &viewModelInfo.cancellable)
    }
    
    private func handleState(_ state: VerifyIdentityViewModel.State) {
        
        switch state {
            case .loading:
                ProgressHudWrapper.loadingIndicator()
            case .successList:
            ProgressHudWrapper.dismiss()

             //   ProgressHudWrapper.succeed()
                self.tblView.reloadData()
            DispatchQueue.main.async {
                self.viewDidLayoutSubviews()
            }
            case .success:
            ProgressHudWrapper.dismiss()

               // ProgressHudWrapper.dismiss()
              //  handleSuccess()
                break
            case .error(let message):
                ProgressHudWrapper.dismiss()
                view.makeToast(message, position: .bottom)
            case .logout:
                ProgressHudWrapper.dismiss()

                let tabBar = self.tabBarController as? HomeTabBarController
                tabBar?.logout()
            default:
                ProgressHudWrapper.dismiss()
        }
    }
    
    
    
    
    func setData(){
        let userContext = self.viewModel.getUserContext()
        let model = userContext.getUserInformation().profileModel
        
        self.lblName.text = model?.fullName
        self.profileImage.sd_setImage(with: model?.profileImageUrl, placeholderImage: .none)
//        
//        let planModel = model?.userSubscriptionPlan
//        
//        self.lblPlanName.text = planModel?.title
//        self.lblPlanType.text = planModel?.duration
//        self.lblPlanPrice.text = planModel?.price
//        self.lblPlanExpDate.text = planModel?.expirationDate
    }
    
    func updatedName(name:String){
        self.lblName.text = name
        viewModel.updateProfileInfo(nickName: name)
    }
    
    func showAlert(message:String){
        let vc = CustomAlertInfoView()
            vc.comingTitle = "Success"
            vc.comingDescription = message
            vc.comingImage = "Group 71526"
            vc.alertConfirm = self
        self.presentOnViewController(with: vc)
    }
    
    func alertInfoAction(_ status: String) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func uploadFirstImage(_ sender: ResponsiveButton) {
        showIImagePicker()
    }
    
    @IBAction func updateNameBtnAction(_ sender: ResponsiveButton) {
        let vc = UpdateNameVC()
            vc.editProfileVC = self
            vc.comingName = lblName.text ?? ""
        self.presentOnViewController(with: vc)
    }
    
    func showIImagePicker(){
     
           let alert = UIAlertController()
           
           let chosse_action = UIAlertAction(title: "", style: .default , handler:{ (_) in
            print("User click Approve button")
           // self.openSingleGallery(isCamera: true)
           })
        
        let camera_action = UIAlertAction(title: "Take Picture", style: .default , handler:{ (UIAlertAction)in
                   print("User click Edit button")
                    
                   self.imagePicker.sourceType = .camera
                   //self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
                   self.imagePicker.delegate = self
                   self.imagePicker.allowsEditing = true
                   self.imagePicker.showsCameraControls = true
              
                  // self.imagePicker.videoMaximumDuration = TimeInterval(20.0)
                   //self.imagePicker.videoQuality = .type640x48
                 //  self.imagePicker.mediaTypes = [kUTTypep as String]
                   
                   self.present(self.imagePicker, animated: true, completion: nil)
               })
           
        let photo_action = UIAlertAction(title: "Photo Library", style: .default , handler:{ (UIAlertAction)in
            
               self.imagePicker.allowsEditing = true
               self.imagePicker.delegate = self
               
              // self.imagePicker.videoQuality = .type640x480

               self.imagePicker.sourceType = .photoLibrary
            //   self.imagePicker.mediaTypes = ["public.image", "public.movie"]

               self.present(self.imagePicker, animated: true, completion: nil)
           })
           
           
           alert.addAction(camera_action)
                   
           alert.addAction(photo_action)
           
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
               print("User click Dismiss button")

           }))
           
           self.present(alert, animated: true, completion: {
               print("completion block")
           })
           
       }
    
    @IBAction func logoutBtnAction(_ sender:UIButton){
        let vc = CustomAlertConfirmVC()
            vc.comingTitle = "Logout"
            vc.comingDescription = "Are you sure you want to logout from this device?"
            vc.comingImage = "Group 71524"
            vc.alertConfirm = self
        vc.yesBtnTitle = "Logout"
        self.presentOnViewController(with: vc)
    }
}

extension EditProfileVC:AlertConfimDelegate{
    func alertAction(_ status: String) {
        self.viewModel.logoutAccount()
//        let deviceToken = Utilities.shared.UDValue(.access_token)
//        Utilities.shared.clearAllUD()
//        Utilities.shared.UDSave(deviceToken, forKey: .access_token)
//        Router.showLogin()
    }
}

extension EditProfileVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModelInfo.getNumberOfRows() == 0{
            if #available(iOS 13.0, *) {
                self.setNoRecordsFoundLabel(tblView: self.tblView, lblText: "No record found.")
            } else {
                // Fallback on earlier versions
            }
        }
        else{
            self.tblView.backgroundView = UIView()
        }
        return self.viewModelInfo.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "VerifiedItemsTblCell", for: indexPath) as! VerifiedItemsTblCell
        
        let cellVM = self.viewModelInfo.getItem(At: indexPath)
        cell.backView.backgroundColor = .F_5_F_5_F_5
        cell.lblTitle.text = cellVM?.title
        cell.lblDescription.text = cellVM?.value//!selectedDataArr[indexPath.row] && cellVM.hidden == "1" ? String(repeating: "*", count: cellVM.value.count) : cellVM.value
         //   cell.lblDescription.text = cellVM.value
        cell.btnInfo.isHidden = true
        cell.btnInfo.isUserInteractionEnabled = false

        cell.trailingDescription.constant = 10//cellVM.hidden == "0" ? 10 : 55
        
//        if selectedDataArr.count > 0{
//            cell.btnInfo.isSelected = selectedDataArr[indexPath.row]
//        }
//        cell.btnInfo.tag = indexPath.row
//        cell.btnInfo.addTarget(self, action: #selector(btnInfoAction), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    
    @objc func btnInfoAction(_ sender:ResponsiveButton){
       // selectedDataArr[sender.tag] = !selectedDataArr[sender.tag]
        self.tblView.reloadData()
    }
}

extension EditProfileVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imgPkr = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            
                self.img_1_data = imgPkr.jpegData(compressionQuality: 0.5)!
                self.profileImage.image = imgPkr
            self.viewModel.updateProfileImage(profileImage: self.img_1_data ?? Data(), fileName: "image\(NSDate().timeIntervalSince1970).jpg")

         //   var n_image = imgPkr.resized(withPercentage: 0.5)

         //   n_image = n_image!.resized(toWidth: 300)
            
//                self.img_profile.image = imgPkr
//                self.imageDataProfile = imgPkr.jpegData(compressionQuality: 0.5)!
//                self.lbl_avatar.isHidden = true
//                self.selected_profile_pic = imgPkr
            }
            else{
//                self.img_cover.image = imgPkr
//                self.imageDataCOver = imgPkr.jpegData(compressionQuality: 0.5)!
//                self.selected_cover_pic = imgPkr
            }

         imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
