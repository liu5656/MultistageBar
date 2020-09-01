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
    weak var scrollView: UIScrollView?
    var isSlidesUp: Bool = false
    var isObserveing: Bool = false
    var handler:(() -> Void)?
    var triggerH: CGFloat = 50
    private var originalInsets: UIEdgeInsets = .zero
    private var originalContentSize: CGSize = .zero
    var state: RefreshState = .idle {
        didSet{
            if state != oldValue {
                DispatchQueue.main.async {
                    self.refreshStateDidChanged(to: self.state)
                }
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
            if isSlidesUp == true {
                insets.top = triggerH + scroll.contentInset.top
            }else{
                insets.bottom = triggerH + scroll.contentInset.bottom
            }
            UIView.animate(withDuration: 0.2) {
                self.scrollView?.contentInset = insets
            }
            handler?()
        }else if state == .idle {
            UIView.animate(withDuration: 0.3) {
                self.scrollView?.contentInset = self.originalInsets
            }
        }else if state == .noMore {
            self.scrollView?.contentInset = originalInsets
        }
    }
    override func didMoveToSuperview() {
        superview?.didMoveToSuperview()
        removeObserver()
        if let temp = superview as? UIScrollView {
            scrollView = temp
            originalInsets = scrollView?.contentInset ?? .zero
            addObserver()
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
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard ignoreObserving == false else {return}
        guard let offsetY = self.scrollView?.contentOffset.y else {return}
        if keyPath == contentInsetKeyPath, let newV = change?[NSKeyValueChangeKey.newKey] as? UIEdgeInsets, newV != .zero, originalInsets == .zero, state == .idle {
            originalInsets = newV
        }else if keyPath == contentSizeKeyPath, let newV = change?[NSKeyValueChangeKey.newKey] as? CGSize, newV != originalContentSize{
            originalContentSize = newV
            contentSizeChanged(to: newV)
        }else if keyPath == contentOffsetKeyPath {
            if offsetY < 0, isSlidesUp == true, state != .refreshing {
                if offsetY < -triggerH {
                    if scrollView?.isDragging == true, state != .releaseToRefresh { // 拖拽中,超过阀值
                        state = .releaseToRefresh
                    }else if  scrollView?.isDragging == false, state == .releaseToRefresh { // 超过阀值,然后释放
                        state = .refreshing
                    }
                }else if offsetY > -triggerH{
                    state = .pulling
                }else{
                    state = .idle
                }
            }else if isSlidesUp == false, state != .refreshing, state != .noMore{
                guard let sizeH = self.scrollView?.contentSize.height, let frameH = self.scrollView?.frame.height else {return}
                if sizeH > UIScreen.main.bounds.height {
                    if offsetY + frameH - sizeH > triggerH {
                        if scrollView?.isDragging == true {
                            state = .releaseToRefresh
                        }else{
                            state = .refreshing
                        }
                    }else if offsetY + frameH - sizeH > 0 {
                        state = .pulling
                    }else{
                        state = .idle
                    }
                }else{
                    if offsetY > triggerH / 2 {
                        if scrollView?.isDragging == true {
                            state = .releaseToRefresh
                        }else{
                            state = .refreshing
                        }
                    }else if offsetY > 0 {
                        state = .pulling
                    }else {
                        state = .idle
                    }
                }
            }
        }
    }
}

