//
//  VerifiedItemsTblCell.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 05/01/24.
//

import UIKit

class VerifiedItemsTblCell: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDescription:UILabel!
    @IBOutlet weak var btnInfo:ResponsiveButton!
    @IBOutlet weak var trailingDescription:NSLayoutConstraint!
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
