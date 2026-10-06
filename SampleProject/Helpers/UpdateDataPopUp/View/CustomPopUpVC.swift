//
//  UpdateDataPopUpVC.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit

struct ButtonsUIModel {
    var hasTwoBtns: Bool
    var primaryButton: CustomButton.Model
    var secondaryButton: CustomButton.Model?
}

struct CustomPopUpUIModel {
    var customViewUIModel: CustomViewUIModelProtocol?
    var btnData: ButtonsUIModel?
    var customView: CustomPopupViewProtocol?
    var itemsHeight: CGFloat?
}

class CustomPopUpVC: UIViewController {
    
    lazy private var mainView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let rightImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private var customView: CustomPopupViewProtocol!
    private var cancelButton: CustomButton!
    private var verifyButton: CustomButton!
    private var buttonsStackView: UIStackView!
    
    private var uiModel: CustomPopUpUIModel
    private var leadingPadding: CGFloat = 20.0
    private var trailingPadding: CGFloat = 20.0
    
    init(uiModel: CustomPopUpUIModel) {
        self.uiModel = uiModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupViews()
    }
    
    func setupViews() {
        self.view.backgroundColor = .black.withAlphaComponent(0.3)
        
        self.view.addSubview(self.mainView)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeView))
        self.view.addGestureRecognizer(gesture)

        setupMainViewConstraints()
        self.mainView.backgroundColor = .systemBackground
        self.mainView.makeCorners(
            corners: [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ],
            radius: 20
        )
        
        self.mainView.addSubview(self.rightImgView)
        self.setupRightImgConstraints()
        
        self.setupCustomView()
        self.setupBtnsStackView()
        self.setupBottomConstraint()
    }
    
    @objc func closeView() {
        self.dismiss(animated: true)
    }
    
    func setupMainViewConstraints() {
        self.mainView.anchor(
            left: self.view.leadingAnchor,
            bottom: self.view.bottomAnchor,
            right: self.view.trailingAnchor,
            paddingLeft: 0,
            paddingBottom: 0,
            paddingRight: 0
        )
    }
    
    func setupCustomView() {
        if let custom = self.uiModel.customView {
            self.customView = custom
            self.customView.backgroundColor = .clear
            self.customView.translatesAutoresizingMaskIntoConstraints = false
            self.mainView.addSubview(self.customView)
            self.setupCustomViewConstraints()
        }
        if let _ = self.uiModel.customViewUIModel as? PopUpWithTVUIModel {
            (self.customView as? PopupWithTV)?.reloadItems()
        }
        if let height = self.uiModel.itemsHeight {
            self.customView.setSize(height: height)
        }
    }
    
    func setupCustomViewConstraints() {
        self.customView.anchor(
            top: self.rightImgView.bottomAnchor,
            left: self.mainView.leadingAnchor,
            right: self.mainView.trailingAnchor,
            paddingTop: 5,
            paddingLeft: 0,
            paddingRight: 0
        )
    }
    
    func setupVerifyBtn() {
        if let verifyModel = self.uiModel.btnData?.primaryButton {
            verifyButton = CustomButton(
                model:
                    CustomButton.Model(
                        titleConfig: verifyModel.titleConfig,
                        imageConfig: verifyModel.imageConfig,
                        styleConfig: verifyModel.styleConfig,
                        actionConfig: self.getAction(model: verifyModel)
                    )
            )
        }
    }
    
    private func getAction(model: CustomButton.Model) -> CustomButton.ActionConfig? {
        if let uiModel = self.uiModel.customViewUIModel as? PopUpWithFieldUIModel,
           let view = self.customView as? PopupWithField,
           let action = uiModel.customVerifyAction {
            return CustomButton.ActionConfig(action: { isSelected in
                if !(view.getFieldText()?.isEmpty ?? false) {
                    action(view.getFieldText() ?? "")
                } else {
                    self.view.makeToast("Please enter in field")
                }
            })
        } else {
            return model.actionConfig
        }
    }
    
    func setupCancelBtn() {
        if let secondaryModel = self.uiModel.btnData?.secondaryButton {
            cancelButton = CustomButton(
                model: secondaryModel
            )
        }
    }
    
    func setupRightImgConstraints() {
        self.rightImgView.anchor(
            top: self.mainView.topAnchor,
            right: self.mainView.trailingAnchor,
            paddingTop: 18,
            paddingRight: 12,
            width: 18,
            height: 18
        )
    }
    
    func setupBtnsStackView() {
        if let btnData = self.uiModel.btnData {
            self.setupVerifyBtn()
            var arrangedSubViews: [UIView] = [verifyButton]
            if btnData.hasTwoBtns {
                self.setupCancelBtn()
                arrangedSubViews.insert(cancelButton, at: 0)
            }
            
            self.buttonsStackView = self.view.createStackView(
                arrangedSubviews: arrangedSubViews,
                axis: .horizontal,
                distribution: .fillProportionally,
                alignment: .fill,
                spacing: 10
            )
            
            self.mainView.addSubview(self.buttonsStackView)
            self.setupStackViewConstraints()
        }
    }
    
    func setupStackViewConstraints() {
        var bottomAnchor: NSLayoutYAxisAnchor = self.rightImgView.bottomAnchor
        if self.uiModel.customViewUIModel != nil {
            bottomAnchor = self.customView.bottomAnchor
        }
        self.buttonsStackView.anchor(
            top: bottomAnchor,
            left: self.mainView.leadingAnchor,
            right: self.mainView.trailingAnchor,
            paddingTop: 20,
            paddingLeft: self.leadingPadding,
            paddingRight: self.trailingPadding,
            height: 50
        )
    }
    
    func setupBottomConstraint() {
        if self.uiModel.btnData != nil {
            self.buttonsStackView.anchor(
                bottom: self.mainView.bottomAnchor,
                paddingBottom: 30
            )
        }else if self.uiModel.customViewUIModel != nil {
            self.customView.anchor(
                bottom: self.mainView.bottomAnchor,
                paddingBottom: 30
            )
        } else {
            self.rightImgView.anchor(
                bottom: self.mainView.bottomAnchor,
                paddingBottom: 30
            )
        }
    }
}
