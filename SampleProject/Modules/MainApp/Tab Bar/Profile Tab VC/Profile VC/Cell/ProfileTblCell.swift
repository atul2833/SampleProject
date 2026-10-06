//
//  SettingTblCell.swift
//  SatPay
//
//  Created by Niketan Sharma on 18/11/20.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit

class ProfileTblCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var lblDes : UILabel!
    @IBOutlet weak var switchIs: UISwitch!
    @IBOutlet weak var imgArrow:UIImageView!
    @IBOutlet weak var topTitle:NSLayoutConstraint!
    @IBOutlet weak var viewActivate:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        switchIs.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
