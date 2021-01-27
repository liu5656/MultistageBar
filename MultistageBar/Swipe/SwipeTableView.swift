//
//  SwipeTableView.swift
//  ypj
//
//  Created by x on 2019/10/9.
//  Copyright © 2019 x. All rights reserved.
//

import UIKit

protocol SwipeTableViewDelegate: class {
    func swipeTableView(_ tableView: UITableView, column: Int, didSelectIndexPath index: IndexPath)
    func swipeTableView(_ collectionView: UICollectionView, column: Int, didSelectIndexPath index: IndexPath)
    func swipeTableViewWillDisplay(column: Int)
    func swipeTableView(_ scrollView: UIScrollView, scroll direction: ScrollDirection)
    func swipeTableViewDidScroll(_ scrollView: UIScrollView)
    func swipeTableViewDidScroll(_ x: CGFloat, totalX: CGFloat, direction: ScrollDirection)
    func swipeTableViewDidScroll(_ from: Int, to: Int, scale: CGFloat)
    func swipeTableViewDidEndDecelerating(_ scrollView: UIScrollView)
    func swipeTableView(_ tableView: UITableView, column: Int, heightForRowAt index: IndexPath) -> CGFloat
    func swipeTableView(_ tableView: UITableView, column: Int, heightForHeaderInSection section: Int) -> CGFloat
}

enum ScrollDirection {
    case top
    case down
    case left
    case right
}

protocol SwipeTableViewDataSource: class {
    // 横向滑动数量和视图数据代理
    func swipeTableView(_ swipeTableView: SwipeTableView, mainColumnInSection section: Int) -> Int
    func swipeTableView(_ swipeTableView: SwipeTableView, columnIndexPath index: IndexPath) -> UIView
    // 横向滑动视图为UITableView的代理
    func swipeTableView(_ tableView: UITableView, column: Int, numberOfCellInSection section: Int) -> Int
    func swipeTableView(_ tableView: UITableView, column: Int, rowAtIndexPath index: IndexPath) -> UITableViewCell
    func swipeTableView(_ tableView: UITableView, column: Int, viewForHeaderInSection section: Int) -> UIView?
    
    // 横向滑动视图为UICollectionView的代理
    func swipeTableView(_ collectionView: UICollectionView, column: Int, numberOfItemInSection section: Int) -> Int
    func swipeTableView(_ collectionView: UICollectionView, column: Int, itemAtIndexPath index: IndexPath) -> UICollectionViewCell
}

class SwipeTableView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = swipeCV
        clipsToBounds = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("swipe table view deinit")
    }
    
    let collectionViewIdentify = "collectionViewIdentify"
    var headerView: UIView? {
        willSet{
            if let temp = newValue {
                originalHeaderFrame = temp.frame
                // 删除以前的
                addSubview(temp)
            }
        }
    }
    var headerBar: UIView? {
        willSet{
            if let temp = newValue {
                originalBarFrame = temp.frame
                // 删除以前的
                addSubview(temp)
            }
        }
    }
    
    var observerScroll = true
    // 词属性暂时无效
    var barTopInset: CGFloat = 0
    var originalBarFrame: CGRect = .zero
    var originalHeaderFrame: CGRect = .zero
    let mainContentTag = 200
    let subContentTag = 100
    var tempOffsetY: CGFloat = 0
    var lastHorizontalOffsetX: CGFloat = 0
    var currentScrollDirection = ScrollDirection.down
    
    var contentOffsetS: [Int: CGPoint] = [:]
    var contentViews: [Int: UIView] = [:]
    weak var delegate: SwipeTableViewDelegate?
    weak var datasource: SwipeTableViewDataSource?
    lazy var swipeCV: UICollectionView = {
        let c = UICollectionView.init(frame: self.bounds, collectionViewLayout: layout)
        c.showsHorizontalScrollIndicator = false
        c.showsVerticalScrollIndicator = false
        c.backgroundColor = .clear
        c.tag = mainContentTag
        c.delegate = self
        c.dataSource = self
        c.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: collectionViewIdentify)
        c.isPagingEnabled = true
        c.bounces = false
        addSubview(c)
        if #available(iOS 11.0, *) {
            c.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        return c
    }()
    lazy var layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout.init()
        l.scrollDirection = UICollectionView.ScrollDirection.horizontal
        l.itemSize = self.bounds.size
        l.minimumLineSpacing = 0
        l.minimumInteritemSpacing  = 0
        l.sectionInset = UIEdgeInsets.zero
        return l
    }()
}

