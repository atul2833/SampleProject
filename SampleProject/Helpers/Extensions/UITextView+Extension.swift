//
//  UITextView+Extension.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 18/01/2024.
//

import UIKit

extension UITextView {
    struct TextConfig {
        var originalText: String?
        var textColor: UIColor? = .black
        var textAlignment: NSTextAlignment? = .left
        var font: UIFont? = AppFont.regular(.description)
    }
    
    struct HyperlinkModel {
        var hyperLink: [String] = []
        var urlString: [String] = []
        var linkColor: UIColor? = .link
        var font: UIFont? = AppFont.medium(.description)
    }
    
    struct Model {
        var textConfig: TextConfig? = nil
        var linkConfig: HyperlinkModel? = nil
    }
    
    func addHyperLinkText(model: Model) {
       
        let attributedOriginalText = NSMutableAttributedString(string: model.textConfig?.originalText ?? "")
        let fullRange = NSMakeRange(0, attributedOriginalText.length)
        
        let style = NSMutableParagraphStyle()
        style.alignment = .left

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: style,
            .foregroundColor: model.textConfig?.textColor ?? .black,
            .font: model.textConfig?.font ?? AppFont.regular(.description)
        ]
        
        attributedOriginalText.addAttributes(attributes, range: fullRange)
        
        for (url, text) in zip(model.linkConfig?.urlString ?? [], model.linkConfig?.hyperLink ?? []){
            var searchRange = fullRange
            var range = NSRange(location: 0, length: 0)
            
            while range.location != NSNotFound {
                range = attributedOriginalText.mutableString.range(of: text, options: [], range: searchRange)
                if range.location != NSNotFound {
                    attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: url, range: range)
                    attributedOriginalText.addAttribute(.font, value: model.linkConfig?.font ?? AppFont.medium(.description), range: range)
                    searchRange = NSRange(location: NSMaxRange(range), length: attributedOriginalText.length - NSMaxRange(range))
                }
            }
        }
        
        self.linkTextAttributes = [
            .foregroundColor: model.linkConfig?.linkColor ?? .link,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let combination = NSMutableAttributedString()
        combination.append(attributedOriginalText)
        
        combination.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: combination.length))

        self.attributedText = combination
    }
}
