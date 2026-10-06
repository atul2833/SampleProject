//
//  TitleHeaderTblCell.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 05/02/24.
//

import UIKit

class TitleHeaderTblCell: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var backView:UIView!
    @IBOutlet weak var backLabel:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
