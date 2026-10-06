//
//  RentalSpecificationTblCell.swift
//  TAGCreditMerchant
//
//  Created by somendra on 19/07/24.
//

import UIKit

protocol RentalSpecificationTblCellDelegate: AnyObject {
    func textFieldDidChange(_ text: String, in cell: RentalSpecificationTblCell)
}

class RentalSpecificationTblCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var btnCancel: ResponsiveButton!
    @IBOutlet weak var txtField: UITextField!
    
    weak var delegate: RentalSpecificationTblCellDelegate?
    weak var delegateDelete: RentalSpecificationTblCellDelegate?
    
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
