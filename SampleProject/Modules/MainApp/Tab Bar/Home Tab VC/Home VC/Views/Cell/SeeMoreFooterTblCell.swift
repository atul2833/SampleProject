//
//  SeeMoreFooterTblCell.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 02/02/24.
//

import UIKit

class SeeMoreFooterTblCell: UITableViewCell {

    @IBOutlet weak var btnSeeMore:ResponsiveButton!
    @IBOutlet weak var lblSeeMore:UILabel!
    @IBOutlet weak var backView:UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
