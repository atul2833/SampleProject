//
//  BlockTblViewCell.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 02/02/24.
//

import UIKit

class BlockTblViewCell: UITableViewCell {

    @IBOutlet weak var backView:UIView!
    
    @IBOutlet weak var designationView: UIView!
    @IBOutlet weak var lblDesignation: UILabel!
    @IBOutlet weak var lblMembersCount: UILabel!
    @IBOutlet var imgMembers: [UIImageView]!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLbl: UILabel!
    
    @IBOutlet weak var viewMembersCount: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
