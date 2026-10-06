//
//  NSCollectionLayoutSection+Extension.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 12/01/2024.
//

import UIKit

extension NSCollectionLayoutSection {
    struct SectionConfiguration {
        let itemDimension: NSCollectionLayoutSize
        let groupDimension: NSCollectionLayoutSize
        let scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior
        let itemInsets: NSDirectionalEdgeInsets
        let sectionInsets: NSDirectionalEdgeInsets
        let boundarySupplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem]
    
        init(
            itemDimension: NSCollectionLayoutSize,
            groupDimension: NSCollectionLayoutSize,
            scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .none,
            itemInsets: NSDirectionalEdgeInsets = .zero,
            sectionInsets: NSDirectionalEdgeInsets = .zero,
            boundarySupplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = []
        ) {
            self.itemDimension = itemDimension
            self.groupDimension = groupDimension
            self.scrollingBehavior = scrollingBehavior
            self.itemInsets = itemInsets
            self.sectionInsets = sectionInsets
            self.boundarySupplementaryItems = boundarySupplementaryItems
        }
    }
    
    convenience init(configuration: SectionConfiguration) {
        let item = NSCollectionLayoutItem(layoutSize: configuration.itemDimension)
        item.contentInsets = configuration.itemInsets
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: configuration.groupDimension, subitems: [item])
        self.init(group: group)
        self.contentInsets = configuration.sectionInsets
        self.orthogonalScrollingBehavior = configuration.scrollingBehavior
        self.boundarySupplementaryItems = configuration.boundarySupplementaryItems
    }
}
