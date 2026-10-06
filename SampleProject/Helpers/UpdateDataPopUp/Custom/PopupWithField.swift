//
//  PopupWithField.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit

protocol CustomViewUIModelProtocol {}

struct PopUpWithFieldUIModel: CustomViewUIModelProtocol {
    var title: CustomLabel.Model?
    var descriptionStr: CustomLabel.Model?
    var textField: CustomTextFieldView.Model?
    var customVerifyAction: ((_ fieldText: String)->Void)?
}

protocol CustomPopupViewProtocol: UIView {}

class PopupWithField: UIView, CustomPopupViewProtocol {
    
    private var titleLbl: CustomLabel!
    private var detailLbl: CustomLabel!
    private var fieldView: CustomTextFieldView!
    
    private var leadingPadding: CGFloat = 20.0
    private var trailingPadding: CGFloat = 20.0
    
    private var uiModel: PopUpWithFieldUIModel
    
    init(uiModel: PopUpWithFieldUIModel) {
        self.uiModel = uiModel
        super.init(frame: .zero)
        
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.backgroundColor = .white
        
        self.setupTitleLbl()
        self.setupDetailLbl()
        self.setupFieldView()
        self.setupBottomConstraint()
    }
    
    func getHeight() -> CGFloat {
        self.fieldView.bounds.height
    }
    
    func setupTitleLbl() {
        if let title = self.uiModel.title {
            self.titleLbl = CustomLabel(
                model: title
            )
            
            self.addSubview(self.titleLbl)
            self.setupTitleLblConstraints()
        }
    }
    
    func setupDetailLbl() {
        if let decsription = self.uiModel.descriptionStr {
            self.detailLbl = CustomLabel(
                model: decsription
            )
            
            self.addSubview(self.detailLbl)
            self.setupDetailLblConstraints()
        }
    }
    
    func setupFieldView() {
        if let fieldModel = self.uiModel.textField {
            fieldView = CustomTextFieldView(
                model: fieldModel
            )
            
            self.addSubview(self.fieldView)
            self.setupFeildViewConstraints()
        }
    }
    
    func setupTitleLblConstraints() {
        self.titleLbl.anchor(
            top: self.topAnchor,
            left: self.leadingAnchor,
            right: self.trailingAnchor,
            paddingTop: 5,
            paddingLeft: self.leadingPadding,
            paddingRight: self.trailingPadding,
            height: 25
        )
    }
    
    func setupDetailLblConstraints() {
        var bottomAnchor: NSLayoutYAxisAnchor = self.topAnchor
        if self.uiModel.title != nil {
            bottomAnchor = self.titleLbl.bottomAnchor
        }
        self.detailLbl.anchor(
            top: bottomAnchor,
            left: self.leadingAnchor,
            right: self.trailingAnchor,
            paddingTop: 10,
            paddingLeft: self.leadingPadding,
            paddingRight: self.trailingPadding
        )
    }
    
    func setupFeildViewConstraints() {
        var bottomAnchor: NSLayoutYAxisAnchor = self.topAnchor
        if self.uiModel.descriptionStr != nil{
            bottomAnchor = self.detailLbl.bottomAnchor
        } else if self.uiModel.title != nil {
            bottomAnchor = self.titleLbl.bottomAnchor
        }
        self.fieldView.anchor(
            top: bottomAnchor,
            left: self.leadingAnchor,
            right: self.trailingAnchor,
            paddingTop: 20,
            paddingLeft: self.leadingPadding,
            paddingRight: self.trailingPadding
        )
    }
    
    func setupBottomConstraint() {
        if self.uiModel.textField != nil {
            self.fieldView.anchor(
                bottom: self.bottomAnchor
            )
        }else if self.uiModel.descriptionStr != nil {
            self.detailLbl.anchor(
                bottom: self.bottomAnchor
            )
        } else {
            self.titleLbl.anchor(
                bottom: self.bottomAnchor
            )
        }
    }
    
    func getFieldText() -> String? {
        return self.fieldView.getText()
    }
}
