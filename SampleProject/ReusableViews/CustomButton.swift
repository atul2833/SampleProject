//
//  CustomButton.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 09/01/2024.
//

import UIKit


class CustomButton: UIButton {
    
    private var buttonActionHandler: ((_ isSelected: Bool) -> Void)?
    
    struct TitleConfig {
        var title: String? = nil
        var selectedTitle: String? = nil
    }
    
    struct ImageConfig {
        var image: UIImage? = nil
        var selectedImage: UIImage? = nil
    }
    
    struct StyleConfig {
        var textColor: UIColor = .black
        var tintColor: UIColor? = .appBase
        var backgroundColor: UIColor = .clear
        var font: UIFont = AppFont.regular(.subTitle)
        var cornerRadius: CGFloat = 0
        var borderWidth: CGFloat = 0
        var borderColor: UIColor? = .clear
    }
    
    struct ActionConfig {
        var action: ((_ isSelected: Bool) -> Void)? = nil
    }
    
    struct Model {
        var titleConfig: TitleConfig?
        var imageConfig: ImageConfig?
        var styleConfig: StyleConfig?
        var actionConfig: ActionConfig?
        
        init(
            titleConfig: TitleConfig? = nil,
            imageConfig: ImageConfig? = nil,
            styleConfig: StyleConfig? = nil,
            actionConfig: ActionConfig? = nil
        ) {
            self.titleConfig = titleConfig
            self.imageConfig = imageConfig
            self.styleConfig = styleConfig
            self.actionConfig = actionConfig
        }
    }
    
    convenience init(model: Model) {
        self.init()
        setTitle(model.titleConfig?.title, for: .normal)
        setTitle(model.titleConfig?.selectedTitle, for: .selected)
        setImage(model.imageConfig?.image, for: .normal)
        setImage(model.imageConfig?.selectedImage, for: .selected)
        self.tintColor = model.styleConfig?.tintColor
        setTitleColor(model.styleConfig?.textColor, for: .normal)
        backgroundColor = model.styleConfig?.backgroundColor
        titleLabel?.font = model.styleConfig?.font
        layer.cornerRadius = model.styleConfig?.cornerRadius ?? .zero
        self.buttonActionHandler = model.actionConfig?.action
        self.layer.borderWidth = model.styleConfig?.borderWidth ?? .zero
        self.layer.borderColor = model.styleConfig?.borderColor?.cgColor
        self.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    @objc private func buttonAction(_ isSelected: Bool) {
        self.isSelected.toggle()
        buttonActionHandler?(self.isSelected)
    }
    
    func updateButtonState(enable: Bool) {
        self.isHidden = enable
    }
    
    func setActionHandler(action: ((_ isSelected: Bool) -> Void)?) {
        self.buttonActionHandler = action
    }
    
}
