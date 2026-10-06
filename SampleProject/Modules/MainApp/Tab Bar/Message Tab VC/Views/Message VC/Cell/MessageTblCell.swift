//
//  MessageTblCell.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 06/02/24.
//

import UIKit

class MessageTblCell: UITableViewCell {
    
    @IBOutlet weak var lbl_date: UILabel!

    @IBOutlet weak var imageMessage: UIImageView!
    @IBOutlet weak var imageMessageView: UIView!
    @IBOutlet weak var lblIntrest: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lbl_detail: UILabel!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_image_title: UILabel!

    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var lblInterestRate: UILabel!

    @IBOutlet weak var viewMainBack: UIView!
    @IBOutlet weak var ViewBack: UIView!
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
