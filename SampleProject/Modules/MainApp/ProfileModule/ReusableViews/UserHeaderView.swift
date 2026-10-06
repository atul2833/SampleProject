//
//  UserHeaderView.swift
//  ComeraPay
//
//  Created by Muhammad Ahmed Baig on 23/01/2024.
//

import UIKit

class UserHeaderView: UIView {
    private let mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imgView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
    
    private let rightArrowImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
    
    var userNameLbl: CustomLabel!
    var numberLbl: CustomLabel!
    var textStackView: UIStackView!
    var model: ProfileStickyHeaderUIModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        self.backgroundColor = .white
        self.setupViews()
    }
    
    func setupData(model: ProfileStickyHeaderUIModel) {
        self.model = model
        self.mainView.backgroundColor = model.backgroundColor
        self.imgView.image = model.userImg
        self.numberLbl.text = model.mobileNumber
        self.userNameLbl.textColor = model.userNameColor
        self.userNameLbl.text = model.userName
        self.numberLbl.textColor = model.mobileNumberColor
        self.rightArrowImgView.image = model.indicatorImg
    }
    
    func addTapAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleMainViewTapped))
        self.mainView.addGestureRecognizer(tap)
    }
    
    @objc func handleMainViewTapped() {
        self.model?.tapAction?()
    }
    
    private func setupViews() {
        self.addSubview(mainView)
        self.setupLblsStackView()
        self.mainView.addSubview(textStackView)
        self.mainView.addSubview(imgView)
        self.mainView.addSubview(rightArrowImgView)
        
        self.setupMainView()
        self.setupUserImgView()
        self.setupRightArrowView()
        self.setupStackViewConstraints()
        
        self.addTapAction()
    }
    
    func setupMainView() {
        self.mainView.anchor(
            top: self.topAnchor,
            left: self.leadingAnchor,
            bottom: self.bottomAnchor,
            right: self.trailingAnchor,
            paddingTop: 10,
            paddingLeft: 10,
            paddingBottom: 10,
            paddingRight: 10
        )
        
        self.mainView.backgroundColor = UIColor.E_3_F_8_FF
        self.mainView.layer.cornerRadius = 12.0
    }
    
    func setupUserImgView() {
        self.imgView.anchor(
            top: self.mainView.topAnchor,
            left: self.mainView.leadingAnchor,
            bottom: self.mainView.bottomAnchor,
            paddingTop: 10,
            paddingLeft: 10,
            paddingBottom: 10
        )
        
        self.imgView.proportionalSize(width: self.imgView.heightAnchor)
    }
    
    func setupLblsStackView() {
        self.setupUserNameLbl()
        self.setupNumberLbl()
        
        self.textStackView = self.createStackView(
            arrangedSubviews: [
                userNameLbl,
                numberLbl
            ],
            axis: .vertical,
            distribution: .fillProportionally,
            alignment: .fill,
            spacing: 2
        )
    }
    
    func setupStackViewConstraints() {
        self.textStackView.anchor(
            left: self.imgView.trailingAnchor,
            paddingLeft: 12
        )
        self.textStackView.proportionalSize(height: self.mainView.heightAnchor,
                                            heightPercent: 0.6)
        self.textStackView.centerYAnchor.constraint(equalTo: self.mainView.centerYAnchor).isActive = true
    }
    
    func setupUserNameLbl() {
        self.userNameLbl = CustomLabel(
            model: CustomLabel.Model(
                title: "Richard",
                textColor: UIColor.secondary,
                font: AppFont.bold(
                    .walletBalanceTextSize
                ),
                textAlignment: .left
            )
        )
    }
    
    func setupNumberLbl() {
        self.numberLbl = CustomLabel(
            model: CustomLabel.Model(
                title: "+971501234567",
                textColor: UIColor.primary,
                font: AppFont.regular(
                    .description
                ),
                textAlignment: .left
            )
        )
    }
    
    func setupRightArrowView() {
        self.rightArrowImgView.anchor(
            left: self.textStackView.trailingAnchor,
            bottom: self.mainView.bottomAnchor,
            right: self.mainView.trailingAnchor,
            paddingLeft: 12,
            paddingBottom: 12,
            paddingRight: 12,
            width: 18.0,
            height: 18.0
        )
    }
}
