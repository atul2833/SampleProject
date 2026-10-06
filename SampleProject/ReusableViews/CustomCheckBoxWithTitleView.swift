//
//  CustomCheckBoxWithTitleView.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 18/01/2024.
//

import UIKit

final class CustomCheckBoxWithTitleView: UIView {
    
    private var iconConfigModel: IconConfig?
    
    private var isChecked: Bool = false {
        didSet {
            checkBoxImageView.image = isChecked ? iconConfigModel?.selectedIcon : iconConfigModel?.icon
        }
    }
    
    struct IconConfig {
        var icon: UIImage? = nil
        var selectedIcon: UIImage? = nil
        var iconTintColor: UIColor? = nil
        var iconSize: CGSize? = .init(width: 15, height: 15)
    }
    
    struct Model {
        var iconConfig: IconConfig?
        var textConfig: UITextView.TextConfig?
        var hyperLinkConfig: UITextView.HyperlinkModel?
        var numberOfLines: Int = 0
        
        init(
            iconConfig: IconConfig? = nil,
            textConfig: UITextView.TextConfig? = nil,
            hyperLinkConfig: UITextView.HyperlinkModel? = nil,
            numberOfLines: Int = 0
        ) {
            self.iconConfig = iconConfig
            self.textConfig = textConfig
            self.hyperLinkConfig = hyperLinkConfig
            self.numberOfLines = numberOfLines
        }
    }
        
    convenience init(model: Model) {
        self.init(frame: .zero)
        self.setupView(model: model)
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let checkBoxImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.textContainer.lineFragmentPadding = .zero
        tv.textContainerInset = .zero
        tv.dataDetectorTypes = [.link]
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    func isTermAndConditionChecked() -> Bool {
        self.isChecked
    }
}

private extension CustomCheckBoxWithTitleView {
    
    func setupView(model: Model) {
        self.iconConfigModel = model.iconConfig
        self.setupContainerView()
        self.setupCheckBoxView(model: model.iconConfig)
        self.setupTitleLabel(model: model.textConfig)
        self.configureTextViewHyperLinks(model: model)
        self.setupConstraints()
    }
    
    func configureTextViewHyperLinks(model: Model) {
        guard let hyperLinkModel = model.hyperLinkConfig else { return }
        
        self.textView.addHyperLinkText(
            model: UITextView.Model(
                textConfig: model.textConfig,
                linkConfig: hyperLinkModel
            )
        )
    }
    
    func setupContainerView() {
        self.addSubview(containerView)
        self.anchor(
            top: self.topAnchor,
            left: self.leadingAnchor,
            bottom: self.bottomAnchor,
            right: self.trailingAnchor
        )
    }
    
    func setupCheckBoxView(model: IconConfig?) {
        self.checkBoxImageView.setSize(
            width: model?.iconSize?.width,
            height: model?.iconSize?.height
        )
        checkBoxImageView.isUserInteractionEnabled = true
        checkBoxImageView.image = model?.icon
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(checkboxTapped))
        checkBoxImageView.addGestureRecognizer(tapGesture)

        self.addSubview(checkBoxImageView)
        
        self.checkBoxImageView.centerY(
            inView: self,
            leftAnchor: self.leadingAnchor,
            paddingLeft: 5
        )
    }
    
    @objc private func checkboxTapped() {
        isChecked.toggle()
    }
    
    func setupTitleLabel(model: UITextView.TextConfig?) {
        textView.text = model?.originalText
        textView.textColor = model?.textColor
        textView.textAlignment = model?.textAlignment ?? .left
        textView.font = model?.font ?? AppFont.regular(.description)
        self.addSubview(textView)
    }
    
    func setupConstraints() {
        self.textView.anchor(
            top: self.checkBoxImageView.topAnchor,
            left: self.checkBoxImageView.trailingAnchor,
            bottom: self.checkBoxImageView.bottomAnchor,
            right: self.trailingAnchor,
            paddingTop: 2,
            paddingLeft: 5,
            paddingRight: 5
        )
    }
}

