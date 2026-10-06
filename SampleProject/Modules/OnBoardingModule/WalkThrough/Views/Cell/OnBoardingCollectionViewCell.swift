//
//  OnBoardingCollectionViewCell.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 09/01/2024.
//

import UIKit

class OnBoardingCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "OnBoardingCollectionViewCell"
    
    struct Layout {
        static let imageViewYCenterConstant: CGFloat = -20
        static let imageViewWidthMultiplier: CGFloat = 0.8
        static let imageViewBottomConstant: CGFloat = 20
        static let titleAndDescriptionLabelLeftRightConstant: CGFloat = 16
        static let descriptionLabelTopConstantFromTitleLabel: CGFloat = 8
    }
    
    var imageView: UIImageView!
    var titleLabel: CustomLabel!
    var descriptionLabel: CustomLabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // Create and configure UIImageView
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        // Create and configure UILabel for title
        titleLabel = CustomLabel(
            model: CustomLabel.Model(
                title: nil,
                textColor: .appBase,
                font: AppFont.bold(.title),
                textAlignment: .center
            )
        )
        
        // Create and configure UILabel for description
        descriptionLabel = CustomLabel(
            model: CustomLabel.Model(
                title: nil,
                textColor: .appBase,
                font: AppFont.regular(.subTitle),
                numberOfLines: 0,
                textAlignment: .center
            )
        )
        
        // Add subviews to contentView
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        self.imageView.center(
            inView: self.contentView,
            yConstant: Layout.imageViewYCenterConstant
        )
        
        self.imageView.setSize(
            width: self.contentView.frame.width*0.8,
            height: self.contentView.frame.width*0.8
        )
       
        self.titleLabel.anchor(
            top: self.imageView.bottomAnchor,
            left: contentView.leadingAnchor,
            right: contentView.trailingAnchor,
            paddingTop: Layout.imageViewBottomConstant,
            paddingLeft: Layout.titleAndDescriptionLabelLeftRightConstant,
            paddingRight: Layout.titleAndDescriptionLabelLeftRightConstant
        )

        self.descriptionLabel.anchor(
            top: self.titleLabel.bottomAnchor,
            left: contentView.leadingAnchor,
            right: contentView.trailingAnchor,
            paddingTop: Layout.descriptionLabelTopConstantFromTitleLabel,
            paddingLeft: Layout.titleAndDescriptionLabelLeftRightConstant,
            paddingRight: Layout.titleAndDescriptionLabelLeftRightConstant
        )
    }
    
    func configureCell(item: WalkThroughModel) {
        imageView.sd_setImage(with: item.imageUrl)
        titleLabel.text = item.title
        descriptionLabel.text = item.description
    }
}
