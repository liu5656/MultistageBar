//
//  RefreshComponent.swift
//  Voice
//
//  Created by lj on 2019/4/10.
//  Copyright © 2019 huofeng. All rights reserved.
//

import UIKit

enum RefreshState {
    case idle
    case pulling
    case releaseToRefresh
    case refreshing
    case noMore
}

class RefreshComponent: UIView{
    override func layoutSubviews() {
        super.layoutSubviews()
        MBLog(String.init(format: "%p", self))
        addObserver()
        if refreshImmediately {
            refreshImmediately = false
            state = .refreshing
        }
    }
    weak var scrollView: UIScrollView?
    var refreshImmediately = false
    var headerRefresh: Bool = false
    var isObserveing: Bool = false
    var handler:(() -> Void)?
    var triggerH: CGFloat = 50
    var lastOffsetY: CGFloat = 0
    private var originalInsets: UIEdgeInsets = .zero
    private var originalContentSize: CGSize = .zero
    var state: RefreshState = .idle {
        didSet{
            if state != oldValue {
                self.refreshStateDidChanged(to: self.state)
            }else{
            }
        }
    }
    private var ignoreObserving = false
    private let contentOffsetKeyPath = "contentOffset"
    private let contentSizeKeyPath = "contentSize"
    private let contentInsetKeyPath = "contentInset"
    func refreshStateDidChanged(to state: RefreshState) {
        guard let scroll = scrollView else {return}
        if state == .refreshing {
            // 此时设置inset的时候不能监听footer的contentinset
            self.scrollView?.refreshFooter?.ignoreObserving = true
            self.scrollView?.refreshHeader?.ignoreObserving = true
            var insets = scroll.contentInset
            if headerRefresh == true {
                insets.top = triggerH + scroll.contentInset.top
            }else{
                insets.bottom = triggerH + scroll.contentInset.bottom
            }
            if headerRefresh {
                // 方法二  不能自动下拉,动画返回,手动下拉有动画
                self.scrollView?.setContentOffset(CGPoint.init(x: 0, y: -insets.top), animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if state != .idle {
                        self.scrollView?.contentInset = insets
                    }
                }
            }else{
                // 原始方法
                UIView.animate(withDuration: 0.2) {
                    self.scrollView?.contentInset = insets
                }
            }
            // 方法一 自动下拉,动画返回,手动下拉无动画
//            self.scrollView?.contentInset = insets
//            self.scrollView?.setContentOffset(CGPoint.init(x: 0, y: -insets.top), animated: true)
            handler?()
        }else if state == .idle {
            // 原始
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollView?.contentInset = self.originalInsets
            }) { (_) in
                self.scrollView?.refreshFooter?.ignoreObserving = false
                self.scrollView?.refreshHeader?.ignoreObserving = false
            }
        }else if state == .noMore {
            self.scrollView?.contentInset = originalInsets
        }
    }
    func endRefreshing() {
        self.state = .idle
    }
    func contentSizeChanged(to size: CGSize) {}
}

extension RefreshComponent {
    fileprivate func addObserver() {
        if isObserveing == false, let temp = scrollView {
            isObserveing = true
            temp.addObserver(self, forKeyPath: contentOffsetKeyPath, options: [.initial, .new], context: nil)
            temp.addObserver(self, forKeyPath: contentSizeKeyPath, options: [.initial, .new], context: nil)
            temp.addObserver(self, forKeyPath: contentInsetKeyPath, options: [.initial, .new], context: nil)
            originalInsets = temp.contentInset
        }
    }
    fileprivate func removeObserver() {
        if let temp = scrollView {
            temp.removeObserver(self, forKeyPath: contentOffsetKeyPath)
            temp.removeObserver(self, forKeyPath: contentSizeKeyPath)
            temp.removeObserver(self, forKeyPath: contentInsetKeyPath)
        }
    }
    func handleDistant(_ distant: CGFloat) {
        if distant == 0 {
            state = .idle
        }else if distant > triggerH {
            if state != .releaseToRefresh, state != .refreshing {
                state = .releaseToRefresh
            }else if scrollView?.isDragging == false, state != .refreshing {
//                // 此时设置inset的时候不能监听footer的contentinset
//                self.scrollView?.refreshFooter?.ignoreObserving = true
//                self.scrollView?.refreshHeader?.ignoreObserving = true
                state = .refreshing
            }
        }else if distant < triggerH {
            if state != .pulling {
                state = .pulling
            }
        }
    }
   
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard self.ignoreObserving == false else {return}
        guard let offsetY = self.scrollView?.contentOffset.y else {return}
        if keyPath == contentInsetKeyPath, let newV = change?[NSKeyValueChangeKey.newKey] as? UIEdgeInsets {
            originalInsets = newV
        }else if keyPath == contentSizeKeyPath, let newV = change?[NSKeyValueChangeKey.newKey] as? CGSize, newV != originalContentSize{
            originalContentSize = newV
            contentSizeChanged(to: newV)
        }else if keyPath == contentOffsetKeyPath {
            if headerRefresh, let topy = scrollView?.contentInset.top, offsetY < -topy {
                let distant = abs(originalInsets.top + offsetY)
//                MBLog("1 -- \(offsetY) - \(distant)")
                handleDistant(distant)
            }else if headerRefresh == false, state != .noMore, offsetY > 0 {
                guard let sizeH = self.scrollView?.contentSize.height, let frameH = self.scrollView?.frame.height else {return}
                let realH = sizeH + originalInsets.bottom
                guard realH > frameH else {return}
                let distant = frameH + offsetY - realH
                MBLog("2 -- \(offsetY) - \(distant)")
                handleDistant(distant)
            }
        }
    }
}
