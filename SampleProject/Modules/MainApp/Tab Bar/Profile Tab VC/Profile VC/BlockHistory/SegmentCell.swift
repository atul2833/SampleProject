//
//  SegmentCell.swift
//  TAGCredit
//
//  Created by Atul Upadhyay on 10/09/26.
//

import UIKit

class SegmentCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setSelected(_ selected: Bool) {

            if selected {
                backView.borderColor = .clear
                backView.backgroundColor = UIColor.appBase
                titleLbl.textColor = .white

            } else {
                backView.borderColor = .DEDEDE
                backView.backgroundColor = UIColor.F_5_F_5_F_5
                titleLbl.textColor = ._989898
            }
        }

}
