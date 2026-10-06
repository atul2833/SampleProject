//
//  PopupWithTVCell.swift
//  ComeraPay
//
//  Created by Muhammad Ahmed Baig on 26/01/2024.
//

import UIKit

class PopupWithTVCell: UITableViewCell {
    
    private let bottomView: UIView = {
        let btmView = UIView()
        btmView.translatesAutoresizingMaskIntoConstraints = false
        btmView.backgroundColor = UIColor.appBase
        return btmView
    }()
    
    private var titleLbl: CustomLabel!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setup(withModel model: PopUpListUIModel) {
        self.setupTitle(model: model)
        
        if model.hasBottomView {
            self.setupBottomView()
            self.bottomView.isHidden = false
        } else {
            self.bottomView.isHidden = true
        }
    }
    
    func setupTitle(model: PopUpListUIModel) {
        self.titleLbl = CustomLabel(model: model.title)
        self.contentView.addSubview(self.titleLbl)
        self.titleLbl.anchor(
            top: self.contentView.topAnchor,
            left: self.contentView.leadingAnchor,
            right: self.contentView.trailingAnchor,
            paddingTop: 5,
            paddingLeft: 20,
            paddingRight: 20
        )
        
        if !model.hasBottomView {
            self.titleLbl.anchor(
                bottom: self.contentView.bottomAnchor,
                paddingBottom: 5
            )
        }
    }
    
    func setupBottomView() {
        self.contentView.addSubview(self.bottomView)
        self.bottomView.anchor(
            top: self.titleLbl.bottomAnchor,
            left: self.titleLbl.leadingAnchor,
            bottom: self.contentView.bottomAnchor,
            right: self.titleLbl.trailingAnchor,
            paddingTop: 5,
            paddingLeft: 0,
            paddingBottom: 0,
            paddingRight: 0,
            height: 1.0
        )
    }

}
