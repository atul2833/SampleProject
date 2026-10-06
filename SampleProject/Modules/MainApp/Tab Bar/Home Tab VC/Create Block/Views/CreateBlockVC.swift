//
//  CreateBlockVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 05/02/24.
//

import UIKit
import IQKeyboardManagerSwift
import DropDown

class CreateBlockVC: BaseNavigationController {

    @IBOutlet weak var txtName:UITextField!
    @IBOutlet weak var txtCity:UITextField!
    @IBOutlet weak var txtBlockName:UITextField!
    @IBOutlet weak var txtDescription:IQTextView!
    @IBOutlet weak var txtDepositRules:UITextField!
    @IBOutlet weak var txtDuration:UITextField!
    @IBOutlet weak var lblDepositRules:UILabel!
    @IBOutlet weak var lblCurrency:UILabel!

    @IBOutlet weak var lblDescriptionCount: UILabel!
    private var viewModel: CreateBlockViewModel
   
    private var selectedCityId = "1"
    private var selectedBlockDurationId = "1"
    private var selectedBlockDepositRuleId = "1"
    private var currency = AppUserDefaults.shared.UDValue(.countryCurrency) as? String

    init(viewModel: CreateBlockViewModel) {
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
        
        self.navigationItem.title = "Create Block"
        
        self.txtCity.delegate = self
        self.txtDuration.delegate = self
        self.txtDescription.delegate = self
        
        lblDescriptionCount.text = "MAX \(200) characters"
        self.viewModel.dropDownListData(type: "city")
        self.viewModel.dropDownListData(type: "blockDuration")
        self.viewModel.dropDownListData(type: "blockDepositRule")

        self.lblCurrency.text = currency ?? ""
        stateObserver()
       
        viewModel.dropDownListData(type: "city")
    }
    
    private func stateObserver() {
        self.viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .success(let message, let blockId):
                    let vc = MyContactsVC(viewModel: MyContactsViewModel(blockId: "\(blockId)"))
                    self?.navigationController?.pushViewController(vc, animated: true)
                    break
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
    
    
    @IBAction func durationBtnPressed(_ sender: ResponsiveButton) {
        addDropDown(sender)
    }

    @IBAction func inviteBtnPressed(_ sender: ResponsiveButton) {
        
        self.view.endEditing(true)
        
        let str = ValidationClass().validateCreateBlockForm(self)
        
        if str.count > 0{
            self.view.makeToast(str)
        }
        else{
            let dataDict = ["name":txtName.text!,"cityId":selectedCityId,"blockName":txtBlockName.text!,"description":txtDescription.text!,"blockDepositRuleId":selectedBlockDepositRuleId,"blockDurationId":selectedBlockDurationId,"amount":txtDepositRules.text!] as [String : Any]
            self.viewModel.createBlock(dict: dataDict)
        }
    }
    
    func addDropDown(_ sender:UIView){
        let dropDown = DropDown()

        dropDown.anchorView = sender // UIView or UIBarButtonItem
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)

        dropDown.dataSource = (sender.tag == 0 ? viewModel.getCityList()?.map{$0.title} : sender.tag == 1 ? viewModel.getDepositRulesList()?.map{$0.title} : viewModel.getDurationList()?.map{$0.title}) as? [String] ?? []

        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if sender.tag == 0{
                self.txtCity.text = item
                self.selectedCityId = viewModel.getCityList()?[index].id ?? "0"
            }
            else if sender.tag == 1{
                self.lblDepositRules.text = item
                self.selectedBlockDepositRuleId = viewModel.getDepositRulesList()?[index].id ?? "0"
            }
            else{
                self.txtDuration.text = item
                self.selectedBlockDurationId = viewModel.getDurationList()?[index].id ?? "0"
            }
        }
        dropDown.show()
    }
}

extension CreateBlockVC:UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        addDropDown(textField)
        return false
    }
}
extension CreateBlockVC: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        let maxCharacters = 200

        if textView.text.count > maxCharacters {
            textView.text = String(textView.text.prefix(maxCharacters))
        }

        let remainingCharacters = maxCharacters - textView.text.count
        lblDescriptionCount.text = "MAX \(remainingCharacters) characters"
    }
}
