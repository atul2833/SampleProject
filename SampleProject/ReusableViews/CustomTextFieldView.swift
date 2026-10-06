import UIKit

class CustomTextFieldView: UIView {
    private var model: Model?
    
    struct TextFieldTitleConfig {
        var title: String? = nil
        var isShowTextFieldTitle: Bool? = false
        var textFieldTitleColor: UIColor? = .lightGray
        var textFieldTitleFont: UIFont? = AppFont.regular(.subTitle)
    }

    struct TextFieldPreLabelConfig {
        var isShowTextFieldPreLabel: Bool? = false
        var preTextLabel: String?
        var textFieldPreLabelColor: UIColor? = .black
        var textFieldPreLabelFont: UIFont? = AppFont.regular(.subTitle)
        var textFieldPreAlignment: NSTextAlignment? = .left
    }

    struct AppearanceConfig {
        var textColor: UIColor? = .black
        var textFieldFont: UIFont? = AppFont.regular(.subTitle)
        var backgroundColor: UIColor? = .clear
        var cornerRadius: CGFloat? = 0
        var borderStyle: CustomTextFieldView.BorderStyle? = CustomTextFieldView.BorderStyle.none
        var separatorColor: UIColor? = .systemGray5
        var separatorHeight: CGFloat? = 1
    }

    struct TextFieldConfig {
        var placeholder: String? = nil
        var text: String? = nil
        var isSecureTextField: Bool? = false
        var isEnable: Bool? = true
        var textContentType: UITextContentType? = nil
        var keyboardType: UIKeyboardType? = .default
        var textSpacing: CGFloat? = .zero
        var textAlignment: NSTextAlignment? = .left
        var textFieldDelegate: UITextFieldDelegate? = nil
        var inputView: UIView? = nil
    }

    struct ImageConfig {
        var leftImage: UIImage? = nil
        var leftImageSize: CGSize? = CGSize(width: 40, height: 40)
        var leftImageTintColor: UIColor? = .appBase
        var rightImage: UIImage? = nil
        var rightImageSelected: UIImage? = nil
        var rightImageSize: CGSize? = CGSize(width: 40, height: 40)
        var rightImageTintColor: UIColor? = .appBase
        var rightImageAction: (() -> Void)? = nil
    }
    
    struct Model {
        var titleConfig: TextFieldTitleConfig?
        var preLabelConfig: TextFieldPreLabelConfig?
        var appearanceConfig: AppearanceConfig
        var textFieldConfig: TextFieldConfig?
        var imageConfig: ImageConfig?
        init(
            titleConfig: TextFieldTitleConfig? = nil,
            preLabelConfig: TextFieldPreLabelConfig? = nil,
            appearanceConfig: AppearanceConfig,
            textFieldConfig: TextFieldConfig? = nil,
            imageConfig: ImageConfig? = nil
        ) {
            self.titleConfig = titleConfig
            self.preLabelConfig = preLabelConfig
            self.appearanceConfig = appearanceConfig
            self.textFieldConfig = textFieldConfig
            self.imageConfig = imageConfig
        }
    }

    enum BorderStyle {
        case none
        case rounded
        case squared
    }

    private let textFieldTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let textFieldPreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let separatorView: UIView = {
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        return separatorView
    }()

    convenience init(model: Model) {
        self.init(frame: .zero)
        self.model = model
        setupTitleLabel(with: model)
        setupTextFieldPreLabel(with: model)
        setupTextField(with: model)
        setupLeftImageView(with: model)
        setupRightImageView(with: model)
        setupSeparatorView(with: model)
        configureConstraints(with: model)
        if let spacing = model.textFieldConfig?.textSpacing {
            setCharacterSpacing(characterSpacing: spacing)
        }
    }

    private func setupTitleLabel(with model: Model) {
        if model.titleConfig?.isShowTextFieldTitle ?? false {
            addSubview(textFieldTitleLabel)
            textFieldTitleLabel.text = model.titleConfig?.title
            textFieldTitleLabel.textColor = model.titleConfig?.textFieldTitleColor
            textFieldTitleLabel.font = model.titleConfig?.textFieldTitleFont
        }
    }

    private func setupTextFieldPreLabel(with model: Model) {
        if model.preLabelConfig?.isShowTextFieldPreLabel ?? false {
            addSubview(textFieldPreLabel)
            textFieldPreLabel.textColor = model.preLabelConfig?.textFieldPreLabelColor
            textFieldPreLabel.font = model.preLabelConfig?.textFieldPreLabelFont
            textFieldPreLabel.text = model.preLabelConfig?.preTextLabel
            textFieldPreLabel.textAlignment = model.preLabelConfig?.textFieldPreAlignment ?? .left
        }
    }

