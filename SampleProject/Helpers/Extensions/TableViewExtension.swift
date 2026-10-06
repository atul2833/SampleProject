//
//  TableViewExtension.swift
//  ComeraPay
//
//  Created by Muhammad Ahmed Baig on 23/01/2024.
//

import Foundation
import UIKit

extension UITableView {
    
    func register<T: UITableViewCell>(cell: T.Type) {
        self.register(cell.self, forCellReuseIdentifier: "\(T.self)")
    }
    
    func dequeCell<T: UITableViewCell>(cell: T.Type, indexPath: IndexPath) -> T {
        
        guard let cell = self.dequeueReusableCell(withIdentifier: "\(T.self)", for: indexPath) as? T else {
            fatalError("\(T.self) is not exist")
        }
        return cell
    }
    
    func removeExtraTopPadding() {
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
        }
    }
}
