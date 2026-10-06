//
//  TransactionDetailShowTblCell.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 11/01/24.
//

import UIKit

class TransactionDetailDataTblCell: UITableViewCell {

    @IBOutlet weak var seperationLine: UIView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDescription:UILabel!
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
