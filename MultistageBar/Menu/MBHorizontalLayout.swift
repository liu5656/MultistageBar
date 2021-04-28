//
//  MBHorizontalLayout.swift
//  MultistageBar
//
//  Created by x on 2021/4/27.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBHorizontalLayout: UICollectionViewLayout {
    var scrollDirection: UICollectionView.ScrollDirection = .horizontal
    var itemSize: CGSize = .zero
    var sectionInset: UIEdgeInsets = .zero
    
    var minimumLineSpacing: CGFloat = 10
    var minimumInteritemSpacing: CGFloat = 10
    
    private var maxNumPerRow = 5   // 每行最多item
    private var maxNumPerColumn = 2    // 每列最多item
    
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {return}
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        maxNumPerRow = Int((width + minimumLineSpacing - sectionInset.left - sectionInset.right) / (itemSize.width + minimumLineSpacing))
        maxNumPerColumn = Int((height + minimumInteritemSpacing - sectionInset.top - sectionInset.bottom) / (itemSize.height + minimumInteritemSpacing))
    }
    
    
    
    override var collectionViewContentSize: CGSize {
        get{
            guard let collectionView = collectionView else {return .zero}
            var width: CGFloat = 0
            let height: CGFloat = collectionView.bounds.size.height
            let sections = collectionView.numberOfSections
            for i in 0..<sections {
                if scrollDirection == .horizontal {
                    let all = collectionView.numberOfItems(inSection: i)
                    let tempLine = all / maxNumPerRow
                    let lineNum = maxNumPerRow * tempLine < all ? (tempLine + 1) : tempLine
                    
                    let tempColumn = lineNum / maxNumPerColumn
                    let sceneNum = maxNumPerColumn * tempColumn < lineNum ? (tempColumn + 1) : tempColumn
                    width += sectionInset.left + CGFloat(maxNumPerRow * sceneNum) * (itemSize.width + minimumLineSpacing) - minimumLineSpacing + sectionInset.right
                }
            }
            return CGSize.init(width: width, height: height)
        }
    }

override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    let attributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        var frame = CGRect.init(origin: .zero, size: itemSize)
        var x: CGFloat = 0
        var y: CGFloat = 0
        let column: CGFloat = CGFloat(indexPath.row % maxNumPerRow + indexPath.row / (maxNumPerColumn * maxNumPerRow) * maxNumPerRow)
        let row: CGFloat = CGFloat(indexPath.row / maxNumPerRow % maxNumPerColumn)
        if scrollDirection == .horizontal {
            x = sectionInset.left + (itemSize.width + minimumLineSpacing) * column + 300
            y = sectionInset.top + (itemSize.height + minimumInteritemSpacing) * row
        }
        frame.origin = CGPoint.init(x: x, y: y)
        attributes.frame = frame
        return attributes
    }
    

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let tempColl = collectionView else {return nil}
        let sections = tempColl.numberOfSections
        var attributes: [UICollectionViewLayoutAttributes] = []
        for section in 0..<sections {
            let rows = tempColl.numberOfItems(inSection: section)
            for row in 0..<rows {
                if let attribute = layoutAttributesForItem(at: IndexPath.init(row: row, section: section)) {
                    attributes.append(attribute)
                }
            }
        }
        return attributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: elementKind, with: indexPath)
        attribute.frame = CGRect.init(x: 0, y: 0, width: 200, height: 100)
        return attribute
    }
    
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
