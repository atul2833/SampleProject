//
//  TransactionHistoryTblCell.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit

class TransactionHistoryTblCell: UITableViewCell {

    @IBOutlet weak var backView:UIView!
    @IBOutlet weak var lblTitle:UILabel!
   // @IBOutlet weak var desc_lbl:UILabel!

    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var imgView:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backView.dropShadow(UIColor.lightGray)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
