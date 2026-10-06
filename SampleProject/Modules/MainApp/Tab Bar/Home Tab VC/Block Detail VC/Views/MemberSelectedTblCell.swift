//
//  MemberSelectedTblCell.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 05/02/24.
//

import UIKit

class MemberSelectedTblCell: UITableViewCell {

    @IBOutlet weak var lblVoteCount: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var typeLbl: UILabel!
    
    @IBOutlet weak var lblDescrition: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