extension SwipeTableView { // 更新部分
    func scrollviewToPage(_ page: Int, animated: Bool = true) {
        swipeCV.scrollToItem(at: IndexPath.init(row: page, section: 0), at: UICollectionView.ScrollPosition.right, animated: animated)
    }
    func reloadData(page: Int?) {
        if let page = page {
            if let temp = contentViews[page] as? UICollectionView {
                temp.reloadData()
            }else if let temp = contentViews[page] as? UITableView {
                temp.reloadData()
            }
        }else{
            contentViews.removeAll()
            swipeCV.reloadData()
        }
    }
    func barTop() -> CGFloat {
        return (headerBar?.frame.minY ?? 0) + barTopInset
    }
    func barBottom() -> CGFloat {
        return headerBar?.frame.maxY ?? headerView?.frame.maxY ?? 0
    }
    func headerAndBarMaxY() -> CGFloat {
        return max(originalHeaderFrame.maxY, originalBarFrame.maxY)
//        return 200
    }
    func scrollToTop() {
        if let index = swipeCV.indexPathsForVisibleItems.first?.row, let temp = contentViews[index] as? UIScrollView {
            temp.setContentOffset(CGPoint.init(x: 0, y: -headerAndBarMaxY()), animated: true)
        }
    }
}

extension SwipeTableView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.swipeTableView(collectionView, column: collectionView.tag - subContentTag, didSelectIndexPath: indexPath)
    }
}
extension SwipeTableView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if mainContentTag == collectionView.tag {
            return datasource?.swipeTableView(self, mainColumnInSection: section) ?? 0
        }else{
            return datasource?.swipeTableView(collectionView, column:collectionView.tag - subContentTag, numberOfItemInSection: section) ?? 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if mainContentTag == collectionView.tag {
            if let view = cell.viewWithTag(subContentTag + indexPath.row), let temp = view as? UIScrollView {
                if let offset = contentOffsetS[indexPath.row], offset.y > barBottom(), 0 == barTop() {
                    temp.setContentOffset(offset, animated: false)
                }else{
                    temp.setContentOffset(CGPoint.init(x: -temp.contentInset.left, y: -(barBottom())), animated: false)
                }
            }
            delegate?.swipeTableViewWillDisplay(column: indexPath.row)
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if mainContentTag == collectionView.tag {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewIdentify, for: indexPath)
            for view in cell.contentView.subviews {
                if subContentTag <= view.tag {
                    view.removeFromSuperview()
                }
            }
            if let content = contentViews[indexPath.row] {
                cell.contentView.addSubview(content)
            }else if let v = datasource?.swipeTableView(self, columnIndexPath: indexPath) {
                if let temp = v as? UIScrollView {
                    if #available(iOS 11.0, *) {
                        temp.contentInsetAdjustmentBehavior = .never
                    } else {
                        // Fallback on earlier versions
                    }
                    temp.tag = subContentTag + indexPath.row
                    observerScroll = false
                    temp.contentInset.top = headerAndBarMaxY()
                    temp.setContentOffset(CGPoint.init(x: 0, y: -(barBottom())), animated: false)
                    observerScroll = true
                    
                    temp.delegate = self
                    if let temp = v as? UITableView {
                        temp.dataSource = self
                    }
                    if let temp = v as? UICollectionView {
                        temp.dataSource = self
                    }
                }
                v.tag = subContentTag + indexPath.row
                v.frame = self.bounds
                cell.contentView.addSubview(v)
                contentViews[indexPath.row] = v
            }
            return cell
        }else{
            return datasource?.swipeTableView(collectionView, column: collectionView.tag - subContentTag, itemAtIndexPath: indexPath) ?? UICollectionViewCell()
        }
    }
}
extension SwipeTableView { // UIScrollView相关代理
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        calculateCurrentPageOffset(scrollView)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        calculateCurrentPageOffset(scrollView)
        delegate?.swipeTableViewDidEndDecelerating(scrollView)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.tag != mainContentTag {
            tempOffsetY = scrollView.contentOffset.y
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.tag != mainContentTag {
            if decelerate == false { // 手拿开时是否还在减速(已停止)
                calculateCurrentPageOffset(scrollView)
            }
            let direction: ScrollDirection = scrollView.contentOffset.y > tempOffsetY ? .top : .down
            if decelerate && direction != currentScrollDirection {
                currentScrollDirection = direction
                delegate?.swipeTableView(scrollView, scroll: direction)
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag != mainContentTag, observerScroll == true {
            let offsetY = scrollView.contentOffset.y
            if offsetY == -headerAndBarMaxY() {
                if offsetY != -barBottom() {
                    scrollView.setContentOffset(CGPoint.init(x: 0, y: -(barBottom())), animated: false)
                }
                return
            }
            let delta = min(headerAndBarMaxY() + offsetY, headerAndBarMaxY() - (barTopInset + originalBarFrame.height))
            delegate?.swipeTableViewDidScroll(scrollView)
            guard delta > 0 else {
                headerView?.frame = originalHeaderFrame
                headerBar?.frame = originalBarFrame
                return
            } // headerview或headerBar顶部紧贴设备
            headerView?.frame = CGRect.init(origin: CGPoint.init(x: originalHeaderFrame.minX, y: -delta), size: originalHeaderFrame.size)
            headerBar?.frame = CGRect.init(origin: CGPoint.init(x: originalBarFrame.minX, y: (headerView?.frame.maxY ?? 0) - barTopInset), size: originalBarFrame.size)
        }else if scrollView.tag == mainContentTag {
            let multiple = scrollView.contentOffset.x / scrollView.frame.width
            let direction: ScrollDirection = scrollView.contentOffset.x > lastHorizontalOffsetX ? .left : .right
            let from = direction == .left ? floor(multiple) : ceil(multiple)
            let to = direction == .left ? from + 1 : from - 1
            let scale = (scrollView.contentOffset.x - from * scrollView.frame.width) / ((to - from) * scrollView.frame.width)
            delegate?.swipeTableViewDidScroll(Int(from), to: Int(to), scale: scale)
            lastHorizontalOffsetX = scrollView.contentOffset.x
        }
    }
    func calculateCurrentPageOffset(_ scrollView: UIScrollView) {
        if scrollView != swipeCV {
            contentOffsetS[scrollView.tag - subContentTag] = scrollView.contentOffset
        }
    }
}

extension SwipeTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.swipeTableView(tableView, column: tableView.tag - subContentTag, didSelectIndexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return delegate?.swipeTableView(tableView, column: tableView.tag - subContentTag, heightForRowAt: indexPath) ?? tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return delegate?.swipeTableView(tableView, column: tableView.tag - subContentTag, heightForHeaderInSection: section) ?? .leastNormalMagnitude
    }
    
}
extension SwipeTableView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource?.swipeTableView(tableView, column: max(tableView.tag - subContentTag, 0), numberOfCellInSection: section) ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return datasource?.swipeTableView(tableView, column: tableView.tag - subContentTag, rowAtIndexPath: indexPath) ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return datasource?.swipeTableView(tableView, column: tableView.tag - subContentTag, viewForHeaderInSection: section)
    }
    
}

