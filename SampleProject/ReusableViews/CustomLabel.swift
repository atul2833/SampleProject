//
//  CustomLabel.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 09/01/2024.
//

import UIKit

class CustomLabel: UILabel {
    
    struct Model {
        var title: String?
        var textColor: UIColor
        var font: UIFont
        var numberOfLines: Int
        var textAlignment: NSTextAlignment
        init(
            title: String?,
            textColor: UIColor,
            font: UIFont,
            numberOfLines: Int = 1,
            textAlignment: NSTextAlignment = .natural
        ) {
            self.title = title
            self.textColor = textColor
            self.font = font
            self.numberOfLines = numberOfLines
            self.textAlignment = textAlignment
        }
    }
    
    convenience init(model: Model) {
        self.init()
        self.text = model.title
        self.textColor = model.textColor
        self.textAlignment = model.textAlignment
        self.numberOfLines = model.numberOfLines
        self.font = model.font
    }
    
    
    convenience init(frame: CGRect, model: Model) {
        self.init(frame: frame)
        self.text = model.title
        self.textColor = model.textColor
        self.textAlignment = model.textAlignment
        self.numberOfLines = model.numberOfLines
        self.font = model.font
    }
    
}
