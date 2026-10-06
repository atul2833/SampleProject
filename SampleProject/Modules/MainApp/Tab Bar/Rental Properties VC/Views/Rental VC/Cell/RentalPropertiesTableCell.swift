//
//  RentalPropertiesTableCell.swift
//  TAGCreditMerchant
//
//  Created by somendra on 18/07/24.
//

import UIKit

class RentalPropertiesTableCell: UITableViewCell {

    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDescription:UILabel!
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var lblDuration:UILabel!

    @IBOutlet weak var imgView:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
