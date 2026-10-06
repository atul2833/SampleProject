//
//  BottomSheetPresenter.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit

protocol BottomSheetPresentable {
    func presentBottomSheet(
        contentViewController: UIViewController,
        sheetHeight: CGFloat,
        animationDuration: TimeInterval
    )
}

extension BottomSheetPresentable where Self: UIViewController {
    func presentBottomSheet(
        contentViewController: UIViewController,
        sheetHeight: CGFloat,
        animationDuration: TimeInterval = 0.3
    ) {
        let bottomSheetVC = BottomSheetViewController(
            contentViewController: contentViewController,
            sheetHeight: sheetHeight,
            animationDuration: animationDuration
        )
        
        
        bottomSheetVC.modalPresentationStyle = .overCurrentContext
        
        if let tab = (UIApplication.shared.windows.first?.rootViewController as? UITabBarController){
            tab.present(bottomSheetVC, animated: true)
        }else if let nav = (UIApplication.shared.windows.first?.rootViewController as? UINavigationController){
            nav.present(bottomSheetVC, animated: true)
        }
    }
}

final class BottomSheetViewController: UIViewController, BottomSheetPresentable {
    
    private let contentViewController: UIViewController
    private let sheetHeight: CGFloat
    private let animationDuration: TimeInterval
    
    init(
        contentViewController: UIViewController,
        sheetHeight: CGFloat = 300,
        animationDuration: TimeInterval = 0.3
    ) {
        self.contentViewController = contentViewController
        self.sheetHeight = sheetHeight
        self.animationDuration = animationDuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addPanGesture()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear

//        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeView))
//        self.view.addGestureRecognizer(gesture)

        contentViewController.view.layer.cornerRadius = 20
        contentViewController.view.layer.shadowColor = UIColor.black.cgColor
        contentViewController.view.layer.shadowOpacity = 0.5
        contentViewController.view.layer.shadowOffset = CGSize(width: 2, height: 5)
        contentViewController.view.layer.shadowRadius = 8
        //        contentViewController.view.layer.masksToBounds = true
        //        contentViewController.view.clipsToBounds = true
        
        addChild(contentViewController)
        view.addSubview(contentViewController.view)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentViewController.view.heightAnchor.constraint(equalToConstant: sheetHeight)
        ])
        
        contentViewController.didMove(toParent: self)
    }
    
//    @objc func closeView() {
//        self.dismiss(animated: true)
//    }
    
    private func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        contentViewController.view.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)
        
        switch gestureRecognizer.state {
        case .changed:
            if translation.y > 0 {
                contentViewController.view.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            if translation.y > sheetHeight / 2 {
                dismissSheet()
            } else {
                UIView.animate(withDuration: animationDuration) {
                    self.contentViewController.view.transform = .identity
                }
            }
        default:
            break
        }
    }
    
    private func dismissSheet() {
        UIView.animate(withDuration: animationDuration, animations: {
            self.contentViewController.view.transform = CGAffineTransform(translationX: 0, y: self.sheetHeight)
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
}


