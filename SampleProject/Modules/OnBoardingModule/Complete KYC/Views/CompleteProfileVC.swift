//
//  CompleteProfileVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 05/01/24.
//

import UIKit

class CompleteProfileVC: BaseNavigationController {

    @IBOutlet weak var btnSkip:ResponsiveButton!
    
    private var viewModel: VerifyIdentityViewModel
    //private var timerLabel: CustomTimerLabel!

    init(viewModel: VerifyIdentityViewModel) {
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

        self.navigationItem.title = "Complete Your KYC"
        
         stateObserver()
        
         if AppUserDefaults.shared.UDValue(.isLoggedIn) as? Bool ?? false {
             self.btnSkip.isHidden = true
             self.btnSkip.isEnabled = false
         }
        // Do any additional setup after loading the view.
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
    
    func handleSuccess(){
        let vc = SubscriptionVC(viewModel: SubscriptionViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func scanBtnAction(_ sender:UIButton){
        let vc = VerifyInformationVC(viewModel: VerifyIdentityViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func skipBtnAction(_ sender:UIButton){
    }

}
