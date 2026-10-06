 //
//  ChatImageSendTblCell.swift
//  TAGCreditMerchant
//
//  Created by NIKETAN SHARMA on 09/05/24.
//

import UIKit

class ChatImageSendTblCell: UITableViewCell {

    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var backView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backView.makeCorners(corners: [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: 15)
    }
    
    override func prepareForReuse() {
           super.prepareForReuse()
           imgView.sd_cancelCurrentImageLoad()
           imgView.image = nil
       }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
