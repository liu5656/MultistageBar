//
//  MBSpecialHorizontalLayout2.swift
//  MultistageBar
//
//  Created by x on 2021/4/28.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

protocol MBSpecialHorizontalLayoutDelegate: class {
    func layout(_: MBSpecialHorizontalLayout2, headerIn section: Int) -> Bool
    // 横向滑动时:宽度无效,高度有效;竖向滑动:宽度有效,高度无效;
    func layout(_: MBSpecialHorizontalLayout2, refreenceSizeForHeaderIn section: Int) -> CGSize
}

class MBSpecialHorizontalLayout2: UICollectionViewLayout {
    
    var attributes: [UICollectionViewLayoutAttributes] = []
    var scrollDirection: UICollectionView.ScrollDirection = .horizontal
    var itemSize: CGSize = .zero
    var sectionInset: UIEdgeInsets = .zero
    var minimumLineSpacing: CGFloat = 10
    var minimumInteritemSpacing: CGFloat = 10
    weak var delegate: MBSpecialHorizontalLayoutDelegate?
    
    var maxRows: Int = 0                                // 一屏最多展示多少行
    var maxColumn: Int = 0                              // 一屏最多展示多少列
    private var sectionsRect: [Int: CGRect] = [:]       // 保存每个分区的size,宽度:左边距 + 中间部分 + 右边距,高度:上边距 + 中间部分 + 下边距
    
    override func prepare() {
        super.prepare()
        guard let col = collectionView else {
            return
        }
        attributes.removeAll()
        maxRows = Int((col.bounds.height + minimumLineSpacing) / (itemSize.height + minimumLineSpacing))
        maxColumn = Int((col.bounds.width + minimumInteritemSpacing) / (itemSize.width + minimumInteritemSpacing))
        var offset: CGPoint = .zero                           // 每个分区偏移值x
        for section in 0..<col.numberOfSections {
            
            prepareSupplementAttribute(at: section, offset: &offset)
            let itemNum = col.numberOfItems(inSection: section)
            
            for row in 0..<itemNum {
                let index = IndexPath.init(row: row, section: section)
                var relateX: CGFloat = 0
                var relateY: CGFloat = 0
                prepareItemAttribute(at: index, base: offset, relateX: &relateX, relateY: &relateY)
                if row == (itemNum - 1) {
                    // 不足一屏,按照一屏计算
                    let (scene, _) = (row + 1).divided(maxRows * maxColumn)
                    // 分区宽度: 左边距 + 中间部分 + 右边距
                    let width = sectionInset.left + CGFloat(scene * maxColumn) * (itemSize.width + minimumInteritemSpacing) - minimumInteritemSpacing
                    sectionsRect[section] = CGRect.init(x: offset.x, y: sectionInset.top, width: width, height: col.bounds.height)
                    offset.x += width   // 每个section需要累加
                }
            }
        }
    }
    private func prepareSupplementAttribute(at section: Int, offset: inout CGPoint) {
        guard let temp = delegate?.layout(self, headerIn: section),
              temp == true,
              let height = delegate?.layout(self, refreenceSizeForHeaderIn: section).height else {
            return
        }
        let width = CGFloat(maxColumn) * (itemSize.width + minimumInteritemSpacing)
        
        let kind = UICollectionView.elementKindSectionHeader
        let attribute = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: kind, with: IndexPath.init(row: 0, section: section))
        attribute.frame = CGRect.init(x: sectionInset.left + offset.x, y: sectionInset.top, width: width, height: height)
        attribute.zIndex = 9
        offset.y = sectionInset.top + height    // 每个section需要重置
        attributes.append(attribute)
    }
    private func prepareItemAttribute(at index: IndexPath, base: CGPoint, relateX: inout CGFloat, relateY: inout CGFloat) {
        let attribute = UICollectionViewLayoutAttributes.init(forCellWith: index)
//        // 悬浮
//        let cellY = base.y
//            + sectionInset.top
//            + (itemSize.height + minimumLineSpacing) * CGFloat(index.row % maxColumn / maxColumn)
//        if cellY > relateY {
//            relateY = cellY
//        }else{  // 换页
//
//        }
//
//        let cellX = base.x
//            + sectionInset.left
//            + (itemSize.width + minimumInteritemSpacing) * CGFloat(index.row % maxColumn)
//        if cellX > relateX {
//            relateX = cellX
//        }else{ // 换行
//
//        }
//
        
        
        
        // 固定
        let row = index.row
        // 确定在当前分区的哪一屏的哪一行哪一列
        let scene = row / (maxRows * maxColumn)    // 哪一屏,0...
        let temp = row % (maxRows * maxColumn)
        let line = temp / maxColumn                // 哪一行,0...
        let column = temp % maxColumn              // 哪一列,0...
        let cellX = base.x + sectionInset.left + CGFloat(scene * maxColumn + column) * (itemSize.width + minimumInteritemSpacing)
        let cellY = sectionInset.top + CGFloat(line) * (itemSize.height + minimumLineSpacing)
        attribute.frame = CGRect.init(origin: CGPoint.init(x: cellX, y: cellY), size: itemSize)
        attributes.append(attribute)
    }
    private func prepareSupplement(attribute: UICollectionViewLayoutAttributes) {
        guard let frame = sectionsRect[attribute.indexPath.section],
              let offsetX = collectionView?.contentOffset.x else {
            return
        }
        let size = attribute.frame.size
        let minX = frame.minX + sectionInset.left
        let maxX = frame.maxX - size.width
        var x = minX
        if minX <= offsetX, offsetX < maxX {
            x = offsetX
        }else if offsetX >= maxX {
            x = maxX
        }
        attribute.frame = CGRect.init(origin: CGPoint.init(x: x, y: frame.origin.y), size: size)
        if 1 == attribute.indexPath.section {
            MBLog("\(attribute.indexPath.section)-\(attribute.frame.origin.x)-\(offsetX)")
        }
    }
    
    // 这里的尺寸是指的所有内容所占的尺寸
    override var collectionViewContentSize: CGSize {
        get{
            guard let col = collectionView else {
                return .zero
            }
            let width = sectionsRect.values.reduce(0, {$0 + $1.size.width})
            return CGSize.init(width: width, height: col.bounds.height)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // 相交过滤出要展示在rect范围内的attribute
        let temp = attributes.filter({$0.frame.intersects(rect)})
        let supplements = temp.filter({$0.representedElementCategory == UICollectionView.ElementCategory.supplementaryView})
//        supplements.forEach { (item) in
//            MBLog(item)
//        }
//        if supplements.count > 0 {
//            MBLog("\n\n\n")
//        }
        
        supplements.forEach(prepareSupplement(attribute:))
        return temp
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
