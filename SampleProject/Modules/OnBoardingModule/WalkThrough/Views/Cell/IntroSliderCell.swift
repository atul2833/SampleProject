//
//  IntroSliderCell.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit

class IntroSliderCell: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(item: WalkThroughModel?) {
        imgView.image = UIImage(named: item?.image ?? "")
        titleLbl.text = item?.title
        descriptionLbl.text = item?.description
    }
}
