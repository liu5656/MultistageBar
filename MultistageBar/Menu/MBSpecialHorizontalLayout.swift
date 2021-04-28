//
//  MBSpecialHorizontalLayout.swift
//  MultistageBar
//
//  Created by x on 2021/4/27.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBSpecialHorizontalLayout: UICollectionViewLayout {
    
    var scrollDirection: UICollectionView.ScrollDirection = .horizontal
    var itemSize: CGSize = .zero
    var sectionInset: UIEdgeInsets = .zero
    var minimumLineSpacing: CGFloat = 10
    var minimumInteritemSpacing: CGFloat = 10
    
    var maxRows: Int = 0
    var maxColumn: Int = 0
    private var sectionsSize: [Int: CGSize] = [:]
    
    override func prepare() {
        super.prepare()
        guard let col = collectionView else {
            return
        }
        maxRows = Int((col.bounds.height + minimumLineSpacing) / (itemSize.height + minimumLineSpacing))
        maxColumn = Int((col.bounds.width + minimumInteritemSpacing) / (itemSize.width + minimumInteritemSpacing))
    }
    // 这里的尺寸是指的所有内容所占的尺寸
    override var collectionViewContentSize: CGSize {
        get{
            guard let col = collectionView else {
                return .zero
            }
            sectionsSize.removeAll()
            var width: CGFloat = 0
            let height = col.bounds.height
            let sections = col.numberOfSections
            for i in 0..<sections {
                let rows = col.numberOfItems(inSection: i)
                let scene = rows / (maxRows * maxColumn) + 1
                width += sectionInset.left + CGFloat(maxColumn * scene) * (itemSize.width + minimumInteritemSpacing) - minimumInteritemSpacing + sectionInset.right
                sectionsSize[i] = CGSize.init(width: width, height: height)
            }
            return CGSize.init(width: width, height: height)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        MBLog(rect)
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        var res: [UICollectionViewLayoutAttributes] = []
        attributes.forEach { (item) in
            switch item.representedElementCategory {
            case .cell:
                if let temp = layoutAttributesForItem(at: item.indexPath) {
                    res.append(temp)
                }
            case .supplementaryView:
                if let kind = item.representedElementKind,
                   let temp = layoutAttributesForSupplementaryView(ofKind: kind, at: item.indexPath) {
                    res.append(temp)
                }
            default:
                break
            }
        }
        return res
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        var begin: CGFloat = 0
        (0..<indexPath.section).forEach { (section) in
            if let size = sectionsSize[section] {
                begin += size.width
            }
        }

        // 确定在哪一屏的哪一行哪一列
        let scene = indexPath.row / (maxRows * maxColumn)      // ceil(CGFloat(indexPath.row) / CGFloat(factRow * factColumn)) 哪一屏,0...
        let temp = indexPath.row % (maxRows * maxColumn)
        let row = temp / maxColumn                             // ceil(CGFloat(temp) / CGFloat(factColumn)) 哪一行,0...
        let column = temp % maxColumn                          // CGFloat(temp % factColumn) // 哪一列,0...
        // (scene * CGFloat(factColumn) + column) * (itemSize.width + minimumInteritemSpacing)
        let cellX = sectionInset.left + CGFloat(scene * maxColumn + column) * (itemSize.width + minimumInteritemSpacing)
        let cellY = sectionInset.top + CGFloat(row) * (itemSize.height + minimumLineSpacing)
        
        attribute.frame = CGRect.init(origin: CGPoint.init(x: cellX, y: cellY), size: itemSize)
        return attribute
    }
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard elementKind == UICollectionView.elementKindSectionHeader,
              let col = collectionView,
              let attribute = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) else {
            return nil
        }
        
        var frame = attribute.frame
        frame.origin.x = col.contentOffset.x
        attribute.frame = frame
        attribute.zIndex = 999
        return attribute
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
}
