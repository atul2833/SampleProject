//
//  TransferMoneyVC.swift
//  MoneyMoov
//
//  Created by Rahul Jangid on 20/06/24.
//

import UIKit
var isInBackground = false

class SendMoneyVC: BaseNavigationController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!

    @IBOutlet weak var lblPaidAmount: UILabel!
    @IBOutlet weak var imgDropdown: UIImageView!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var lblFee: UILabel!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var btnDropdown: ResponsiveButton!
    @IBOutlet weak var viewFee: UIView!
    @IBOutlet weak var btnProceed: ResponsiveButton!
    @IBOutlet weak var viewNotes: UIView!

    private var walletViewModel: WalletViewModel
    private var paymentMethod: PaymentMethod?

    private var selectedCountry: String?
    private var comingFrom: String?

    var currency = AppUserDefaults.shared.UDValue(.countryCurrency) as? String ?? "CAD"

    init(walletViewModel: WalletViewModel,comingFrom:String?, paymentMethod:PaymentMethod) {
        self.walletViewModel = walletViewModel
        self.paymentMethod = paymentMethod
        self.comingFrom = comingFrom
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        Log.info("====== \(self) ======")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()

        walletStateObserver()
        
        self.navigationItem.title = "Add funds via \(comingFrom ?? "")"
        
        imgDropdown.isHidden = true
        btnDropdown.isHidden = true
     //   viewFee.isHidden = comingFrom != "send"
        
        txtAmount.delegate = self
        txtDescription.delegate = self

        txtAmount.addTarget(self, action: #selector(amountChanged(_:)), for: .editingChanged)
        
        self.lblCurrency.text = currency
        self.btnProceed.setTitle("Add Fund", for: .normal)
        self.viewNotes.isHidden = true
        showPaymentMethodData()
      //  walletViewModel.getPaymentMethod(type: comingFrom ?? "")

    }
   
    
    private func walletStateObserver() {
        self.walletViewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .success:
                    break
                case .paymentMethodFetched:
                    self?.showPaymentMethodData()
                case .addFund(let transactionId, let redirectUrl):
                    guard let self = self else { return }
                    let vc = PaymentWebViewVC(
                           redirectURL: redirectUrl ?? "",
                           transactionId: transactionId ?? "",
                           gateway: comingFrom ?? "", walletViewModel: walletViewModel
                           
                       )

                       vc.delegate = self

                       self.navigationController?.pushViewController(
                           vc,
                           animated: true
                       )
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
            .store(in: &self.walletViewModel.cancellable)
    }
    
    func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    func formatNumberCurrent(_ number: Double) -> String {
        let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    func removeCommas(from input: String) -> String {
        return input.replacingOccurrences(of: ",", with: "")
    }
    
    func setDataOfCurrencyList(){
//        let countryDataFrom = walletViewModel.setSelectedCountryFrom(index: 0)
//        self.lblCurrency.text = countryDataFrom?.currency
    }
    
    func showPaymentMethodData(){
        let bankData = walletViewModel.getBankPaymentData()
        lblTitle.text = paymentMethod?.title
        lblSubtitle.text = bankData?.accountNumber
        imgView.sd_setImage(with: paymentMethod?.payImageUrl)
    }
    
    func goToTransactionDetail(transactionId:String?){
        let vc = TransactionDetailVC(viewModel: TransactionViewModel(transactionId: transactionId))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showTransactionFeeData(){
      //  let data = walletViewModel.getTransactionFeeData()
        
      //  lblFee.text = "Transaction Fees: \(data?.currency ?? "") \(data?.transactionFees ?? 0) \(data?.type == "PERCENTAGE" ? "(\(data?.percentage ?? 0)%)" : "")"

      //  lblPaidAmount.text = "\(data?.currency ?? ""): \(data?.amountToBePaid ?? 0)"
    //    btnProceed.setTitle("\("Add Fund (")\("\(data?.currency ?? ""): \(data?.amountToBePaid ?? 0)"))", for: .normal)
    }
    
    @IBAction func currencyBtnAction(_ sender: ResponsiveButton) {
//        let vc = CountryCurrencyListVC()
//            vc.delegate = self
//           // vc.dataArr = sender.tag == 0 ? walletViewModel.getCurrencyListFrom() : walletViewModel.getCurrencyListTo()
//            vc.isFirstDropDown = sender.tag == 0
//        self.presentOnRoot(with: vc)
    }
    
    @IBAction func nextBtn(_ sender: ResponsiveButton) {
        self.view.endEditing(true)
    
        let isBlank = ValidationClass().isBlank(txtAmount)
        if isBlank{
            self.view.makeToast("Please enter amount!")
        }
        else{
            goForPayment()
        }
    }
    
    func goForPayment(){
        //let bankData = walletViewModel.getBankPaymentData()
        self.walletViewModel.addFund(dict: ["amount":txtAmount.text ?? "","type": comingFrom ?? ""])
    }

}

extension SendMoneyVC:UITextFieldDelegate{
    
    @objc func amountChanged(_ sender:UITextField){
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtAmount{
            return checkValidattionDecimalAndMax(textField, shouldChangeCharactersIn: range, replacementString: string, maxAmount: "1000000")
        }
        else{
            let currentText = textField.text ?? ""
                   guard let stringRange = Range(range, in: currentText) else {
                       return false
                   }
                   let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 50
        }
  }
}

extension UIViewController{
    
    func checkValidattionDecimalAndMax(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String,maxAmount:String)->Bool{
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }

        let newText1 = oldText.replacingCharacters(in: r, with: string)
        let newText = newText1.replacingOccurrences(of: ",", with: "")
        let isNumeric = newText.isEmpty || (Double(newText) != nil)
        let numberOfDots = newText.components(separatedBy: ".").count - 1

        let numberOfDecimalDigits: Int
        if let dotIndex = newText.firstIndex(of: ".") {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }

        // Define your maximum amount here
        let maximumAmount: Double = Double(maxAmount.replacingOccurrences(of: ",", with: "")) ?? 0.0// Change this to your desired maximum amount

        // Check if the entered value is numeric and within the allowed range
        let enteredAmount = Double(newText) ?? 0.0
        let isWithinMaximumAmount = enteredAmount <= maximumAmount

        return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2 && isWithinMaximumAmount
    }
}

extension SendMoneyVC: PaymentWebViewDelegate {

    func paymentFinished(
        transactionId: String,
        gateway: String
    ) {

        print("Payment finished")
        print("Gateway:", gateway)
        print("Transaction:", transactionId)
        goToTransactionDetail(transactionId: transactionId)
        // Call common payment verification API
//        walletViewModel.verifyPayment(
//            transactionId: transactionId,
//            gateway: gateway
//        )
    }
}
