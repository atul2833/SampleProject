//
//  AppFont.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 09/01/2024.
//

import UIKit

class AppFont {
    enum AppFontSize: Int {
        
        case otpCodeSize = 30
        case walletBalanceTextSize = 20
        case title = 18
        case subTitle = 16
        case description = 14
        case sectionTrailingTextSize = 13
        
        var value: CGFloat {
            return CGFloat(rawValue)
        }
    }
    
    enum FontWeight: Int {
        case regular, bold, semiBold, medium, italic
        
        var name: String {
            switch self {
            case .bold:
                return "Bold"
            case .semiBold:
                return "SemiBold"
            case .medium:
                return "Medium"
            case .regular:
                return "Regular"
            case .italic:
                return "Italic"
            }
        }
    }
    
    static func font(_ fontSize: AppFontSize, weight: FontWeight = .regular) -> UIFont {
        return UIFont(name: "Montserrat-\(weight.name)", size: fontSize.value) ?? UIFont.systemFont(ofSize: fontSize.value, weight: .regular)
    }
    
    static func regular(_ fontSize: AppFontSize) -> UIFont {
        font(fontSize, weight: .regular)
    }
    
    static func bold(_ fontSize: AppFontSize) -> UIFont {
        font(fontSize, weight: .bold)
    }
    
    static func medium(_ fontSize: AppFontSize) -> UIFont {
        font(fontSize, weight: .medium)
    }
    
    static func semi(_ fontSize: AppFontSize) -> UIFont {
        font(fontSize, weight: .semiBold)
    }
    
    static func regularFont(regularFontWithSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    static func boldFont(boldFontWithSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    static func extraBoldFont(extraBoldFontWithSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    static func mediumFont(mediumFontWithSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    static func italic(fontWithSize size: CGFloat) -> UIFont {
        return UIFont.italicSystemFont(ofSize: size)
    }
}
