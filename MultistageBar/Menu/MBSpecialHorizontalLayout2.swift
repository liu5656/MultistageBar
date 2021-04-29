//
//  MBSpecialHorizontalLayout2.swift
//  MultistageBar
//
//  Created by x on 2021/4/28.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBSpecialHorizontalLayout2: UICollectionViewLayout {
    
    var attributes: [UICollectionViewLayoutAttributes] = []
    var scrollDirection: UICollectionView.ScrollDirection = .horizontal
    var itemSize: CGSize = .zero
    var sectionInset: UIEdgeInsets = .zero
    var minimumLineSpacing: CGFloat = 10
    var minimumInteritemSpacing: CGFloat = 10
    
    var maxRows: Int = 0                                // 一屏最多展示多少行
    var maxColumn: Int = 0                              // 一屏最多展示多少列
    private var sectionsSize: [Int: CGSize] = [:]       // 保存每个分区的size,宽度:左边距 + 中间部分 + 右边距,高度:上边距 + 中间部分 + 下边距
    
    override func prepare() {
        super.prepare()
        guard let col = collectionView else {
            return
        }
        sectionsSize.removeAll()
        attributes.removeAll()
        maxRows = Int((col.bounds.height + minimumLineSpacing) / (itemSize.height + minimumLineSpacing))
        maxColumn = Int((col.bounds.width + minimumInteritemSpacing) / (itemSize.width + minimumInteritemSpacing))
        var offsetX: CGFloat = 0                           // 每个分区偏移值x
        for section in 0..<col.numberOfSections {
            let itemNum = col.numberOfItems(inSection: section)
            for row in 0..<itemNum {
                let index = IndexPath.init(row: row, section: section)
                prepareSupplementAttribute(at: index, offsetX: offsetX)
                prepareItemAttribute(at: index, offsetX: offsetX)
                if row == (itemNum - 1) {
                    // 不足一屏,按照一屏计算
                    let (scene, _) = (row + 1).divided(maxRows * maxColumn)
                    // 分区宽度: 左边距 + 中间部分 + 右边距
                    let width = sectionInset.left + CGFloat(scene * maxColumn) * (itemSize.width + minimumInteritemSpacing) - minimumInteritemSpacing
                    sectionsSize[section] = CGSize.init(width: width, height: col.bounds.height)
                    offsetX += width
                }
            }
        }
    }
    private func prepareSupplementAttribute(at index: IndexPath, offsetX: CGFloat) {
        guard 0 == index.row else {
            return
        }
        
        let kind = UICollectionView.elementKindSectionHeader
        let attribute = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: kind, with: index)
        attribute.frame = CGRect.init(x: sectionInset.left, y: sectionInset.top, width: 300, height: 60)
        attribute.zIndex = 999
        attributes.append(attribute)
    }
    private func prepareItemAttribute(at index: IndexPath, offsetX: CGFloat) {
        let attribute = UICollectionViewLayoutAttributes.init(forCellWith: index)
        let row = index.row
        // 确定在当前分区的哪一屏的哪一行哪一列
        let scene = row / (maxRows * maxColumn)    // 哪一屏,0...
        let temp = row % (maxRows * maxColumn)
        let line = temp / maxColumn                // 哪一行,0...
        let column = temp % maxColumn              // 哪一列,0...
        let cellX = offsetX + sectionInset.left + CGFloat(scene * maxColumn + column) * (itemSize.width + minimumInteritemSpacing)
        let cellY = sectionInset.top + CGFloat(line) * (itemSize.height + minimumLineSpacing)
        attribute.frame = CGRect.init(origin: CGPoint.init(x: cellX, y: cellY), size: itemSize)
        attributes.append(attribute)
    }
    
    // 这里的尺寸是指的所有内容所占的尺寸
    override var collectionViewContentSize: CGSize {
        get{
            guard let col = collectionView else {
                return .zero
            }
            let width = sectionsSize.values.reduce(0, {$0 + $1.width})
            return CGSize.init(width: width, height: col.bounds.height)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // 相交过滤出要展示在rect范围内的attribute
        let temp = attributes.filter({$0.frame.intersects(rect)})
        temp.filter({$0.representedElementCategory == UICollectionView.ElementCategory.supplementaryView}).forEach { (attribute) in
            attribute.frame = CGRect.init(x: sectionInset.left + collectionView!.contentOffset.x, y: sectionInset.top, width: 300, height: 60)
        }
        return temp
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.layoutAttributesForItem(at: indexPath)
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard elementKind == UICollectionView.elementKindSectionHeader,
              let col = collectionView else {
            return nil
        }
        let kind = UICollectionView.elementKindSectionHeader
        let attribute = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: kind, with: indexPath)
        attribute.frame = CGRect.init(x: sectionInset.left + col.contentOffset.x, y: sectionInset.top, width: 300, height: 60)
        attribute.zIndex = 999
        return attribute
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
