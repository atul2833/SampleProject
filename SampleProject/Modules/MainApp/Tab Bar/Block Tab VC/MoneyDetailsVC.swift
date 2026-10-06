//
//  MoneyDetailsVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 05/02/24.
//

import UIKit

class MoneyDetailsVC: BaseNavigationController {
    
    @IBOutlet weak var refreshBtn: ResponsiveButton!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var topView:UIView!
    @IBOutlet weak var viewMyContribution:UIView!
    @IBOutlet weak var heightTblView:NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        //initVM()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //NotificationCenter.default.removeObserver(self, name: Notification.Name("BioSuccess"), object: nil)
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        
        topView.addGradientToViewTopToBottom(colors: [UIColor.subscriptionGredient1,UIColor.subscriptionGredient2])
        
        DispatchQueue.main.async{
            self.heightTblView.constant = self.tblView.contentSize.height + 50
        }
    }
    
    @IBAction func transactionPressed(_ sender:ResponsiveButton){
//        let vc = TransactionHistoryVC()
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func initView() {
        
        self.navigationItem.title = "The Tree Fellas."
        tblView.register(UINib(nibName: "TransactionHistoryTblCell", bundle: nil), forCellReuseIdentifier: "TransactionHistoryTblCell")
        tblView.register(UINib(nibName: "SeeMoreFooterTblCell", bundle: nil), forCellReuseIdentifier: "SeeMoreFooterTblCell")
        tblView.tableFooterView = UIView()
    }
    @objc func footerButtonTapped(sender: ResponsiveButton) {
//        let vc = TransactionHistoryVC()
//        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}


extension MoneyDetailsVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3//viewModel.transactionViewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryTblCell", for: indexPath) as! TransactionHistoryTblCell
        self.viewDidLayoutSubviews()
        
        
        
//        if indexPath.row % 2 == 0 {
//            cell.imgView.image = UIImage(named: "Group 43")
//            cell.title_lbl.text = "Wealth Seeds"
//        }else{
//            cell.imgView.image = UIImage(named: "Group 44")
//            cell.title_lbl.text = "Fortune Funds"
//        }

        return cell
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        44
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreFooterTblCell") as! SeeMoreFooterTblCell
                cell.btnSeeMore.addTarget(self, action: #selector(footerButtonTapped), for: .touchUpInside)
                return cell.contentView
         
            
        
    }
}
