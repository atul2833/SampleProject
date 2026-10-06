//
//  SettingTblCell.swift
//  SatPay
//
//  Created by Niketan Sharma on 18/11/20.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit

class AccountTblCell: UITableViewCell {

    @IBOutlet weak var lbl : UILabel!
    @IBOutlet weak var img:UIImageView!
    @IBOutlet weak var lbl_des : UILabel!
    @IBOutlet weak var switchIs: UISwitch!
    @IBOutlet weak var imgArrow:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