    private func setupTextField(with model: Model) {
        addSubview(textField)
        textField.delegate = model.textFieldConfig?.textFieldDelegate
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        textField.placeholder = model.textFieldConfig?.placeholder
        textField.textAlignment = model.textFieldConfig?.textAlignment ?? .natural
        textField.text = model.textFieldConfig?.text
        textField.keyboardType = model.textFieldConfig?.keyboardType ?? .default
        textField.textContentType = model.textFieldConfig?.textContentType
        textField.isSecureTextEntry = model.textFieldConfig?.isSecureTextField ?? false
        textField.textColor = model.appearanceConfig.textColor
        textField.font = model.appearanceConfig.textFieldFont
        textField.backgroundColor = model.appearanceConfig.backgroundColor
        textField.layer.cornerRadius = model.appearanceConfig.cornerRadius ?? 0
        textField.isEnabled = model.textFieldConfig?.isEnable ?? true
        switch model.appearanceConfig.borderStyle {
        case .rounded:
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = model.appearanceConfig.textColor?.cgColor
        case .squared:
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = model.appearanceConfig.textColor?.cgColor
            textField.layer.cornerRadius = model.appearanceConfig.cornerRadius ?? 0
        default:
            break
        }
    }

    private func setupLeftImageView(with model: Model) {
        if let leftImage = model.imageConfig?.leftImage {
            addSubview(leftImageView)
            leftImageView.image = leftImage
            leftImageView.tintColor = model.imageConfig?.leftImageTintColor ?? nil
        }
    }

    private func setupRightImageView(with model: Model) {
        if let rightImage = model.imageConfig?.rightImage {
            addSubview(rightImageView)
            rightImageView.image = rightImage
            rightImageView.tintColor = model.imageConfig?.leftImageTintColor ?? nil
        }
    }
    
    @objc private func rightImageAction() {
        guard let model else { return }
        if model.textFieldConfig?.isSecureTextField ?? false {
            self.textField.isSecureTextEntry.toggle()
            rightImageView.image = self.textField.isSecureTextEntry ? model.imageConfig?.rightImage : model.imageConfig?.rightImageSelected
            model.imageConfig?.rightImageAction?()
        } else if model.imageConfig?.rightImageAction != nil {
            model.imageConfig?.rightImageAction?()
        }
    }

    private func setupSeparatorView(with model: Model) {
        addSubview(separatorView)
        separatorView.backgroundColor = model.appearanceConfig.separatorColor
    }

    func configureConstraints(with model: Model) {
        var views = [UIView]()

        if model.imageConfig?.leftImage != nil {
            leftImageView.setSize(width: model.imageConfig?.leftImageSize?.width)
            views.append(leftImageView)
            addSubview(leftImageView)
        }

        if model.preLabelConfig?.isShowTextFieldPreLabel ?? false {
            textFieldPreLabel.setSize(width: 45)
            views.append(textFieldPreLabel)
        }
        views.append(textField)

        if model.imageConfig?.rightImage != nil {
            rightImageView.setSize(width: model.imageConfig?.rightImageSize?.width)
            rightImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(rightImageAction))
            rightImageView.addGestureRecognizer(tap)
            views.append(rightImageView)
            addSubview(rightImageView)
        }

        let stackView = createStackView(arrangedSubviews: views, axis: .horizontal)
        addSubview(stackView)
    
        if model.titleConfig?.isShowTextFieldTitle ?? false {
            textFieldTitleLabel.anchor(
                top: topAnchor,
                left: leadingAnchor,
                right: trailingAnchor,
                height: 20
            )
        }
        stackView.anchor(
            top: (model.titleConfig?.isShowTextFieldTitle ?? false) ? textFieldTitleLabel.bottomAnchor : topAnchor,
            left: leadingAnchor,
            bottom: bottomAnchor,
            right: trailingAnchor,
            paddingLeft: model.imageConfig?.leftImage != nil ? -8 : 0,
            height: 45
        )

        separatorView.anchor(
            left: leadingAnchor,
            bottom: bottomAnchor,
            right: trailingAnchor
        )
        separatorView.setSize(height: model.appearanceConfig.separatorHeight)
    }

    func setLeftImage(_ image: UIImage?) {
        leftImageView.image = image
    }

    func getText() -> String? {
        return textField.text
    }
    
    func getPreLabelText() -> String? {
        return self.textFieldPreLabel.text
    }

    func setTextFieldPreLabelTitle(text: String) {
        textFieldPreLabel.text = text
    }
    
    func setTextField(_ text: String) {
        self.textField.text = text
    }
}

extension CustomTextFieldView: UITextFieldDelegate {
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let model else { return }
        if (model.titleConfig?.isShowTextFieldTitle ?? false) && 
            !(textField.text?.isEmpty ?? false) {
            textFieldTitleLabel.text = model.textFieldConfig?.placeholder ?? model.titleConfig?.title
        } else {
            textFieldTitleLabel.text = model.titleConfig?.title ?? String()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 6
    }
    
    func setCharacterSpacing(characterSpacing: CGFloat = .zero) {
        // Set the character spacing value
        let characterSpacing: CGFloat = characterSpacing
        
        // Create an attributed string with the desired character spacing
        let attributedString = NSMutableAttributedString(
            string: textField.text ?? ""
        )
        attributedString.addAttribute(
            NSAttributedString.Key.kern,
            value: characterSpacing,
            range: NSRange(
                location: 0,
                length: attributedString.length
            )
        )
        textField.attributedText = attributedString
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        setCharacterSpacing()
    }
    
    func update(title text: String, and value: String) {
        self.textFieldTitleLabel.text = text
        self.textField.text = value
    }
}
