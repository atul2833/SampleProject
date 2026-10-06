//
//  UINavigationController+Extension.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 26/01/2024.
//

import UIKit

extension UINavigationController {
    func popToViewController(viewController: Swift.AnyClass) {
        for element in viewControllers as Array {
            if element.isKind(of: viewController) {
                self.popToViewController(element, animated: true)
                break
            }
        }
    }
}
