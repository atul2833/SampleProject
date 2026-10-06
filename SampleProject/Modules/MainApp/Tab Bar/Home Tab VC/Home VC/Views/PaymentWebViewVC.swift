//
//  PaymentWebViewVC.swift
//  TAGCredit
//
//  Created by Atul Upadhyay on 08/09/26.
//

import UIKit
import WebKit


protocol PaymentWebViewDelegate: AnyObject {
    func paymentFinished(
        transactionId: String,
        gateway: String
    )
}

class PaymentWebViewVC: UIViewController {
    
    
    @IBOutlet weak var webView: WKWebView!
    
    weak var delegate: PaymentWebViewDelegate?
    
    private let redirectURL: String
    private let transactionId: String
    private let gateway: String
    private let walletViewModel: WalletViewModel
    
    private var statusTimer: Timer?
    private var isFinished = false
    
    init(
        redirectURL: String,
        transactionId: String,
        gateway: String, walletViewModel:WalletViewModel
    ) {
        self.redirectURL = redirectURL
        self.transactionId = transactionId
        self.gateway = gateway
        self.walletViewModel = walletViewModel
        
        super.init(
            nibName: "PaymentWebViewVC",
            bundle: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = gateway.capitalized
        
        webView.navigationDelegate = self
        
        guard let url = URL(string: redirectURL) else {
            print("❌ Invalid payment URL")
            return
        }
        
        webView.load(URLRequest(url: url))
        
        walletStateObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           startStatusPolling()
       }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
        delegate?.paymentFinished(
            transactionId: transactionId,
            gateway: gateway
        )
            stopStatusPolling()
        }
    
    deinit {
            stopStatusPolling()
        }
    
    private func startStatusPolling() {
            guard statusTimer == nil else { return }

            // fire immediately once, then every 3 seconds
            checkPaymentStatus()

            statusTimer = Timer.scheduledTimer(
                withTimeInterval: 3.0,
                repeats: true
            ) { [weak self] _ in
                self?.checkPaymentStatus()
            }
        
        
        }

        private func stopStatusPolling() {
            statusTimer?.invalidate()
            statusTimer = nil
        }
    
    private func checkPaymentStatus() {
        guard !isFinished else { return }
        walletViewModel.checkPaymentStatusApi(transactionId: transactionId)
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
                    self?.stopStatusPolling()
                    self?.closeWebViewOnSuccess()
                
                case .error(let message):
                    Log.error(message)
                    //self?.view.makeToast(message, position: .bottom)
                case .logout:
                    let tabBar = self?.tabBarController as? HomeTabBarController
                    tabBar?.logout()
                default:
                    break
                }
            }
            .store(in: &self.walletViewModel.cancellable)
    }
    
    private func closeWebViewOnSuccess() {
           print("💰 Payment completed via status API")
           print("Gateway:", gateway)
           print("Transaction ID:", transactionId)
          
           dismissWebView()
       }
    
    private func showFailureAlert(message: String) {
           let alert = UIAlertController(
               title: "Payment Failed",
               message: message,
               preferredStyle: .alert
           )

           alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
               self?.dismissWebView()
           })

           present(alert, animated: true)
       }

       private func dismissWebView() {
           if let nav = navigationController {
               nav.popViewController(animated: true)
           } else {
               dismiss(animated: true)
           }
       }

    
    
}





extension PaymentWebViewVC: WKNavigationDelegate {

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        print("🌐 Payment URL:", url.absoluteString)

        let urlString = url.absoluteString

        // Backend callback (kept as a fallback path alongside polling)
        if urlString.contains("/payment/callback"), !isFinished {
            decisionHandler(.cancel)

            print("💰 Payment callback received")
            print("Gateway:", gateway)
            print("Transaction ID:", transactionId)

            isFinished = true
            stopStatusPolling()

            delegate?.paymentFinished(
                transactionId: transactionId,
                gateway: gateway
            )

            return
        }

        decisionHandler(.allow)
    }
}
