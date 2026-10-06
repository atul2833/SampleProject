//
//  MoneyCreditTblCell.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 05/02/24.
//

import UIKit

class MoneyCreditTblCell: UITableViewCell {

   
    @IBOutlet weak var lblTotalMoney: UILabel!
    @IBOutlet weak var lblBlockVal: UILabel!
    @IBOutlet weak var typeImg: UIImageView!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var typeNameLbl: UILabel!
    @IBOutlet weak var viewMainBack: UIView!
    @IBOutlet weak var ViewBack: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

