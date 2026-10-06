//
//  TotalValueTblCell.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 14/03/24.
//

import UIKit

class TotalValueTblCell: UITableViewCell {

    @IBOutlet weak var lblContributedMoney: UILabel!
    @IBOutlet weak var lblTotalBlockVal: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
