//
//  NavigationConfigurator.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 15/01/2024.
//

import UIKit

extension UIViewController {
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
}

protocol NavigationBarConfigurable: AnyObject {
    func configureNavigationBar(avatar: ImageResource,
                                title: String,
                                subTitle: String?,
                                tintColor: UIColor?,
                                rightBarButtonImages: [ImageResource],
                                rightBarButtonActions: [Selector],
                                actionBack: Selector?)
    
    func configureNavigationBar(title: String, titleColor: UIColor, fontSize: AppFont.AppFontSize, rightBarItem: UIBarButtonItem?, leftBarItem: UIBarButtonItem?)
    func setBackBarItem(action: Selector?)
}

extension NavigationBarConfigurable where Self: UIViewController {
    func configureNavigationBar(
        avatar: ImageResource,
        title: String,
        subTitle: String?,
        tintColor: UIColor? = .none,
        rightBarButtonImages: [ImageResource],
        rightBarButtonActions: [Selector],
        actionBack: Selector?
    ){
        let imageView = UIImageView(image: UIImage(resource: avatar))
        imageView.layer.cornerRadius = 15
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 35, height: 35)

        let leftBarAvatarView = UIBarButtonItem(customView: imageView)

        let backBarButton = createBackBarItem(with: actionBack)

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLabel.text = title

        let subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.text = subTitle
        subtitleLabel.textColor = .gray

        let titleSubtitleStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleSubtitleStackView.axis = .vertical
        titleSubtitleStackView.alignment = .leading
        titleSubtitleStackView.distribution = .equalSpacing
        titleSubtitleStackView.spacing = 2

        let titleSubtitleBarItem = UIBarButtonItem(customView: titleSubtitleStackView)

        self.navigationItem.leftBarButtonItems = [backBarButton,
                                                  leftBarAvatarView,
                                                  titleSubtitleBarItem]
        self.navigationItem.rightBarButtonItems = []

        for (image, action) in zip(rightBarButtonImages, rightBarButtonActions) {
            let icon =  UIImage(resource: image)
            let barButton = UIBarButtonItem(image: icon,
                                            style: .done,
                                            target: self,
                                            action: action)
            barButton.tintColor = tintColor
            self.navigationItem.rightBarButtonItems?.append(barButton)
        }
    }

    func setBackBarItem(action: Selector?) {
        navigationItem.leftBarButtonItem = createBackBarItem(with: action)
    }
    
    private func createBackBarItem(with action: Selector?, tintColor: UIColor = .appBase) -> UIBarButtonItem{
        let backImageName = "chevron.left"
        let backImage = UIImage(systemName: backImageName)?.withRenderingMode(.alwaysTemplate)
        let backBarButton = UIBarButtonItem(image: backImage,
                                            style: .done,
                                            target: self,
                                            action: action)
        backBarButton.tintColor = tintColor
        return backBarButton
    }
    
    func createBackItemWithBG() -> UIBarButtonItem {
        return UIBarButtonItem(image: .iconBackArrowShadow.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backAction))
    }
}

extension NavigationBarConfigurable where Self: UIViewController {
    
    func configureNavigationBar(title: String, 
                                titleColor: UIColor = .appBase,
                                fontSize: AppFont.AppFontSize = .title,
                                rightBarItem: UIBarButtonItem? = nil,
                                leftBarItem: UIBarButtonItem? = nil) {
        var titleWidth = UIScreen.main.bounds.width - 75
        if leftBarItem != nil {
            titleWidth -= 75
        }
        let titleLbl = CustomLabel(frame: CGRect(x: 0,
                                                 y: 7,
                                                 width: titleWidth,
                                                 height: 30),
                                   model: CustomLabel.Model(
                                    title: title,
                                    textColor: titleColor,
                                    font: AppFont.bold(fontSize),
                                    numberOfLines: 0,
                                    textAlignment: leftBarItem == nil ? .left : .center
                                ))
        titleLbl.accessibilityLabel = title
        self.navigationItem.titleView = titleLbl
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.rightBarButtonItem = rightBarItem
        self.navigationItem.leftBarButtonItem = leftBarItem
    }
}
