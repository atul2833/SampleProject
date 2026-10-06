//
//  UIView+Extension.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 10/01/2024.
//

import UIKit

extension UIView {
    
    enum CornerEnum: String {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    func anchor(
        top: NSLayoutYAxisAnchor? = nil,
        left: NSLayoutXAxisAnchor? = nil,
        bottom: NSLayoutYAxisAnchor? = nil,
        right: NSLayoutXAxisAnchor? = nil,
        paddingTop: CGFloat = 0,
        paddingLeft: CGFloat = 0,
        paddingBottom: CGFloat = 0,
        paddingRight: CGFloat = 0,
        width: CGFloat? = nil,
        height: CGFloat? = nil
    )
    {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left {
            leadingAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right {
            trailingAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func anchorWithLessThen(
        top: NSLayoutYAxisAnchor? = nil,
        left: NSLayoutXAxisAnchor? = nil,
        bottom: NSLayoutYAxisAnchor? = nil,
        right: NSLayoutXAxisAnchor? = nil,
        paddingTop: CGFloat = 0,
        paddingLeft: CGFloat = 0,
        paddingBottom: CGFloat = 0,
        paddingRight: CGFloat = 0,
        width: CGFloat? = nil,
        height: CGFloat? = nil
    )
    {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top {
            topAnchor.constraint(lessThanOrEqualTo: top, constant: paddingTop).isActive = true
        }
        
        if let left {
            leadingAnchor.constraint(lessThanOrEqualTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom {
            bottomAnchor.constraint(lessThanOrEqualTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right {
            trailingAnchor.constraint(lessThanOrEqualTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func center(
        centerX: NSLayoutXAxisAnchor? = nil,
        paddingX: CGFloat = 0,
        centerY: NSLayoutYAxisAnchor? = nil,
        paddingY: CGFloat = 0
    )
    {
        translatesAutoresizingMaskIntoConstraints = false
        if let centerX {
            centerXAnchor.constraint(equalTo: centerX, constant: paddingX).isActive = true
        }
        
        if let centerY {
            centerYAnchor.constraint(equalTo: centerY, constant: paddingY).isActive = true
        }
    }
    
    func center(
        inView view: UIView,
        yConstant: CGFloat = 0
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant).isActive = true
    }
    
    func centerX(
        inView view: UIView,
        topAnchor: NSLayoutYAxisAnchor? = nil,
        paddingTop: CGFloat = 0
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if let topAnchor {
            self.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop).isActive = true
        }
    }
    
    func centerY(
        inView view: UIView,
        leftAnchor: NSLayoutXAxisAnchor? = nil,
        paddingLeft: CGFloat? = nil,
        constant: CGFloat = 0
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let leftAnchor, let paddingLeft {
            self.leadingAnchor.constraint(equalTo: leftAnchor, constant: paddingLeft).isActive = true
        }
    }
    
    func centerY(
        inView view: UIView,
        rightAnchor: NSLayoutXAxisAnchor? = nil,
        paddingRight: CGFloat? = nil,
        constant: CGFloat = 0
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: constant).isActive = true
        
        if let rightAnchor, let paddingRight {
            self.trailingAnchor.constraint(equalTo: rightAnchor,constant: paddingRight).isActive = true
        }
    }
    
    func setSize(
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        if let width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func proportionalSize(
        width: NSLayoutDimension? = nil,
        widthPercent: CGFloat = 1,
        height: NSLayoutDimension? = nil,
        heightPercent: CGFloat = 1
    )
    {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let width {
            widthAnchor.constraint(equalTo: width, multiplier: widthPercent).isActive = true
        }
        
        if let height {
            heightAnchor.constraint(equalTo: height, multiplier: heightPercent).isActive = true
        }
    }
    
    func addConstraintsToFillView(
        _ view: UIView
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        anchor(
            top: view.topAnchor,
            left: view.leadingAnchor,
            bottom: view.bottomAnchor,
            right: view.trailingAnchor
        )
    }
    
    func setViewToCorner(corner: CornerEnum, in view: UIView, padding: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        anchor(
            top: (corner == .topLeft || corner == .topRight ) ? view.topAnchor : nil,
            left: (corner == .topLeft || corner == .bottomLeft) ? view.leadingAnchor : nil,
            bottom: (corner == .bottomLeft || corner == .bottomRight) ? view.bottomAnchor : nil,
            right: (corner == .topRight || corner == .bottomRight) ? view.trailingAnchor : nil,
            paddingTop: padding,
            paddingLeft: padding,
            paddingBottom: padding,
            paddingRight: padding
        )
    }
    
    func roundCorners(
        corners: UIRectCorner,
        radius: CGFloat
    ) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(
                width: radius,
                height: radius
            )
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func dropShadow(
        shadowOffset: CGSize = .zero,
        shadowOpacity: Float = 0.4,
        shadowRadius: CGFloat = 2,
        shadowColor: UIColor = .black,
        cornerRadius: CGFloat = 5,
        maskCorner: Bool = false
    ) {
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = false
        if maskCorner {
            self.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner,
                .layerMaxXMinYCorner
            ]
        }
    }
    
    func removeShadow() {
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 0
        self.layer.shadowOpacity = 0
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.cornerRadius = 0
    }
    
    func createStackView(
        arrangedSubviews: [UIView],
        axis: NSLayoutConstraint.Axis,
        distribution: UIStackView.Distribution = .fillProportionally,
        alignment: UIStackView.Alignment = .fill,
        spacing: CGFloat = 1
    ) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.distribution = distribution
        stackView.alignment = alignment
        stackView.spacing = spacing
        
        return stackView
    }
    
    func makeCorners(
        corners: CACornerMask,
        radius: CGFloat
    ) {
        self.clipsToBounds = false
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
    }
    
    func bounce(
        duration: TimeInterval = 1,
        scale: CGFloat = 1.5,
        completion: (
    () -> Void
        )? = nil
    ) {
        UIView.animate(withDuration: duration/2, animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }) { _ in
            UIView.animate(withDuration: duration/2, animations: {
                self.transform = .identity
            }, completion: { _ in
                completion?()
            })
        }
    }
}

