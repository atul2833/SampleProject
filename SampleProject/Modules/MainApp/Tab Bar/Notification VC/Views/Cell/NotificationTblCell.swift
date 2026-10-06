//
//  NotificationTblCell.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit

class NotificationTblCell: UITableViewCell {

    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var lbl_image_title: UILabel!

    @IBOutlet weak var lbl_detail: UILabel!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_img: UILabel!
    @IBOutlet weak var imgView: UIImageView!

    @IBOutlet weak var btnCancel: ResponsiveButton!
    @IBOutlet weak var btnAccept: ResponsiveButton!
    @IBOutlet weak var btnJoinBlock: ResponsiveButton!

    @IBOutlet weak var viewMainBack: UIView!
    @IBOutlet weak var ViewBack: UIView!
    @IBOutlet weak var topDate: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
