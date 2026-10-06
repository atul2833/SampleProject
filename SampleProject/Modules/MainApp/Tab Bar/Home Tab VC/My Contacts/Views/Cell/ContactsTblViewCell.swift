//
//  ContactsTblViewCell.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.

import UIKit

class ContactsTblViewCell: UITableViewCell {

    @IBOutlet weak var backView:UIView!
    @IBOutlet weak var title_lbl:UILabel!
    @IBOutlet weak var desc_lbl:UILabel!

    @IBOutlet weak var data_lbl:UILabel!
    @IBOutlet weak var imgLabel:UILabel!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var inviteBtn:UIButton!

    @IBOutlet weak var inviteView: UIView!
    @IBOutlet weak var checkBoxBtn: UIButton!
    
    @IBOutlet weak var checkBoxImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
