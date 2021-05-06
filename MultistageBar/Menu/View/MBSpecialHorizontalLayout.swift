//
//  MBSpecialHorizontalLayout.swift
//  MultistageBar
//
//  Created by x on 2021/4/28.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

/* 参考文章
 https://www.cnblogs.com/huanying2000/p/8515272.html            iOS 关于自定义UICollectionViewLayout实现复杂布局
 https://www.jianshu.com/p/c0d7023df00e/                        分区头悬浮固定
 https://segmentfault.com/q/1010000002934267                    UICollectionViewLayout中两个方法的疑惑
 
 https://www.jianshu.com/p/b3322f41e84c                         iOS 用UICollectionView实现各种神奇效果
 https://www.jianshu.com/p/97e930658671                         iOS: 玩转UICollectionViewLayout
 https://blog.csdn.net/u013410274/article/details/79925531      UICollectionView 的研究之二 ：自定义 UICollectionViewFlowLayout
 https://www.cnblogs.com/hissia/p/5723629.html                  自定义流水布局（UICollectionViewFlowLayout的基本使用）
 https://www.jianshu.com/p/5ee9333644ed                         UICollectionViewFlowLayout的自定义探究
 https://www.jianshu.com/p/c87fcabd1153                         横向布局且可左右分页滑动的UICollectionViewLayout
 https://www.jianshu.com/p/e8e9dcc12b37                         自定义UICollectionViewFlowLayout
 */

/* 调用流程
 override func prepare() 初始化操作,可以在此函数里创建所有的UICollectionViewLayoutAttributesd并初始化他们的frame,

 override var collectionViewContentSize: CGSize 通过重载get方法,获取collectionview的contentSize

 override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? 返回当前可视区域内的attributes,可在这实时对attribute处理(如位置/大小等)

 更新时,通过invalidateLayout()标记,标记后会在下一个loop时顺序调用上面的流程刷新视图
 */

protocol MBSpecialHorizontalLayoutDelegate: class {
    
    func layout(_: MBSpecialHorizontalLayout, headerIn section: Int) -> Bool
    
    // 横向滑动时:宽度无效,高度有效;竖向滑动:宽度有效,高度无效;
    func layout(_: MBSpecialHorizontalLayout, refreenceSizeForHeaderIn section: Int) -> CGSize
    
}

class MBSpecialHorizontalLayout: UICollectionViewLayout {
    var scrollDirection: UICollectionView.ScrollDirection = .horizontal
    var itemSize: CGSize = .zero
    var sectionInset: UIEdgeInsets = .zero
    var minimumLineSpacing: CGFloat = 10        // 行间距
    var minimumInteritemSpacing: CGFloat = 10
    
