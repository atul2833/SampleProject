//
//  UIScrollView+Extension.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 21/02/2024.
//

import UIKit

extension UIScrollView {
    func fitSizeOfContent() {
        let sumHeight = self.subviews.map({$0.frame.size.height}).reduce(0, {x,y in x+y})
        self.contentSize = CGSize(width: self.frame.width, height: sumHeight)
    }
    
    private var emptyStateViewTag: Int { return 999 }
    
    func setEmptyView(image: UIImage?, title: String) {
        removeEmptyView()
        
        let emptyView = UIView(frame: self.bounds)
        emptyView.backgroundColor = .clear
        emptyView.tag = emptyStateViewTag
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit

        imageView.setSize(width: 150,
                          height: 150)
        
        let titleLabel = CustomLabel(
            model: CustomLabel.Model(
                title: title,
                textColor: UIColor(resource: .appGray),
                font: AppFont.regular(.description),
                numberOfLines: 1,
                textAlignment: .center
            )
        )
        var views: [UIView] = []

        if let image {
            views.append(imageView)
        }

        //views.append(titleLabel)

        let stackView = emptyView.createStackView(
            arrangedSubviews: views,
            axis: .vertical,
            distribution: .fillProportionally,
            alignment: .fill,
            spacing: 5
        )
        emptyView.addSubview(stackView)
        self.addSubview(emptyView)

        stackView.center(inView: emptyView,
                         yConstant: -50)
    }
    
    func restore() {
        removeEmptyView()
    }
    
    private func removeEmptyView() {
        if let emptyView = self.viewWithTag(emptyStateViewTag) {
            emptyView.removeFromSuperview()
        }
    }
}
