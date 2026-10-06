//
//  CustomAlertListVC.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 25/06/24.
//

import UIKit
import WebKit

class CustomAlertListVC: BaseNavigationController {
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDescription:UILabel!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var webKitView: WKWebView!

    @IBOutlet weak var cancelBtn: ResponsiveButton!
    @IBOutlet weak var yesBtn: ResponsiveButton!
    var alertConfirm : AlertConfimDelegate!
    
    var comingTitle = String()
    var comingDescription = String()
    var comingImage = String()
    var yesBtnTitle = String()
    
    private var viewModel: CustomAlertListViewModel

    init(viewModel: CustomAlertListViewModel) {
        self.viewModel = viewModel
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
        initView()
        stateObserver()
        viewModel.getCustomAlertListData(type: viewModel.type ?? "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = viewModel.type == "leaveBlock" ? "Leaved Block" : viewModel.type == "deleteAccount" ? "Delete Block" : viewModel.type == "joinBlock" ? "Join Block" : viewModel.type == "swapBlock" ? "Swap Request" : ""

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
   
    private func stateObserver() {
        self.viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .success:
                    self?.showWebView()
            
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
    
    func showWebView(){
            
        let webConfiguration = WKWebViewConfiguration()
            webConfiguration.preferences.javaScriptEnabled = true
        
        self.webKitView.navigationDelegate = self

        //let request = URLRequest(url: url)
        
        let htmlString = """
        <!doctype html>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <html>
            <head>
                <style>
                    body {
                        font-size: 16px;
                        font-family: "Montserrat-Regular"
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="element">
                        <span class="custom">\(viewModel.getListData()?.content ?? "")</span>
                    </div>
                </div>
            </body>
        </html>
        """

        
        self.webKitView.loadHTMLString(htmlString, baseURL: nil)

        //self.webKitView.load(request)
        self.webKitView.allowsBackForwardNavigationGestures = true
        
    }
    
    func initView(){
        
        if yesBtnTitle.count != 0{
            yesBtn.setTitle(yesBtnTitle, for: .normal)
        }
        else{
            yesBtn.setTitle("Yes", for: .normal)
        }
       
        imgView.image = UIImage(named: comingImage)
    }
    
    @IBAction func acceptBtnAction(_ sender: ResponsiveButton) {
        viewModel.isTermsSelected = !viewModel.isTermsSelected
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func continueAction(_ sender:UIButton) {
        
        self.view.endEditing(true)
        
        if sender.tag == 0{
            self.navigationController?.popViewController(animated: true)
        }
        else{
            if viewModel.isTermsSelected{
                self.navigationController?.popViewController(animated: true)
                alertConfirm.alertAction(comingTitle)
            }
            else{
                self.view.makeToast("Please accept terms ad conditions")
            }
            
        }
    }
}

extension CustomAlertListVC:WKNavigationDelegate{
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {     
        debugPrint("didCommit")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        debugPrint("didFail")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Inject CSS to set the background color of the HTML content
    
        ProgressHudWrapper.dismiss()
    }
}
