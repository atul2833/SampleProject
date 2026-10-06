//
//  Shareable.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 30/01/2024.
//

import UIKit

protocol Shareable {
    func shareActivity(with items: [Any], and activities: [UIActivity]?)
}

extension Shareable where Self: UIViewController {
    func shareActivity(with items: [Any], and activities: [UIActivity]? = nil) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: activities)
        
        // For iPad, provide a source rect for the popover
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
}
