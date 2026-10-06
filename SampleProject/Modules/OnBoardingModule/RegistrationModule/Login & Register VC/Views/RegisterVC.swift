//
//  RegisterVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 02/02/24.
//

import UIKit
import DropDown

class RegisterVC: BaseNavigationController{
    
    @IBOutlet weak var countryCodeBtn: UIButton!
    @IBOutlet weak var countryImage: UIImageView!

    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var cityTxt: UITextField!

    private var viewModel: RegisterViewModel
    //private var timerLabel: CustomTimerLabel!

    private var selectedCountryId = String()
    private var selectedCityId = String()

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
        stateObserver()
        
        cityTxt.delegate = self
        
       // viewModel.dropDownListData(countryId: selectedCountryId)
        setCurrentCountry()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
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
        viewModel.countryId = "\(country.id ?? 37)"
        selectedCountryId = "\(country.id ?? 37)"
        viewModel.dropDownListData(countryId: "\(country.id ?? 228)")
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
        case .listFetched:
            break
        }
    }
    
    private func handleSuccess(){
        let vc = VerifyOTPVC(viewModel: OTPCodeViewModel(userModel: UserRegisterRequestModel(phoneNumber: phoneTxt.text ?? "",emailAddress: emailTxt.text ?? "",fullName: nameTxt.text ?? "",cityId: self.selectedCityId,countryId: self.selectedCountryId,comingFrom: "register")))

       self.navigationController?.pushViewController(vc, animated: true)
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
    
    
    @IBAction func termsAndPrivacyAction(_ sender: ResponsiveButton) {
        if sender.tag == 0 {
            let URLString = ServerConfiguration.shared.termsOfServiceURL
                    openURLInSafari(urlString: URLString)
                } else {
                    let URLString = ServerConfiguration.shared.privacyPolicyURL
                    openURLInSafari(urlString: URLString)
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
    }
    
    @IBAction func loginBtnAction(_ sender: ResponsiveButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueAction(_ sender: ResponsiveButton) {
        
        self.view.endEditing(true)
        
        let str = ValidationClass().validateRegisterForm(self)
        
        if str.count > 0{
            self.view.makeToast(str)
        }
        else if !viewModel.isTermsSelected{
            self.view.makeToast(Strings().check_terms_toast)
        }
        else{
            self.viewModel.signUpUserData(phoneNumber: self.phoneTxt.text!, emailAddress: self.emailTxt.text!, fullName: self.nameTxt.text!, cityId: self.selectedCityId, countryId: selectedCountryId)
        }
    }
    
    @IBAction func loginAction(_ sender: ResponsiveButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func sendToVerifyOTP(){
//        let vc = VerifyOTPVC()
////           vc.apiCredentials = self.viewModel.apiCredentials
////           vc.comingFrom = self.comingFrom
//       self.navigationController?.pushViewController(vc, animated: true)

    }
}


extension RegisterVC:CountryDelegate{
    func didCountryClicked(_ country: Country) {
       // viewModel.countryCode = country.countryCode!
        countryCodeBtn.setTitle(country.countryCode!, for: .normal)
        countryImage.image = UIImage(named:country.countryShortName!.lowercased())
        viewModel.dropDownListData(countryId: "\(country.id ?? 228)")

        self.selectedCountryId = "\(country.id ?? 228)"
//        countryTxt.text = country.countryName!
    }
}

extension RegisterVC:UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if viewModel.getCityList() == nil{
            self.view.makeToast("Cities not available!")
        }
        else{
            addDropDown(textField)
        }
        return false
    }
}

extension RegisterVC {
    func addDropDown(_ sender:UIView){
        let dropDown = DropDown()

        dropDown.anchorView = sender // UIView or UIBarButtonItem
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)

        dropDown.dataSource =  viewModel.getCityList()?.map{$0.title} as? [String] ?? []

        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                self.cityTxt.text = item
                self.selectedCityId = viewModel.getCityList()?[index].id ?? "0"
            
        }
        dropDown.show()
    }}

