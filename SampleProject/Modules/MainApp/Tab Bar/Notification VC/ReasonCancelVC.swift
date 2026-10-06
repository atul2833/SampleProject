//
//  ReasonCancelVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 06/02/24.
//

import UIKit
import DropDown


class ReasonCancelVC:BaseNavigationController {
    
    @IBOutlet weak var txtReason:UITextField!
    
    var notificationVC:NotificationVC?
    var messageDetailVC: MessageDetailVC?
    var reasonList:[HelpCenterModel]?
    var rejectId = String()
    var requestId = String()
    var usedFor = String()

    override func viewDidLoad() {
        super.viewDidLoad()

        txtReason.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueAction(_ sender:UIButton) {
        
        self.view.endEditing(true)
        
        if sender.tag == 0{
            self.dismiss(animated: false)
        }
        else{
            notificationVC?.confirm(reasonId: rejectId, requestId: requestId, usedFor: usedFor)
            messageDetailVC?.confirm(reasonId: rejectId, requestId: requestId, usedFor: usedFor)
            self.dismiss(animated: false)
        }
    }
}

extension ReasonCancelVC:UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let dropDown = DropDown()

        dropDown.anchorView = textField // UIView or UIBarButtonItem
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)

        dropDown.dataSource = reasonList?.map{$0.title} as! [String]

        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            textField.text = item
            self.rejectId = "\(self.reasonList?[index].id ?? "")"
        }
        dropDown.show()
        return false
    }
}
