//
//  MemberBlockTblCell.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 05/02/24.
//

import UIKit

class MemberBlockTblCell: UITableViewCell {

   
    @IBOutlet weak var viewColorChange: UIView!
    @IBOutlet weak var btnForVote: ResponsiveButton!
    @IBOutlet weak var lblVoteCount: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