extension SwipeTableViewDataSource {
    func swipeTableView(_ tableView: UITableView, column: Int, numberOfCellInSection section: Int) -> Int {return 0}
    func swipeTableView(_ tableView: UITableView, column: Int, rowAtIndexPath index: IndexPath) -> UITableViewCell {return UITableViewCell.init()}
    func swipeTableView(_ tableView: UITableView, column: Int, viewForHeaderInSection section: Int) -> UIView?{ return nil }
    
    func swipeTableView(_ collectionView: UICollectionView, column: Int, numberOfItemInSection section: Int) -> Int {return 0}
    func swipeTableView(_ collectionView: UICollectionView, column: Int, itemAtIndexPath index: IndexPath) -> UICollectionViewCell {return UICollectionViewCell.init()}
    
}

extension SwipeTableViewDelegate {
    func swipeTableView(_ tableView: UITableView, column: Int, didSelectIndexPath index: IndexPath) {}
    func swipeTableView(_ collectionView: UICollectionView, column: Int, didSelectIndexPath index: IndexPath) {}
    func swipeTableViewWillDisplay(column: Int) {}
    func swipeTableView(_ scrollView: UIScrollView, scroll direction: ScrollDirection) {}
    func swipeTableViewDidScroll(_ scrollView: UIScrollView){}
    func swipeTableView(_ tableView: UITableView, column: Int, heightForRowAt index: IndexPath) -> CGFloat {return tableView.rowHeight}
    func swipeTableViewDidScroll(_ x: CGFloat, totalX: CGFloat, direction: ScrollDirection){}
    func swipeTableViewDidScroll(_ from: Int, to: Int, scale: CGFloat){}
    func swipeTableViewDidEndDecelerating(_ scrollView: UIScrollView){}
    func swipeTableView(_ tableView: UITableView, column: Int, heightForHeaderInSection section: Int) -> CGFloat{ return 0 }
}
