//
//  VerifyInformationVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 05/01/24.
//

import UIKit

class VerifyInformationVC: BaseNavigationController {

    @IBOutlet weak var tblView:UITableView!

    var info = String()
    
    private var viewModel: VerifyIdentityViewModelProtocol
    
    init(viewModel: VerifyIdentityViewModelProtocol){
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
        self.viewModel.getUserKycInfo()
    }
    
    private func stateObserver() {
        viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &viewModel.cancellable)
    }
    
    private func handleState(_ state: VerifyIdentityViewModel.State) {
        
        switch state {
            case .loading:
                ProgressHudWrapper.loadingIndicator()
            case .successList:
                ProgressHudWrapper.succeed()
                self.tblView.reloadData()
            case .success:
                ProgressHudWrapper.dismiss()
                handleSuccess()
            case .error(let message):
                ProgressHudWrapper.dismiss()
                view.makeToast(message, position: .bottom)
            default:
                ProgressHudWrapper.dismiss()
        }
    }
    
    private func handleSuccess() {
        ProgressHudWrapper.succeed()
        
        if AppUserDefaults.shared.UDValue(.isLoggedIn) as? Bool ?? false {
            self.navigationController?.popToRootViewController(animated: true)
        }
        else{
            let vc = SubscriptionVC(viewModel: SubscriptionViewModel())
            self.navigationController?.pushViewController(vc, animated: true)
        }
//        let vc = ScanFaceVC()
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func tryAgainBtnAction(_ sender: ResponsiveButton) {
        
        if let completeProfileVC = self.navigationController?.viewControllers.first(where: { $0 is CompleteProfileVC }) {
            self.navigationController?.popToViewController(completeProfileVC, animated: true)
        }
    }
    
    @IBAction func confirmBtnAction(_ sender: ResponsiveButton) {
//        self.viewModel.saveKYCData(type: "completed")
    }
    
    func initView() {
        self.navigationItem.title = "Information"
        tblView.register(UINib(nibName: "VerifiedItemsTblCell", bundle: nil), forCellReuseIdentifier: "VerifiedItemsTblCell")
    }
}

extension VerifyInformationVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel.getNumberOfRows() == 0{
            if #available(iOS 13.0, *) {
                self.setNoRecordsFoundLabel(tblView: self.tblView, lblText: "No record found.")
            } else {
                // Fallback on earlier versions
            }
        }
        else{
            self.tblView.backgroundView = UIView()
        }
        return self.viewModel.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "VerifiedItemsTblCell", for: indexPath) as! VerifiedItemsTblCell
        
//        let cellVM = self.viewModel.getItem(At: indexPath)
//        cell.lblTitle.text = cellVM?.title
//        cell.lblDescription.text = cellVM?.value//!selectedDataArr[indexPath.row] && cellVM.hidden == "1" ? String(repeating: "*", count: cellVM.value.count) : cellVM.value
//         //   cell.lblDescription.text = cellVM.value
//        cell.btnInfo.isHidden = true
//        cell.btnInfo.isUserInteractionEnabled = false

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
