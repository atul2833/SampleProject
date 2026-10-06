//
//  MessageInnerTblCell.swift
//  TAGCreditMerchant
//
//  Created by NIKETAN SHARMA on 25/04/24.
//

import UIKit

class MyMessageInnerTblCell: UITableViewCell {

    @IBOutlet weak var lblIntrestChange: UILabel!
    @IBOutlet weak var lblCreditChange: UILabel!
    @IBOutlet weak var lbl_date: UILabel!

    @IBOutlet weak var lbl_detail: UILabel!
    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var lblInterestRate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!

    @IBOutlet weak var bottomDescription: NSLayoutConstraint!
    @IBOutlet weak var viewBottom: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
