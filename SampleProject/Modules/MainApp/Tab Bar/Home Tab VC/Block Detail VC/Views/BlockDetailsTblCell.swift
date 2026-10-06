//
//  BlockDetailsTblCell.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 14/03/24.
//

import UIKit

class BlockDetailsTblCell: UITableViewCell {

    @IBOutlet weak var lblMembersCount: UILabel!
    @IBOutlet var imgMembers: [UIImageView]!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var bottomFromPayment: NSLayoutConstraint!
    @IBOutlet weak var lblMode: UILabel!
    @IBOutlet weak var viewMode: UIView!

    @IBOutlet weak var viewMembersCount: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDateTitle: UILabel!
    @IBOutlet weak var lblCreatedDate: UILabel!
    @IBOutlet weak var lblPaymentDue: UILabel!
    @IBOutlet weak var lblUnit: UILabel!

    @IBOutlet weak var viewPayment: UIView!
    @IBOutlet weak var viewUnit: UIView!

    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var lblDepositRules: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
