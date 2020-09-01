//
//  RefreshNormalFooter.swift
//  Voice
//
//  Created by lj on 2019/4/10.
//  Copyright © 2019 huofeng. All rights reserved.
//

import UIKit

class RefreshNormalFooter: RefreshComponent {
    override func layoutSubviews() {
        super.layoutSubviews()
        titleL.sizeToFit()
        titleL.center = CGPoint.init(x: self.frame.width / 2, y: self.frame.height / 2)
        indicator.center = .init(x: titleL.frame.origin.x - 16.0, y: titleL.center.y)
        arrowIV.center = CGPoint.init(x: indicator.center.x, y: titleL.center.y)
    }
    override func contentSizeChanged(to size: CGSize) {
        self.frame.origin.y = max(size.height, superview?.frame.height ?? 0)
    }
    override func refreshStateDidChanged(to state: RefreshState) {
        if state != RefreshState.noMore {
            super.refreshStateDidChanged(to: state)
        }
        switch state {
        case .idle, .pulling:
            titleL.text = "上拉刷新列表"
            indicator.isHidden = true
            arrowIV.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.arrowIV.transform = CGAffineTransform.identity
            }
        case .releaseToRefresh:
            titleL.text = "松开刷新列表"
            indicator.isHidden = true
            arrowIV.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.arrowIV.transform = CGAffineTransform(rotationAngle: 0.000001 - CGFloat(Double.pi))
            }
        case .refreshing:
            titleL.text = "正在刷新列表"
            indicator.isHidden = false
            arrowIV.isHidden = true
            indicator.startAnimating()
        case .noMore:
            titleL.text = "到底了，喵~"
            indicator.isHidden = true
            arrowIV.isHidden = true
        }
        setNeedsLayout()
    }
    lazy var titleL: UILabel = {
        let l = UILabel.init()
        l.font = UIFont.systemFont(ofSize: 14.0)
        l.textColor = UIColor.init(white: 0.625, alpha: 1.0)
        l.text = "上拉刷新列表"
        addSubview(l)
        return l
    }()
    lazy var arrowIV: UIImageView = {
        let iv = UIImageView.init()
        iv.image = UIImage.init(named: "refresh_arrow")
        iv.frame = CGRect.init(x: 0, y: 0, width: 18, height: 18)
        addSubview(iv)
        return iv
    }()
    lazy var indicator: UIActivityIndicatorView  = {
        let i = UIActivityIndicatorView.init(style: .gray)
        i.isHidden = true
        addSubview(i)
        return i
    }()
}
