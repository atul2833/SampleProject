//
//  ProfileTVCell.swift
//  ComeraMoney
//
//  Created by NIKETAN SHARMA on 12/02/24.
//

import UIKit

class ProfileTVCell: UITableViewCell {

    private let itemImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .center
        return imgView
    }()
    
    private let rightImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private let rightSwitch: UISwitch = {
        let switchView = UISwitch()
        switchView.translatesAutoresizingMaskIntoConstraints = false
        return switchView
    }()
    
    private let bottomView: UIView = {
        let btmView = UIView()
        btmView.translatesAutoresizingMaskIntoConstraints = false
        btmView.backgroundColor = UIColor.appBase
        btmView.isHidden = true
        return btmView
    }()
    
    private let mainView: UIView = {
        let mainView = UIView()
        mainView.translatesAutoresizingMaskIntoConstraints = false
        return mainView
    }()
    
    var titleLbl: CustomLabel!
    var detailLbl: CustomLabel!
    var textStackView: UIStackView!
    
    var itemModel: ListItemUIModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setupViews() {
        self.setupLblsStackView()
        
        self.contentView.addSubview(self.mainView)
        self.mainView.addSubview(self.itemImgView)
        self.mainView.addSubview(self.rightImgView)
        self.mainView.addSubview(self.rightSwitch)
        self.mainView.addSubview(self.textStackView)
        self.contentView.addSubview(self.bottomView)
        
//        self.setupMainView()
        self.setupItemImgView()
        self.setupRightImgView()
        self.setupStackViewConstraints()
        self.setupBottomView()
        self.setupSwitchView()
    }
    
    func setupData(item: ListItemUIModel) {
        self.itemModel = item
        self.setupMainView(item: item.bgViewUIModel)
        
        self.titleLbl.text = item.titleStr
        self.titleLbl.textColor = item.titleColor
        
        self.detailLbl.text = item.descriptionStr
        self.detailLbl.textColor = item.descriptionColor
        
        self.detailLbl.isHidden = item.descriptionStr == nil
        
        self.itemImgView.image = item.cellImg
        
        self.rightSwitch.isHidden = !item.haveSwitch
        self.rightImgView.isHidden = item.rightArrowHidden
        self.rightImgView.image = item.rightArrow
        
        self.bottomView.isHidden = !item.needToShowSeparator
        
    }
    
    func setupMainView(item: ListBGViewUIModel) {
        self.mainView.anchor(
            top: self.contentView.topAnchor,
            left: self.contentView.leadingAnchor,
            bottom: self.contentView.bottomAnchor,
            right: self.contentView.trailingAnchor,
            paddingTop: item.topPadding,
            paddingLeft: item.leftPadding,
            paddingBottom: item.bottomPadding,
            paddingRight: item.rightPadding
        )
        
        self.mainView.backgroundColor = item.backgroundColor
        if item.cornerRadius != 0 {
            self.mainView.layer.cornerRadius = item.cornerRadius
        }
    }
    
    
    func setupItemImgView() {
        self.itemImgView.anchor(
            top: self.mainView.topAnchor,
            left: self.mainView.leadingAnchor,
            paddingTop: 10,
            paddingLeft: 12
        )
        
        self.itemImgView.setSize(width: 45, height: 45)
    }
    
    func setupRightImgView() {
        self.rightImgView.anchor(
            top: self.itemImgView.topAnchor,
            bottom: self.itemImgView.bottomAnchor,
            right: self.mainView.trailingAnchor,
            paddingTop: 0,
            paddingBottom: 0,
            paddingRight: 12
        )
        self.rightImgView.setSize(width: 8)
    }
    
    
    func setupSwitchView() {
        self.rightSwitch.anchor(
            left: self.textStackView.trailingAnchor,
            right: self.mainView.trailingAnchor,
            paddingLeft: 12,
            paddingRight: 12
        )
        
        self.rightSwitch.centerYAnchor.constraint(equalTo: self.mainView.centerYAnchor).isActive = true
    }
    
    func setupLblsStackView() {
        self.setupUserNameLbl()
        self.setupNumberLbl()
        
        self.textStackView = self.createStackView(
            arrangedSubviews: [
                titleLbl,
                detailLbl
            ],
            axis: .vertical,
            distribution: .fill,
            alignment: .leading,
            spacing: 0
        )
    }
    
    func setupStackViewConstraints() {
        self.textStackView.anchor(
            top: self.mainView.topAnchor,
            left: self.itemImgView.trailingAnchor,
            bottom: self.mainView.bottomAnchor,
            paddingTop: 10,
            paddingLeft: 12,
            paddingBottom: 20)
        
       // self.textStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        
    }
    
    func setupUserNameLbl() {
        self.titleLbl = CustomLabel(
            model: CustomLabel.Model(
                title: "",
                textColor: .appBase,
                font: AppFont.medium (
                    .description
                ),
                textAlignment: .left
            )
        )
    }
    
    func setupNumberLbl() {
        self.detailLbl = CustomLabel(
            model: CustomLabel.Model(
                title: "",
                textColor: .appBase,
                font: AppFont.regularFont (
                    regularFontWithSize: 10.0
                ),
                textAlignment: .left
            )
        )
        self.detailLbl.numberOfLines = 2
    }
    
    func setupBottomView() {
        self.bottomView.anchor(
            left: self.contentView.leadingAnchor,
            bottom: self.contentView.bottomAnchor,
            right: self.contentView.trailingAnchor,
            paddingLeft: 0,
            paddingBottom: 0,
            paddingRight: 0,
            height: 5
        )
    }

}
