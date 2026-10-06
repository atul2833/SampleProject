//
//  MemberCollViewCell.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 02/02/24.
//

import UIKit

class MemberCollViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    
    
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblStatus:UILabel!
    @IBOutlet weak var centerTitle:NSLayoutConstraint!
    @IBOutlet weak var viewNotification:UIView!
    @IBOutlet weak var countView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
