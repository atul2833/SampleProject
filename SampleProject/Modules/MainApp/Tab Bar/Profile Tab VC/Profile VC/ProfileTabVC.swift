//
//  SettingsVC.swift
//  SatPay
//
//  Created by Niketan Sharma on 18/11/20.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit
import SDWebImage
import LocalAuthentication

class ProfileTabVC: BaseSlideViewController {

    @IBOutlet weak var lblPlanPrice: UILabel!
    @IBOutlet weak var lblPlanName: UILabel!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var heightTblView: NSLayoutConstraint!

    @IBOutlet weak var lblPlanExpDate: UILabel!
    @IBOutlet weak var lblPlanType: UILabel!
    private var viewModel: ProfileViewModel
    private var currency = AppUserDefaults.shared.UDValue(.countryCurrency) as? String
    private var isBiometricEnable = AppUserDefaults.shared.UDValue(.isBiometricEnable) as? String

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

        //initVM()
        initView()
        setNavigationBar()
        stateObserver()
        topView.addGradientToView(colors: [UIColor.appGreen,UIColor.appBase])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setData()
        NotificationCenter.default.addObserver(self, selector: #selector(nextNotify(_:)), name: Notification.Name("BioSuccess"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(Notification.Name("BioSuccess"))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.heightTblView.constant = self.tblView.contentSize.height
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
    
    func setData(){
        let userContext = self.viewModel.getUserContext()
        let model = userContext.getUserInformation().profileModel
        
        self.lbl_name.text = model?.fullName
        self.imgView.sd_setImage(with: model?.profileImageUrl, placeholderImage: .none)
        
        let planModel = model?.userSubscriptionPlan
        
        self.lblPlanName.text = planModel?.title
        self.lblPlanType.text = planModel?.duration
        self.lblPlanPrice.text = "\(currency ?? "")\(planModel?.price ?? "")"
        self.lblPlanExpDate.text = planModel?.expirationDate
    }
    
    func setNavigationBar(){
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        customView.isUserInteractionEnabled = true // Enable user interaction

           let label = UILabel(frame: CGRect(x: 10, y: 0, width: 160, height: 40))
           label.text = "Profile"
           label.textColor = .appBase
        label.font = AppFont.bold(.title)
        customView.addSubview(label)
       
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(customView: customView)
    }
    
    func initView() {
        
        tblView.register(UINib(nibName: "ProfileTblCell", bundle: nil), forCellReuseIdentifier: "ProfileTblCell")
        tblView.register(UINib(nibName: "TitleHeaderTblCell", bundle: nil), forCellReuseIdentifier: "TitleHeaderTblCell")
        
       // tblView.tableFooterView = UIView()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
    }
    
    @IBAction func editProfileBtnAction(_ sender:ResponsiveButton){
        let vc = EditProfileVC(viewModel: ProfileViewModel(userContext: viewModel.getUserContext()), viewModelInfo: VerifyIdentityViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func callBioMetric(){
        let vc = BioMetricVC()
        self.present(vc, animated: false, completion:nil )
    }
    
    
    @objc func nextNotify(_ notification:Notification){

        let object_dict = notification.object as? NSDictionary
        
        if object_dict != nil{
            
            let data =  object_dict!["data"] as? String
            
            if data == "success"{
                if !isInBackground{
                    AppUserDefaults.shared.UDSave("no", forKey: .isBiometricEnable)
                }
                isInBackground = false
               // callingSendMoneyDataAPI()

                self.dismiss(animated: false, completion: nil)
            }
            else if data == "fail"{
                callBioMetric()
            }
            else{

            }
        }
    }
}

extension ProfileTabVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionArr.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sectionArr[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTblCell", for: indexPath) as! ProfileTblCell
      
        let list = viewModel.sectionArr[indexPath.section][indexPath.row]
        
        let userContext = self.viewModel.getUserContext()
        let model = userContext.getUserInformation().profileModel

        cell.lblTitle.text = (list.slug == "kyc" && model?.kycDone == "completed") ? "KYC Verified" : list.title
        cell.imgView.image = UIImage(named: list.image)
        cell.lblDes.text = list.description
        cell.switchIs.isHidden = !(list.slug == "app_notification" || list.slug == "biometric")
        

        cell.switchIs.isOn = list.slug == "app_notification" ? (model?.isNotificationEnabled ?? false) : isBiometricEnable == "yes"
        cell.imgArrow.isHidden = (list.slug == "app_notification" || list.slug == "biometric")
        cell.imgArrow.image = UIImage(named: list.slug == "kyc" && model?.kycDone == "completed" ? "Layer 2" : "Icon feather-chevron-down-21")
        cell.viewActivate.isHidden = !(list.slug == "kyc" && model?.kycDone != "completed")
        cell.topTitle.constant = list.description == "" ? 6 : 2
        //cell.switchIs.isOn = security == "yes"
        
        cell.switchIs.accessibilityIdentifier = list.slug
        cell.switchIs.addTarget(self, action: #selector(switchBtnAction(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleHeaderTblCell") as! TitleHeaderTblCell
        cell.lblTitle.text = section == 0 ? "PERTIONAL DETAILS" : section == 1 ? "NOTIFICATIONS" : "OTHERS"
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let list = viewModel.sectionArr[indexPath.section][indexPath.row]

        let userContext = self.viewModel.getUserContext()
        let model = userContext.getUserInformation().profileModel
        
        switch list.slug {
        case "kyc":
            if model?.kycDone != "completed"{
                let vc = KycVC(viewModel: VerifyIdentityViewModel())
                self.navigationController?.pushViewController(vc, animated: true)
//                let vc = CompleteProfileVC(viewModel: VerifyIdentityViewModel())
//                self.navigationController?.pushViewController(vc, animated: true)
            }
        case "account":
            let vc = AccountVC(viewModel: ProfileViewModel(userContext: viewModel.getUserContext()))
            self.navigationController?.pushViewController(vc, animated: true)
            
        case "help":
            let vc = HelpCenterVC(viewModel: HelpCenterViewModel(userId: ""))
            self.navigationController?.pushViewController(vc, animated: true)
            
        case "rental_property":
            let vc = RentalPropertiesVC(viewModel: RentalViewModel())
            self.navigationController?.pushViewController(vc, animated: true)
        
        case "about":
            let vc = AboutAppVC()
            self.navigationController?.pushViewController(vc, animated: true)
            
        case "conti_amount":
            self.tabBarController?.selectedIndex = 2
        
        case "terms":
            let URLString = ServerConfiguration.shared.termsOfServiceURL
            openURLInSafari(urlString: URLString)
            
        case "privacy":
            let URLString = ServerConfiguration.shared.privacyPolicyURL
            openURLInSafari(urlString: URLString)
            
        case "block_history":
            let vc = BlockHistoryVC(viewModel: BlockViewModel(), createViewModel: CreateBlockViewModel(userContext: viewModel.getUserContext()))
            self.navigationController?.pushViewController(vc, animated: true)
        default:
                break
          }
    }
    
    func openURLInSafari(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        guard UIApplication.shared.canOpenURL(url) else {
            print("Safari cannot be opened with this URL")
            return
        }
        UIApplication.shared.open(url)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 1 ? 60 : 50
    }
    
    @objc func switchBtnAction(_ sender:UISwitch){
        if sender.accessibilityIdentifier == "app_notification"{
            self.viewModel.updateNotificationSetting(isNotificationEnabled:sender.isOn)
        }
        else{
            if sender.isOn{
                authenticateCheck()
            }
            else{
                callBioMetric()
            }
        }
    }
    
    func authenticateCheck() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            print("Face Available")
            AppUserDefaults.shared.UDSave("yes", forKey: .isBiometricEnable)
        }
        else {
            checkWithPasscodeCheck()
            // Device doesn't support biometrics
        }
    }
    
    func checkWithPasscodeCheck() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Identify yourself!"
            AppUserDefaults.shared.UDSave("yes", forKey: .isBiometricEnable)
        } else{
            
            AppUserDefaults.shared.UDSave("no", forKey: .isBiometricEnable)
            self.tblView.reloadData()
        
            let ac = UIAlertController(title: "Biometry and Passcode unavailable", message: "Your device is not configured for biometry and Passcode authentication. Do you want to setup security?", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Yes", style: .default) { (_) in
                
                if let url1 = URL(string: "App-Prefs:root=TOUCHID_PASSCODE") {
                    guard let url = URL(string: "\(url1)"), !url.absoluteString.isEmpty else {
                          return
                       }
                    self.dismiss(animated: false, completion: nil)
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
            let action1 = UIAlertAction(title: "No", style: .cancel) { (_) in
                self.dismiss(animated: false, completion: nil)
            }
            ac.addAction(action)
            ac.addAction(action1)

            DispatchQueue.main.async {
                self.present(ac, animated: true)
            }
            // no biometry
        }
    }
}

