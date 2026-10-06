//
//  AlertPresentable.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 15/01/2024.
//

import UIKit

protocol AlertPresentable: AnyObject {
    func showAlert(
        title: String?,
        message: String?,
        actions: [UIAlertAction],
        alertStyle: UIAlertController.Style
    )
}

extension AlertPresentable where Self: UIViewController {
    func showAlert(
        title: String?,
        message: String?,
        actions: [UIAlertAction],
        alertStyle: UIAlertController.Style
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach { alert.addAction($0) }
        self.present(alert, animated: true, completion: nil)
    }
}