    weak var delegate: MBSpecialHorizontalLayoutDelegate?
    private var pageWidth: CGFloat = 0                                                      // inset.left + contnt + inset.right
    private var maxColumn: Int = 0                                                          // 一屏最多展示多少列
    private var itemAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]         // 保存所有的item的attribute
    private var supplementAttributes: [Int: UICollectionViewLayoutAttributes] = [:]         // 保存所有的supplement的attribute
    private var sectionsRect: [Int: CGRect] = [:]                                           // 保存每个分区的size,宽度:左边距 + 中间部分 + 右边距,高度:上边距 + 中间部分 + 下边距
    
    // 创建并初始化collectionView的所有内容(item,supplement,decornate)
    override func prepare() {
        super.prepare()
        guard let col = collectionView else {return}
        
        maxColumn = Int((col.bounds.width + minimumInteritemSpacing) / (itemSize.width + minimumInteritemSpacing))
        
        let sectionNum = col.numberOfSections
        
        var sectionBase: CGPoint = .zero                                                                  // section区域的左上角
        
        for section in 0..<sectionNum {
            
            pageWidth = sectionInset.left
                + itemSize.width * CGFloat(maxColumn)
                + CGFloat(maxColumn - 1) * minimumInteritemSpacing
                + sectionInset.right
            
            var contentbase = CGPoint.init(x: sectionBase.x + sectionInset.left, y: sectionInset.top)
            
            contentbase = prepareSupplementAttribute(at: section, base: contentbase)                    // 先添加supplement
            
            let itemNum = col.numberOfItems(inSection: section)
            
            let contentY = contentbase.y
            
            var page: CGFloat = itemNum > 0 ? 1 : 0                                                     // 初始化页数,
            
            for row in 0..<itemNum {
                
                let index = IndexPath.init(row: row, section: section)
                
                contentbase = prepareItemAttribute(at: index,                                           // 添加item
                                                   base: contentbase,
                                                   contentY: contentY,
                                                   allPage: &page)
            }
            
            let frame = CGRect.init(x: sectionBase.x, y: 0, width: page * pageWidth, height: col.bounds.height)
            
            sectionsRect[section] = frame
            
            sectionBase = CGPoint.init(x: frame.maxX, y: 0)                                             // base到下一个分区的左上角
        }
    }
    
    // 初始化supplement的frame,预设置的宽度无效,仅高度有效
    private func prepareSupplementAttribute(at section: Int, base: CGPoint) -> CGPoint {
        guard let temp = delegate?.layout(self, headerIn: section),
              temp == true,
              let height = delegate?.layout(self, refreenceSizeForHeaderIn: section).height else {
            return base
        }
        
        let kind = UICollectionView.elementKindSectionHeader
        
        let attribute: UICollectionViewLayoutAttributes
        if let temp = supplementAttributes[section] {
            attribute = temp
        }else{
            attribute = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: kind,
                                                              with: IndexPath.init(row: 0, section: section))
        }
        attribute.frame = CGRect.init(x: base.x,
                                      y: base.y,
                                      width: pageWidth - sectionInset.left - sectionInset.right,
                                      height: height)
        
        attribute.zIndex = 9                                                                              // 值越大,视图越靠前
        
        supplementAttributes[section] = attribute
        
        return CGPoint.init(x: base.x, y: attribute.frame.maxY)
    }
    
    // 初始化item的frame,由于item的位置是固定不变的,所以后面就不用再处理了
    // 如果内容超过一页,就增加page
    private func prepareItemAttribute(at index: IndexPath,
                                      base: CGPoint,
                                      contentY: CGFloat,
                                      allPage page: inout CGFloat) -> CGPoint {
        guard let bounds = collectionView?.bounds else {return base}
        
        var origin = base
        
        if 0 != index.row, 0 == index.row % maxColumn {                                                  // 换行,检查是否需要翻页
            
            if origin.y + itemSize.height + minimumLineSpacing > bounds.height {              // 翻页
            
                origin.x += (sectionInset.left + sectionInset.right - minimumInteritemSpacing)           // 加上分页的间距: left + right
                
                origin.y = contentY
                
                page += 1
                
            }else{                                                                                       // 仅仅换行
                
                origin.x -= (itemSize.width + minimumInteritemSpacing) * CGFloat(maxColumn)
                
                origin.y += itemSize.height + minimumLineSpacing
                
            }
        }
        let attribute = UICollectionViewLayoutAttributes.init(forCellWith: index)
        
        attribute.frame = CGRect.init(origin: origin, size: itemSize)
        
        itemAttributes[index] = attribute
        
        origin.x += itemSize.width + minimumInteritemSpacing                                                  // 指向下一个item
        
        return origin
    }
    
    // 动态修改supplement的位置,使它悬浮固定在分区左上角
    private func prepareSupplement(attribute: UICollectionViewLayoutAttributes) {
        guard let frame = sectionsRect[attribute.indexPath.section],
              let offsetX = collectionView?.contentOffset.x else {
            return
        }
        let size = attribute.frame.size
        let minX = frame.minX
        let maxX = frame.maxX - sectionInset.left - size.width - sectionInset.right
        
        var x: CGFloat = 0
        if offsetX <= minX {
            x = frame.minX + sectionInset.left
        }else if offsetX >= maxX {
            x = frame.maxX - size.width - sectionInset.right
        }else{
            x = offsetX + sectionInset.left
        }
        attribute.frame = CGRect.init(origin: CGPoint.init(x: x, y: frame.origin.y), size: size)
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

    // 返回和rect相交的attribute,
    // 由于item的位置不变,所以不用再处理;
    // supplement由于要悬浮固定在分区左上角,所以需要再处理一次
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var temp = itemAttributes.values.filter({$0.frame.intersects(rect)})                // 过滤item
        
        supplementAttributes.values.forEach(prepareSupplement(attribute:))                  // 对所有的supplement视图进行处理
        
        let supplement = supplementAttributes.values.filter({$0.frame.intersects(rect)})    // 过滤supplment
        
        temp.append(contentsOf: supplement)
 
        return temp
    }
    
    // 当边界发生变化,是否要刷新布局
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
