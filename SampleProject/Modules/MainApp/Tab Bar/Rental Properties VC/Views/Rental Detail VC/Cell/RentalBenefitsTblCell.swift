//
//  RentalBenefitsTblCell.swift
//  TAGCreditMerchant
//
//  Created by somendra on 22/07/24.
//

import UIKit


protocol RentalBenefitsTblCellDelegate: AnyObject {
    func textFieldDidChange(_ text: String, in cell: RentalBenefitsTblCell)
}
class RentalBenefitsTblCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var txtField: UITextField!

    weak var delegate: RentalBenefitsTblCellDelegate?
    weak var delegateDelete: RentalBenefitsTblCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        txtField.delegate = self
        // Initialization code
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
            if let text = textField.text {
                delegate?.textFieldDidChange(text, in: self)
            }
        }
}
