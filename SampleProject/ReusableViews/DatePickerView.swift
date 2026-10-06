//
//  DatePickerView.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 12/02/2024.
//

import Foundation
import UIKit

final class DatePickerView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.layer.cornerRadius = 12
        return view
    }()

    private let selectorField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let trailingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var titleLabel: CustomLabel!
    
    struct SelectorFieldConfig {
        var placeHolder: String? = nil
        var text: String? = nil
        var isEnable: Bool? = true
        var font: UIFont? = AppFont.regular(.subTitle)
        var textColor: UIColor? = .appBase
        var inputView: UIView? = nil
        var textDelegate: UITextFieldDelegate? = nil
    }
    
    struct IconConfig {
        var icon: UIImage? = nil
        var iconSize: CGSize? = .init(width: 20, height: 20)
        var action: (() -> Void)?
    }
    
    struct Model {
        var selectorFieldConfig: SelectorFieldConfig?
        var iconConfig: IconConfig?
    }
    
    convenience init(model: Model) {
        self.init(frame: .zero)
        self.setupView(model: model)
    }
    
    func getTextField() -> UITextField {
        self.selectorField
    }
    
}

private extension DatePickerView {
    func setupView(model: Model) {
        self.addSubview(containerView)
        self.setupTextField(model: model)
        self.setupImageView(model: model)
        
    }
    
    func setupImageView(model: Model) {
        self.containerView.addSubview(trailingImageView)
        self.trailingImageView.image = model.iconConfig?.icon
        self.containerView.addConstraintsToFillView(self)
        
        self.trailingImageView.setSize(
            width: model.iconConfig?.iconSize?.width,
            height: model.iconConfig?.iconSize?.height
        )

        self.trailingImageView.centerY(
            inView: self.containerView,
            rightAnchor: self.containerView.trailingAnchor,
            paddingRight: -15
        )
        
        self.selectorField.anchor(
            top: self.containerView.topAnchor,
            left: self.containerView.leadingAnchor,
            bottom: self.containerView.bottomAnchor,
            right: self.trailingImageView.leadingAnchor,
            paddingTop: 5,
            paddingLeft: 5,
            paddingBottom: 5,
            paddingRight: 0,
            height: 55
        )
    }
    
    func setupTextField(model: Model){
        self.containerView.addSubview(selectorField)
        selectorField.placeholder = model.selectorFieldConfig?.placeHolder
        selectorField.text = model.selectorFieldConfig?.text
        selectorField.textColor = model.selectorFieldConfig?.textColor
        selectorField.font = model.selectorFieldConfig?.font
        selectorField.inputView = model.selectorFieldConfig?.inputView
        selectorField.delegate = model.selectorFieldConfig?.textDelegate
    }
}
