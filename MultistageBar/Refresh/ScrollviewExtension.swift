//
//  ScrollviewExtension.swift
//  Voice
//
//  Created by lj on 2019/4/13.
//  Copyright © 2019 huofeng. All rights reserved.
//

import UIKit

private var refreshHeaderKey = "refreshHeaderKey"
private var refreshFooterKey = "refreshFooterKey"
func excuteInMainThread(handler: @escaping () -> Void) {
    DispatchQueue.main.async {
        handler()
    }
}
func GlobalThread(ExcuteHandler: @escaping () -> Void) {
    DispatchQueue.global().async {
        ExcuteHandler()
    }
}

enum RefreshType {
    case normal
    case refresh
    case loadMore
}

extension UIScrollView {
    func refreshHeader(refreshView header: RefreshComponent = RefreshNormalHeader(), handler: @escaping () -> Void) {
        self.contentInsetAdjustmentBehavior = .never
        header.tag = 1
        header.frame = CGRect.init(x: 0, y: -header.triggerH, width: UIScreen.main.bounds.width, height: header.triggerH)
        header.headerRefresh = true
        header.handler = handler
        refreshHeader = header
        self.addSubview(header)
        header.scrollView = self
    }
    func refreshFooter(refreshView footer: RefreshComponent = RefreshNormalFooter(), handler: @escaping () -> Void) {
        footer.tag = 2
        footer.frame = CGRect.init(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: footer.triggerH)
        footer.headerRefresh = false
        footer.handler = handler
        refreshFooter = footer
        self.addSubview(footer)
        footer.scrollView = self
    }
    func beginHeaderRefreshing() {
        guard refreshHeader != nil else {
            return
        }
        refreshHeader?.refreshImmediately = true
        MBLog("flat to refresh immediately")
        refreshHeader?.setNeedsLayout()
    }
    func endHeaderRefreshing() {
        excuteInMainThread {
            self.refreshHeader?.endRefreshing()
        }
    }
    
    func refreshFooterState() -> RefreshState {
        self.refreshFooter?.state ?? .idle
    }
    
    func endFooterRefreshing(hasMoreData: Bool) {
        excuteInMainThread {
            self.refreshFooter?.state = hasMoreData ? RefreshState.idle : RefreshState.noMore
        }
    }
    func removeRefreshHeader() {
        _ = refreshHeader?.subviews.map({$0.removeFromSuperview()})
        refreshHeader?.removeFromSuperview()
    }
    func removeRefreshFooter() {
        _ = refreshFooter?.subviews.map({$0.removeFromSuperview()})
        refreshFooter?.removeFromSuperview()
    }
    var refreshHeader: RefreshComponent? {
        get {
            return (objc_getAssociatedObject(self, &refreshHeaderKey) as? RefreshComponent)
        }
        set {
            objc_setAssociatedObject(self, &refreshHeaderKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var refreshFooter: RefreshComponent? {
        get {
            return (objc_getAssociatedObject(self, &refreshFooterKey) as? RefreshComponent)
        }
        set {
            objc_setAssociatedObject(self, &refreshFooterKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
