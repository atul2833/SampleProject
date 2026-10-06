//
//  LoginWithPhoneNumberVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit
import Combine

class LoginVC: BaseNavigationController {
    
    @IBOutlet weak var countryCodeBtn: UIButton!
    @IBOutlet weak var countryImage: UIImageView!

    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var countryTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!

    @IBOutlet weak var countryView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var emailView: UIView!

    @IBOutlet weak var topView: UIView!

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var termsView: UIView!

    var comingFrom = String()
    
    private var viewModel: RegisterViewModel
    //private var timerLabel: CustomTimerLabel!

    init(viewModel: RegisterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log.info("====== \(self) ======")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        stateObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = comingFrom.count == 0

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func setCurrentCountry() {
        
        // Get current device country
        guard let regionCode = Locale.current.regionCode else {
            print("❌ Unable to get current country")
            return
        }
        
        print("🌍 Device Country: \(regionCode)")
        
        // Get country from your countries.json
        let country = CountryManager.shared.getCountry(
            forCode: regionCode.uppercased()
        )
        
        // Set country code
        countryCodeBtn.setTitle(country.countryCode, for: .normal)
        
        // Set flag
        if let shortName = country.countryShortName {
            countryImage.image = UIImage(named: shortName.lowercased())
        }
        
        // Set country ID
        viewModel.countryId = "\(country.id ?? 228)"
    
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
    
    private func handleState(_ state: RegisterViewModel.State) {

        switch state {
        case .success:
            ProgressHudWrapper.dismiss()
            handleSuccess()
        case .error(let message):
            Log.error(message)
            ProgressHudWrapper.failed(message: message)
        case .loading:
            view.endEditing(true)
            ProgressHudWrapper.loadingIndicator()
        case .otpSent(let message):
            ProgressHudWrapper.dismiss()
            self.view.makeToast(message, position: .bottom)
        default:
            break
        }
    }
    
    private func handleSuccess(){
        let vc = VerifyOTPVC(viewModel: OTPCodeViewModel(userModel: UserRegisterRequestModel(phoneNumber: phoneTxt.text ?? "",emailAddress: "",fullName:"",countryId: viewModel.countryId ?? "228", comingFrom: "login")))

       self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func initView(){
     
        if comingFrom.count > 0{
            self.lblTitle.text = comingFrom == "updateEmail" ? "Update Your Email Address" : "Update Your Phone Number"
            self.termsView.isHidden = true
        }
        
        setCurrentCountry()
    }
    
    @IBAction func countryAction(_ sender: UIButton) {
        let countryVC = CountryCodeVC()
            countryVC.delegate = self
       //  let navctrl = UINavigationController(rootViewController: countryVC)
            
        self.present(countryVC, animated: true, completion: nil)
    }
    

    @IBAction func acceptBtnAction(_ sender: ResponsiveButton) {
        viewModel.isTermsSelected = !viewModel.isTermsSelected
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func registerBtnAction(_ sender: ResponsiveButton) {
        let vc = RegisterVC(viewModel: RegisterViewModel())
       self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func termsAndPrivacyAction(_ sender: ResponsiveButton) {
//       let vc = TermsAndPrivacyVC()
//         //  vc.coming_from = sender.tag == 0 ? "terms" : "privacy"
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func continueAction(_ sender: ResponsiveButton) {
        
        self.view.endEditing(true)
        
        let str = ValidationClass().validateLoginForm(self)
        
        if str.count > 0{
            self.view.makeToast(str)
        }
        else{
            self.viewModel.loginUser(phoneNumber: phoneTxt.text ?? "")
        }
    }
    
    @IBAction func loginAction(_ sender: ResponsiveButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func callPIN(){
//        let vc = VerifyPINVC()
//           // vc.verifyPINDelegate = self
//        self.presentOnViewController(with: vc)
    }
}

extension LoginVC:CountryDelegate{
    func didCountryClicked(_ country: Country) {
      // viewModel.countryCode = country.countryCode
        countryCodeBtn.setTitle(country.countryCode!, for: .normal)
        countryImage.image = UIImage(named:country.countryShortName!.lowercased())
        viewModel.countryId = "\(country.id ?? 228)"
//        countryTxt.text = country.countryName!
    }
}


