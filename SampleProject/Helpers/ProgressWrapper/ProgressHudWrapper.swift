//
//  ProgressHudWrapper.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 18/01/2024.
//

import Foundation
import ProgressHUD

struct ProgressHudWrapper {
    
    static func loadingIndicator(message: String? = nil, type: AnimationType = .activityIndicator, interaction: Bool = false) {
        ProgressHUD.animate(message, type, interaction: interaction)
    }
    
    static func succeed(message: String? = nil, interaction: Bool = false, delay: TimeInterval? = nil) {
        ProgressHUD.succeed(message, interaction: interaction, delay: delay)
    }
    
    static func failed(message: String? = nil, interaction: Bool = false, delay: TimeInterval? = nil) {
        ProgressHUD.failed(message, interaction: interaction, delay: delay)
    }
    
    static func showBanner(title: String? = nil, message: String? = nil, delay: TimeInterval? = nil) {
        ProgressHUD.banner(title, message, delay: delay ?? 0)
    }
    
    static func dismissBanner() {
        ProgressHUD.bannerHide()
    }
    
    static func dismiss() {
        ProgressHUD.dismiss()
    }
}
