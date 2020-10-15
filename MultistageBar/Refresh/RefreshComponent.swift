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

protocol RefreshPortocol {
    var triggerH: CGFloat {set get}
    var view: UIView{get}
    func refreshStateDidChanged(to state: RefreshState)
}

class RefreshComponent: UIView{
    weak var scrollView: UIScrollView? {
        didSet{
            guard let temp = scrollView else {return}
            scrollView = temp
            originalInsets = temp.contentInset
            addObserver()
        }
    }
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
//                DispatchQueue.main.async {
                    self.refreshStateDidChanged(to: self.state)
//                }
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
            var insets = scroll.contentInset
            if headerRefresh == true {
                insets.top = triggerH + scroll.contentInset.top
            }else{
                insets.bottom = triggerH + scroll.contentInset.bottom
            }
            UIView.animate(withDuration: 0.2) {
                self.scrollView?.contentInset = insets
            }
            handler?()
        }else if state == .idle {
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
        if isObserveing == false, scrollView != nil {
            isObserveing = true
            scrollView?.addObserver(self, forKeyPath: contentOffsetKeyPath, options: [.initial, .new], context: nil)
            scrollView?.addObserver(self, forKeyPath: contentSizeKeyPath, options: [.initial, .new], context: nil)
            scrollView?.addObserver(self, forKeyPath: contentInsetKeyPath, options: [.initial, .new], context: nil)
        }
    }
    fileprivate func removeObserver() {
        scrollView?.removeObserver(self, forKeyPath: contentOffsetKeyPath)
        scrollView?.removeObserver(self, forKeyPath: contentSizeKeyPath)
    }
    func handleDistant(_ distant: CGFloat) {
        if distant == 0 {
            state = .idle
        }else if distant > triggerH {
            if state != .releaseToRefresh, state != .refreshing {
                state = .releaseToRefresh
            }else if scrollView?.isDragging == false, state != .refreshing {
                self.scrollView?.refreshFooter?.ignoreObserving = true  // 此时设置inset的时候不能监听footer的contentinset
                self.scrollView?.refreshHeader?.ignoreObserving = true
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
            if headerRefresh, offsetY < 0 {
                let distant = abs(originalInsets.top + offsetY)
                MBLog("1 -- \(offsetY) - \(distant)")
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

