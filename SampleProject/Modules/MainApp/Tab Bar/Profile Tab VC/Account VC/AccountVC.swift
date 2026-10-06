//
//  AccountVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 14/01/24.
//

import UIKit

class AccountVC: BaseNavigationController, AlertInfoDelegate {

    @IBOutlet weak var tblView:UITableView!

    var menu_arr = [
                    (title: "Email Address:", description: "Verify"),
                    (title: "Phone number:", description:""),
                   ]
    
    private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
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

        self.navigationItem.title = "Account"
        tblView.register(UINib(nibName: "AccountTblCell", bundle: nil), forCellReuseIdentifier: "AccountTblCell")
        stateObserver()
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
                    break
                    
                case .sendToVerify(let type,let phoneNumber,let countryCode,let emailAddress, let countryId):
                    
                    let vc = VerifyOTPVC(viewModel: OTPCodeViewModel(userModel: UserRegisterRequestModel(phoneNumber: phoneNumber,emailAddress: emailAddress,fullName:"",countryId: countryId, comingFrom: type)))
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                    break
                case .error(let message):
                    self?.showAlert(message: message, title: "Failed")
                    Log.error(message)
                   // self?.view.makeToast(message, position: .bottom)
                case .logout:
                    let tabBar = self?.tabBarController as? HomeTabBarController
                    tabBar?.logout()
                default:
                    break
                }
            }
            .store(in: &self.viewModel.cancellable)
    }
    
    func updateEmail(email:String){
        viewModel.updateEmailOrPhone(type: "email", phoneNumber: "", countryCode: "", emailAddress: email, countryId: "")
    }
    
    func updatePhone(countryCode:String,phone:String, countryId: String ){
        viewModel.updateEmailOrPhone(type: "phone", phoneNumber: phone, countryCode: countryCode, emailAddress: "", countryId: countryId)
    }
    
    
    func showAlert(message:String, title: String){
        let vc = CustomAlertInfoView()
        vc.comingTitle = title
        vc.comingDescription = message
        if title == "Failed" {
            vc.comingImage = "Group -22"
        }else{
            vc.comingImage = "Group 71526"
        }
        vc.alertConfirm = self
        self.presentOnViewController(with: vc)
    }
    
    func alertInfoAction(_ status: String) {
       // self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
    
    @IBAction func deleteBtnAction(_ sender:UIButton){
        
        let vc = CustomAlertListVC(viewModel: CustomAlertListViewModel(type: "deleteAccount"))
            vc.comingImage = "Group 71527"
            vc.alertConfirm = self
            vc.yesBtnTitle = "Yes, Delete"
        self.navigationController?.pushViewController(vc, animated: true)
        
//        let vc = CustomAlertConfirmVC()
//            vc.comingTitle = "Delete Account"
//            vc.comingDescription = "Are you sure you want to delete your account?"
//            vc.comingImage = "Group 71528"
//            vc.alertConfirm = self
//            vc.yesBtnTitle = "Delete"
//        self.presentOnViewController(with: vc)
    }
}

extension AccountVC:AlertConfimDelegate{
    func alertAction(_ status: String) {
        self.viewModel.deleteAccount()
    }
}

extension AccountVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu_arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTblCell", for: indexPath) as! AccountTblCell
      
        let userContext = self.viewModel.getUserContext()
        let model = userContext.getUserInformation().profileModel
        
        let list = menu_arr[indexPath.row]
        cell.lbl.text = list.title
        cell.lbl_des.isHidden = !(indexPath.row == 0 && !(model?.isEmailVerified ?? false))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        let userContext = self.viewModel.getUserContext()
        let model = userContext.getUserInformation().profileModel
        
        
        if indexPath.row == 0{
            let vc = UpdateEmailVC()
                vc.accountVC = self
                vc.comingEmail = model?.emailAddress ?? ""

            self.presentOnViewController(with: vc)
        }
        else{
     
            let vc = UpdatePhoneVC()
                vc.accountVC = self
                vc.phoneNumber = model?.phoneNumber ?? ""
                vc.countryCode = model?.countryCode ?? ""
                vc.countryId = model?.countryId ?? ""
            self.presentOnViewController(with: vc)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
