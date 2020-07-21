//
//  DDLSegmentMenuView.swift
//  MultistageBar
//
//  Created by x on 2020/4/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

protocol DDLSegmentMenuViewDelegate: class {
    func ddl_didSelected(index: Int)
}

class DDLSegmentMenuView: UIView {
    
    func ddl_show(in content: UIView, contentFrame: CGRect) {
        if header != nil {
            horizontalScroll.frame = content.bounds
            content.addSubview(horizontalScroll)
            
            content.addSubview(header!)
            
            originalHeaderFrame = header!.frame
            originalBarFrame = self.frame
        }
        content.addSubview(self)
        if header == nil {
            horizontalScroll.frame = contentFrame
            content.addSubview(horizontalScroll)
        }
    }
    
    func ddl_slider(from: Int, to: Int, scale: CGFloat) {
        menuCV.ddl_slider(from: from, to: to, scale: scale)
    }
    
    //MARK: - utils
    private func ddl_maxWidth() -> CGFloat {
        var width: CGFloat = 0
        datasource.enumerated().forEach { (model) in
            width += model.element.ddl_size().width
            if model.offset != datasource.count - 1 {
                width += lineSpacing
            }
        }
        return min(maxWidth, width)
    }
    
    private func ddl_page(at index: Int) -> DDLSegmentContentItemProtocol {
        if let temp = contentItems[index] {
            return temp
        }else{
            return contentDatasource!.ddl_segmentContent(cellForItemAt: index)
        }
    }
    //判重后再决定是否添加
    private func ddl_willShow(at index: Int, item: DDLSegmentContentItemProtocol) {
        guard contentItems[index] == nil else {return}
        contentItems[index] = item
        let content = item.ddl_view()
        if header == nil {
            content.frame = CGRect.init(origin: CGPoint.init(x: CGFloat(index) * horizontalScroll.frame.width, y: 0), size: CGSize.init(width: horizontalScroll.frame.width, height: horizontalScroll.frame.height))
            horizontalScroll.addSubview(content)
        }else{
            let page: UIScrollView
            if (content as? UIScrollView) != nil {
                page = content as! UIScrollView
            }else{
                page = UIScrollView.init()
                page.frame = CGRect.init(origin: CGPoint.init(x: CGFloat(index) * horizontalScroll.frame.width, y: 0), size: horizontalScroll.frame.size)
                page.showsVerticalScrollIndicator = false
                page.showsHorizontalScrollIndicator = false
                
                page.contentSize = CGSize.init(width: content.frame.width, height: content.frame.height)
                page.addSubview(content)
            }
            page.contentInsetAdjustmentBehavior = .never
            horizontalScroll.addSubview(page)
            page.contentInset = UIEdgeInsets.init(top: originalTopOffset, left: 0, bottom: 0, right: 0)
            page.setContentOffset(CGPoint.init(x: 0, y: -frame.maxY), animated: false)
            page.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .new, context: nil)
        }
    }
    private func ddl_willShowAgain(at index: Int, item: DDLSegmentContentItemProtocol) {
        guard header != nil else {return}
        let content = item.ddl_view()
        guard let temp = (content as? UIScrollView) ?? (content.superview as? UIScrollView),
            temp.contentOffset.y != -frame.maxY else {return}
        temp.setContentOffset(CGPoint.init(x: 0, y: -frame.maxY), animated: false)
        print("\(-frame.maxY)")
    }
        
    //MARK: - lazy
    // step 2: 如果设置底部容器代理,就监听contentOffset为滑动做准备
    weak var contentDatasource : DDLSegmentContentDatasource? {
        didSet{
            horizontalScroll.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .new, context: nil)
        }
    }
    // menu
    weak var delegate: DDLSegmentMenuViewDelegate?
    var sectionInset: UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
    ///当内容不能铺满容器时的布局方式
    var isStretch: Bool = false
    var maxWidth: CGFloat = UIScreen.main.bounds.width
    var lineSpacing: CGFloat = 0
    var itemHeight: CGFloat = 40
    var contentRadius: CGFloat = 0
    var contentColor: UIColor?
    var selectedIndex: Int = 0
    
    var indicator: DDLSegmentIndicatorProtocol? {
        didSet{
            menuCV.indicator = indicator
        }
    }
    
    
    deinit {
        if header != nil {
            horizontalScroll.subviews.forEach { (view) in
                if view is UIScrollView {
                    view.removeObserver(self, forKeyPath: contentOffsetKeyPath)
                }
            }
        }
        if contentDatasource != nil {
            horizontalScroll.removeObserver(self, forKeyPath: contentOffsetKeyPath)            
        }
    }
    
    // header 只有一级菜单才有header,多级菜单要出问题
    var header: DDLSegmentHeader?
    private var originalHeaderFrame: CGRect = .zero
    private var originalBarFrame: CGRect = .zero
    private var originalTopOffset: CGFloat {
        get{
            return originalBarFrame.maxY
        }
    }
    var topOffset: CGFloat = 100
    var datasource: [DDLSegmentModelProtocol] = [] {
        didSet{
            let width = min(bounds.width, sectionInset.left + ddl_maxWidth() + sectionInset.right)
            menuCV.frame = CGRect.init(x: (bounds.size.width - width) * 0.5, y: (bounds.size.height - itemHeight) * 0.5, width: width, height: itemHeight)
            menuCV.paddingWidth = datasource.first?.style?.ddl_widthPadding() ?? 0
            datasource.first?.style?.ddl_registerCell(in: menuCV)
            menuCV.reloadData()
            // 更新contentsize
            guard let number = contentDatasource?.ddl_segmentContentNumber() else {return}
            horizontalScroll.contentSize = CGSize.init(width: horizontalScroll.frame.width * CGFloat(number), height: horizontalScroll.frame.height)
            guard contentItems.count == 0, datasource.count > 0 else {return}
            ddl_willShow(at: 0, item: ddl_page(at: 0))
        }
    }
    
    private let contentOffsetKeyPath = "contentOffset"
    // content
    private var lastContentOffset: CGPoint = .zero
    private var contentItems: [Int: DDLSegmentContentItemProtocol] = [:]
    private lazy var horizontalScroll: UIScrollView = {
        let scr = UIScrollView.init()
        scr.contentInsetAdjustmentBehavior = .never
        scr.isPagingEnabled = true
        scr.bounces = false
        scr.showsVerticalScrollIndicator = false
        scr.showsHorizontalScrollIndicator = false
        scr.scrollsToTop = false
        return scr
    }()
    private lazy var menuCV: DDLSegmentCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let col = DDLSegmentCollectionView.init(frame: .zero, collectionViewLayout: layout)
        col.showsVerticalScrollIndicator = false
        col.showsHorizontalScrollIndicator = false
        if contentRadius > 0, contentColor != nil{
            col.layer.cornerRadius = contentRadius
            col.layer.masksToBounds = true
            col.backgroundColor = contentColor
        }else{
            col.backgroundColor = .clear
        }
        col.scrollsToTop = false
        col.dataSource = self
        col.delegate = self
        addSubview(col)
        return col
    }()
    private func ddl_handleUpDown(offset: CGPoint, scrollView: UIScrollView) {
        guard header != nil else {return}
        let delta = originalTopOffset + offset.y
        if delta > 0 {
            header?.frame = CGRect.init(origin: CGPoint.init(x: 0, y: originalHeaderFrame.origin.y - min(delta, topOffset)), size: originalHeaderFrame.size)
            self.frame = CGRect.init(origin: CGPoint.init(x: 0, y: originalBarFrame.origin.y - min(delta, topOffset)), size: originalBarFrame.size)
        }else{
            header?.frame = CGRect.init(origin: CGPoint.init(x: 0, y: originalHeaderFrame.origin.y - max(delta, 0)), size: originalHeaderFrame.size)
            self.frame = CGRect.init(origin: CGPoint.init(x: 0, y: originalBarFrame.origin.y - max(delta, 0)), size: originalBarFrame.size)
        }
    }
    //MARK: - kvo
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == contentOffsetKeyPath, let currentOffset = change?[NSKeyValueChangeKey.newKey] as? CGPoint, let scroll = object as? UIScrollView else {return}
        guard scroll == horizontalScroll else {
            ddl_handleUpDown(offset: currentOffset, scrollView: scroll)
            return
        }
        defer {
            lastContentOffset = currentOffset
        }

        let multiple = currentOffset.x / horizontalScroll.frame.width
        let leftToRight = currentOffset.x > lastContentOffset.x
        let from = leftToRight ? floor(multiple) : ceil(multiple)
        let to = leftToRight ? from + 1 : from - 1
        let scale = (currentOffset.x - from * horizontalScroll.frame.width) / ((to - from) * horizontalScroll.frame.width)
        if scale > 0.1, contentItems[Int(to)] == nil { // 超过scroll宽度0.1就要准备数据
            ddl_willShow(at: Int(to), item: ddl_page(at: Int(to)))
        }else if scale > 0.1, header != nil {
            ddl_willShowAgain(at: Int(to), item: ddl_page(at: Int(to)))
        }
        // 滚动条变化
        guard from != to, scale != 0 else {return}
        menuCV.ddl_slider(from: Int(from), to: Int(to), scale: scale)
    }
}

//MARK: - UICollectionViewDataSource
extension DDLSegmentMenuView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = datasource[indexPath.row]
        guard let style = data.style else {return UICollectionViewCell()}
        let cell = style.ddl_cell(in: collectionView, for: indexPath)
        cell.ddl_update(model: data)
        cell.ddl_update(style: style)
        return cell as! UICollectionViewCell
    }
}

//MARK: - UICollectionViewDelegate
extension DDLSegmentMenuView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if contentDatasource != nil {
            
            horizontalScroll.setContentOffset(CGPoint.init(x: CGFloat(indexPath.row) * horizontalScroll.frame.width, y: 0), animated: false)
            menuCV.ddl_sliderClick(index: indexPath)
            
            if contentItems[indexPath.row] == nil {
                ddl_willShow(at: indexPath.row, item: ddl_page(at: indexPath.row))
            }
        }else{
            menuCV.ddl_slider(from: menuCV.lastIndex, to: indexPath.row, scale: 1)
        }
        delegate?.ddl_didSelected(index: indexPath.row)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension DDLSegmentMenuView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = datasource[indexPath.row].ddl_size()
        return CGSize.init(width: size.width, height: itemHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInset
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
}
