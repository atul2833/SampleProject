//
//  CreditTblCell.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 05/02/24.
//

import UIKit

class CreditTblCell: UITableViewCell {

    @IBOutlet weak var viewLeft:UIView!
    @IBOutlet weak var viewRight:UIView!
    
    @IBOutlet weak var typeFullLbl: UILabel!
    
    @IBOutlet weak var viewMainBack: UIView!
    @IBOutlet weak var ViewBack: UIView!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var lblBlockVal: UILabel!
    @IBOutlet weak var lblHeaderBlockVal: UILabel!

    @IBOutlet weak var lblCreditedAmount: UILabel!
    @IBOutlet weak var lblContributedAmount: UILabel!
    @IBOutlet weak var lblTotalCreditedMoney: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewLeft.roundSpecificCorners(corners: [.bottomLeft], radius: 14)
        viewRight.roundSpecificCorners(corners: [.bottomRight], radius: 14)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
