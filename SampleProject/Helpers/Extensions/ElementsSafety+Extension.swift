//
//  ElementsSafety+Extension.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 07/02/2024.
//

import Foundation

extension RandomAccessCollection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    /// - complexity: O(1)
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        return self[index]
    }
    
}
