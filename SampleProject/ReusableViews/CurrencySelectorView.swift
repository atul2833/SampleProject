//
//  CurrencySelectorView.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 03/02/2024.
//

import Foundation
import UIKit

class CurrencySelectorView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let countryFlagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let currencyTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let selectorIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "chevron.down")
        return imageView
    }()
    
    var trailingSubTitleLabel: CustomLabel!
    
    struct FlagIconConfig {
        var icon: UIImage? = nil
        var iconSize: CGSize? = .init(width: 15, height: 15)
    }
    
    struct CurrencyTextConfig {
        var text: String? = "AED"
        var isEnable: Bool? = true
        var placeHolder: String? = nil
        var inputView: UIView? = nil
        var textDelegate: UITextFieldDelegate? = nil
        var font: UIFont? = AppFont.bold(.subTitle)
        var textColor: UIColor? = .black
        var alignment: NSTextAlignment? = .left
    }
    
    struct AmountTextConfig {
        var text: String? = "0"
        var isEnable: Bool? = true
        var placeHolder: String? = nil
        var font: UIFont? = AppFont.regular(.title)
        var textColor: UIColor? = .appBase
        var alignment: NSTextAlignment? = .right
    }
    
    struct Model {
        var flagConfig: FlagIconConfig? = nil
        var currencyTextConfig: CurrencyTextConfig? = nil
        var amountTextConfig: AmountTextConfig? = nil
        var selectorIconHide: Bool? = false
    }
    
    convenience init(model: Model) {
        self.init(frame: .zero)
        self.setupView(model: model)
    }
    
    func setCurrency(flagImage: UIImage, CountryName: String, currency: String) {
        self.countryFlagImageView.image = flagImage
        self.trailingSubTitleLabel.text = CountryName
        self.currencyTextField.text = currency
    }
    
    func getAmount() -> String? {
        self.amountTextField.text
    }
    
    func getCurrencyTextField() -> UITextField? {
        self.currencyTextField
    }
    
    func getAmountTextField() -> UITextField? {
        self.amountTextField
    }
    
    func setTextfield(text: String) {
        self.currencyTextField.text = text
    }
}

extension CurrencySelectorView {
    func setupView(model: Model) {
        self.addSubview(containerView)
        self.containerView.anchor(
            top: self.safeAreaLayoutGuide.topAnchor,
            left: self.leadingAnchor,
            bottom: self.safeAreaLayoutGuide.bottomAnchor,
            right: self.trailingAnchor,
            paddingTop: 0,
            paddingLeft: 10,
            paddingRight: 10,
            height: 50
        )
        
        self.countryFlagImageView.image = .iconCountryFlag
        self.countryFlagImageView.setSize(
            width: model.flagConfig?.iconSize?.width,
            height: model.flagConfig?.iconSize?.height
        )
        
        self.selectorIcon.setSize(
            width: 20,
            height: 20
        )
        
        self.currencyTextField.setSize(
            width: 100,
            height: 20
        )
        
        let stackView = self.createStackView(
            arrangedSubviews: [
                countryFlagImageView,
                currencyTextField,
                selectorIcon
            ],
            axis: .horizontal,
            distribution: .fillProportionally,
            alignment: .fill,
            spacing: 3
        )
        
        self.selectorIcon.isHidden = model.selectorIconHide ?? false
        
        self.containerView.addSubview(stackView)
        stackView.centerY(
            inView: self.containerView,
            leftAnchor: self.containerView.leadingAnchor,
            paddingLeft: 5
        )
        
        self.trailingSubTitleLabel = CustomLabel(
            model: CustomLabel.Model(
                title: "UAE",
                textColor: .darkGray,
                font: AppFont.regular(.description),
                numberOfLines: 1,
                textAlignment: .right
            )
        )
        
        amountTextField.text = model.amountTextConfig?.text
        amountTextField.placeholder = model.amountTextConfig?.placeHolder
        amountTextField.textAlignment = model.amountTextConfig?.alignment ?? .left
        amountTextField.textColor = model.amountTextConfig?.textColor

        currencyTextField.text = model.currencyTextConfig?.text
        currencyTextField.placeholder = model.currencyTextConfig?.placeHolder
        currencyTextField.textAlignment = model.currencyTextConfig?.alignment ?? .right
        currencyTextField.textColor = model.currencyTextConfig?.textColor
        
        currencyTextField.delegate = model.currencyTextConfig?.textDelegate
        currencyTextField.inputView = model.currencyTextConfig?.inputView
        
        let trailingStack = self.createStackView(
            arrangedSubviews: [
                amountTextField,
                trailingSubTitleLabel
            ],
            axis: .vertical,
            distribution: .fillProportionally,
            alignment: .fill,
            spacing: 5
        )
        self.containerView.addSubview(trailingStack)
        
        trailingStack.centerY(
            inView: self.containerView,
            rightAnchor: self.containerView.trailingAnchor,
            paddingRight: -5
        )
        trailingStack.anchor(left: stackView.trailingAnchor)
        self.containerView.addSubview(separatorView)
        self.separatorView.backgroundColor = .systemGray5
        self.separatorView.anchor(
            left: self.containerView.leadingAnchor,
            bottom: self.containerView.bottomAnchor,
            right: self.containerView.trailingAnchor,
            paddingLeft: 0,
            paddingBottom: 0,
            paddingRight: 0,
            height: 1
        )
        self.currencyTextField.isEnabled = model.currencyTextConfig?.isEnable ?? true
        self.amountTextField.isEnabled = model.amountTextConfig?.isEnable ?? true
    }
    
}
