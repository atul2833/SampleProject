//
//  CustomButtonWithImageView.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 13/01/2024.
//

import UIKit

class CustomButtonWithImageView: UIView {
    
    
    private var model: Model?
    private var buttonActionHandler: ((_ isSelected: Bool) -> Void)?
    
    enum IconPosition: String {
        case top, left, right, bottom
    }
    
    struct TextConfig {
        var title: String? = nil
        var textColor: UIColor? = .appBase
        var font: UIFont? = AppFont.semi(.description)
    }
    
    struct IconConfig {
        var icon: UIImage? = nil
        var selectedIcon: UIImage? = nil
        var iconTintColor: UIColor? = nil
        var iconSize: CGSize? = .init(width: 20, height: 20)
    }
    
    struct LayoutConfig {
        var iconPosition: IconPosition = .left
        var spacing: CGFloat = 0
        var yConstant: CGFloat = 0
    }
    
    struct ActionConfig {
        var action: ((_ isSelected: Bool) -> Void)? = nil
    }
    
    struct Model {
        var textConfig: TextConfig?
        var iconConfig: IconConfig?
        var layoutConfig: LayoutConfig?
        var actionConfig: ActionConfig?
        
        init(
            textConfig: TextConfig? = nil,
            iconConfig: IconConfig? = nil,
            layoutConfig: LayoutConfig? = nil,
            actionConfig: ActionConfig? = nil
        ) {
            self.textConfig = textConfig
            self.iconConfig = iconConfig
            self.layoutConfig = layoutConfig
            self.actionConfig = actionConfig
        }
    }
    
    convenience init(model: Model) {
        self.init(frame: .zero)
        self.setupView(model: model)
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let iconView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private func setupView(model: Model) {
        self.model = model
        self.buttonActionHandler = model.actionConfig?.action
        self.setupButton(model: model)
        self.setupTitleLabel(model: model)
        self.setupButtonIcon(model: model)
        switch model.layoutConfig?.iconPosition {
        case .top:
            let stackView = self.createStackView(
                arrangedSubviews: [
                    iconView,
                    titleLabel
                ],
                axis: .vertical,
                distribution: .fillProportionally,
                alignment: .center,
                spacing: model.layoutConfig?.spacing ?? .zero
            )
            self.addSubview(stackView)
            stackView.centerX(inView: self)
            stackView.center(
                inView: self,
                yConstant: model.layoutConfig?.yConstant ?? .zero
            )
        case .left:
            let stackView = self.createStackView(
                arrangedSubviews: [
                    iconView,
                    titleLabel
                ],
                axis: .horizontal,
                spacing: model.layoutConfig?.spacing ?? .zero
            )
            self.addSubview(stackView)
            stackView.center(inView: self)
        case .right:
            let stackView = self.createStackView(
                arrangedSubviews: [
                    titleLabel,
                    iconView
                ],
                axis: .horizontal,
                spacing: model.layoutConfig?.spacing ?? .zero
            )
            self.addSubview(stackView)
            stackView.center(inView: self)
        case .bottom:
            let stackView = self.createStackView(
                arrangedSubviews: [
                    titleLabel,
                    iconView
                ],
                axis: .vertical,
                alignment: .center ,
                spacing: model.layoutConfig?.spacing ?? .zero
            )
            self.addSubview(stackView)
            stackView.center(
                inView: self,
                yConstant: model.layoutConfig?.yConstant ?? .zero
            )
        case .none:
            break
        }
        
        titleLabel.setSize(height: 25)
        
        if model.actionConfig?.action != nil {
            self.addSubview(button)
            self.button.addConstraintsToFillView(self)
        }
    }
    
    private func setupTitleLabel(model: Model) {
        self.titleLabel.text = model.textConfig?.title
        self.titleLabel.textColor = model.textConfig?.textColor
        self.titleLabel.font = model.textConfig?.font
    }
    
    private func setupButtonIcon(model: Model) {
        self.iconView.tintColor = model.iconConfig?.iconTintColor
        if let tint = model.iconConfig?.iconTintColor {
            self.iconView.image = model.iconConfig?.icon?.withTintColor(tint, renderingMode: .alwaysTemplate)
        } else {
            self.iconView.image = model.iconConfig?.icon
        }
        self.iconView.setSize(width: model.iconConfig?.iconSize?.width, height: model.iconConfig?.iconSize?.height)
    }
    
    private func setupButton(model: Model) {
        self.button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    @objc func buttonTapped(_ isSelected: Bool) {
        guard let model else { return }
        self.button.isSelected = true
        model.actionConfig?.action?(self.button.isSelected)
    }
    
    func handleSelectionView(isSelected: Bool) {
        guard let model else { return }
        self.iconView.image = isSelected ? model.iconConfig?.selectedIcon : model.iconConfig?.icon
    }
}


extension CustomButtonWithImageView {
    func updateModel(model: Model) {
        // Update the model properties
        self.model = model
        self.setupView(model: model)
    }
}

