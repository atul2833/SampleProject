//
//  HomeCollecCell.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//
import UIKit

class HomeCollecCell: UICollectionViewCell {

    @IBOutlet weak var back_view:UIView!

    @IBOutlet weak var single_view:UIView!

    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var widthLabel:NSLayoutConstraint!
    @IBOutlet weak var lblImg:UILabel!

    @IBOutlet weak var lblGrowth:UILabel!
    @IBOutlet weak var imgGrowth:UIImageView!
    @IBOutlet weak var viewGrowth:UIView!

    @IBOutlet weak var viewMainBack: UIView!
    @IBOutlet weak var ViewBack: UIView!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var lblAmount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
            // Initialization code
            
          //  back_view.dropShadow(.appBase)
    }

}
