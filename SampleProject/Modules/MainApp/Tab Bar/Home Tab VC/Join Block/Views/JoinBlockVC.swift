//
//  JoinBlockVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 06/02/24.
//

import UIKit

class JoinBlockVC:  BaseNavigationController, AlertConfimDelegate {
    func alertAction(_ status: String) {
        self.viewModel.joinBlock(dict: ["block":txtBlockId.text ?? "","password":txtBlockPassword.text ?? ""])
    }
    
    
    @IBOutlet weak var txtBlockPassword: UITextField!
    @IBOutlet weak var txtBlockId: UITextField!
    private var viewModel: JoinBlockViewModel

    init(viewModel: JoinBlockViewModel) {
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
        
        self.navigationItem.title = "Join Block"
        stateObserver()
        
        txtBlockId.text = viewModel.blockId
        txtBlockPassword.text = viewModel.password
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
                    self?.handleSuccess(message: message, title: "Success")
                    break
                case .error(let message):
                    Log.error(message)
                    self?.handleSuccess(message: message, title: "Failed")
                    //self?.view.makeToast(message, position: .bottom)
                case .logout:
                    let tabBar = self?.tabBarController as? HomeTabBarController
                    tabBar?.logout()
                default:
                    break
                }
            }
            .store(in: &self.viewModel.cancellable)
    }
    
//    func handleSuccess(message:String){
//
//        let vc = CustomAlertInfoView()
//            vc.comingTitle = "Success"
//            vc.comingDescription = message
//            vc.comingImage = "Group 71526"
//            vc.alertConfirm = self
//        self.presentOnViewController(with: vc)
//    }
    
    func handleSuccess(message:String, title: String){
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
    
    @IBAction func continueBtnAction(_ sender:ResponsiveButton){
        let str = ValidationClass().validateJointBlockForm(self)
        
        if str.count > 0{
            self.view.makeToast(str)
        }
        else{
            
            let vc = CustomAlertListVC(viewModel: CustomAlertListViewModel(type: "joinBlock"))
                       vc.comingImage = "joinBlock"
                       vc.alertConfirm = self
                       vc.yesBtnTitle = "Yes, Join"
                   self.navigationController?.pushViewController(vc, animated: true)
//            self.viewModel.joinBlock(dict: ["block":txtBlockId.text ?? "","password":txtBlockPassword.text ?? ""])
        }
//        let vc = BlockDetialsVC()
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension JoinBlockVC: AlertInfoDelegate{
    func alertInfoAction(_ status: String) {
        
        if status == "Failed" {
            self.navigationController?.popViewController(animated: true)
        }else{
            let vc = BlockDetailsVC(viewModel: BlockDetailViewModel(blockId: txtBlockId.text ?? ""), contributionViewModel: ContributionViewModel( blockId:txtBlockId.text ?? "0"))
                //    vc.transactionId = cellVM.transactionId
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
       
    }
}
