//
//  VerifyVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit

class VerifyOTPVC: BaseNavigationController{
    
    @IBOutlet weak var otpView: VPMOTPView!
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var lblVerifyTxt: UILabel!
    @IBOutlet weak var timerLabel: CustomTimerLabel!
    @IBOutlet weak var trailingTimer: NSLayoutConstraint!

    var fromScreen = String()
    
    private var viewModel: OTPCodeViewModel
    //private var timerLabel: CustomTimerLabel!

    init(viewModel: OTPCodeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log.info("====== \(self) ======")
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        initOTPViewBuilder()
        stateObserver()
      //  initVM()
        
      //  lblVerifyTxt.text = (comingFrom == "updatePhone" || comingFrom == "") ? "Phone Number Verification " : "Email Address Verification"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
    }
    
    func initOTPViewBuilder(){
        otpView.otpFieldEntrySecureType = false
        otpView.otpFieldDefaultBackgroundColor = UIColor.white
        otpView.otpFieldsCount = 6
        otpView.otpFieldBorderWidth = 1
        otpView.otpFieldDefaultBorderColor = UIColor.appGray
        otpView.otpFieldEnteredBorderColor = UIColor.appGray
        otpView.delegate = self
        otpView.shouldAllowIntermediateEditing = false
        otpView.otpFieldDisplayType = .square
        otpView.otpFieldDefaultBorderColor = UIColor.appGray
        otpView.otpFieldEnteredBorderColor = UIColor.appGray
        otpView.otpFieldSize = (ScreenSize.SCREEN_WIDTH - 24) * 0.1173
       
        otpView.initializeUI()
            //   self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissController))
        
        otpView.becomeFirstResponder()
        
        startTimer()
    }
    
    func startTimer(){
        self.resendBtn.isUserInteractionEnabled = false

        self.timerLabel.startTimer(seconds: self.viewModel.getTimeInSeconds()) {
            self.resendBtn.isUserInteractionEnabled = true
            self.resendBtn.isHidden = false

            self.resendBtn.setTitleColor(.black, for: .normal)
            self.timerLabel.isHidden = true
        }
    }
    private func stateObserver() {
        viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // Handle completion if needed
            } receiveValue: { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &viewModel.cancellable)
    }
    
    private func handleState(_ state: OTPCodeViewModel.State) {

        switch state {
        case .success(let model):
            ProgressHudWrapper.dismiss()
           //model?.kycDone == "inComplete"
            if model?.kycStatus == "notAttempted"{
                let vc = KycVC(viewModel: VerifyIdentityViewModel())
                vc.commingFrom = "fromOTP"
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if !(model?.isSubscribed ?? false) {
                let vc = SubscriptionVC(viewModel: SubscriptionViewModel())
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else{
                self.openHomeTabBar()
            }
        case .error(let message):
            Log.error(message)
            ProgressHudWrapper.failed(message: message)
        case .loading:
            view.endEditing(true)
            ProgressHudWrapper.loadingIndicator()
        case .otpSent(let message):
            ProgressHudWrapper.dismiss()
            self.view.makeToast(message, position: .bottom)
        }
    }
    
    
    private func openHomeTabBar() {
        let vc = HomeTabBarController(userContext: UserContext.create(with: UserInformation()))
        AppUserDefaults.shared.UDSave(true, forKey: .isLoggedIn)
        UIApplication.shared.windows.first?.rootViewController = vc
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    func setKYCNavigation(response:OTPResponseModel){
//        switch response.isKYCRequired {
//         case "Yes":
//            let vc = CompleteProfileVC()
//            self.navigationController?.pushViewController(vc, animated: true)
//            
//         case "No":
//             let vc = SetSecurityVC()
//             self.navigationController?.pushViewController(vc, animated: true)
//        default:
//            print("Error:")
//        }
    }

    @IBAction func continueAction(_ sender:UIButton) {
        
        self.view.endEditing(true)
        print("viewModel.getComingType()")
        print(viewModel.countryId)
        if viewModel.entered_otp?.count == 0{
            self.view.makeToast(Strings().otp)
        }
        else{
            if viewModel.getComingType() == "login" || viewModel.getComingType() == "register"{
                self.viewModel.verifyNumberWith(OTP: viewModel.entered_otp ?? "")
            }
            else{
                self.viewModel.verifyNumberOrEmail(OTP: viewModel.entered_otp ?? "", countryId: viewModel.countryId ?? "")
            }
        }
        
//        if fromScreen == "loginScreen"{
//           // Router.showMain()
//        }else{
////            let vc = CompleteProfileVC()
////            self.navigationController?.pushViewController(vc, animated: true)
//        }
       
    }

    @IBAction func resendOtp(_ sender:ResponsiveButton){
        self.viewModel.resendOTP()
        self.timerLabel.isHidden = false
        self.resendBtn.isUserInteractionEnabled = false
        self.resendBtn.isHidden = true

        self.resendBtn.setTitleColor(.appGray, for: .normal)
        self.startTimer()
    }
}


extension VerifyOTPVC: VPMOTPViewDelegate {
    func hasEnteredAllOTP(hasEntered: Bool) -> Bool {
        if !hasEntered{
            viewModel.entered_otp = ""
        }
        print("Has entered all OTP? \(hasEntered)")
        return true
    }
    
    func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otpString: String) {
        viewModel.entered_otp = otpString
    }
}
