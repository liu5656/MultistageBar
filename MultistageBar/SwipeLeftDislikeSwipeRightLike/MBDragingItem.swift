//
//  MBDragingItem.swift
//  MultistageBar
//
//  Created by x on 2021/2/5.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class MBDragingItem: UIView {
    
    lazy var imgIV: UIImageView = {
        let img = UIImageView.init()
        img.backgroundColor = UIColor.systemGray6
        img.frame = bounds
        img.isUserInteractionEnabled = true
        addSubview(img)
        return img
    }()
    lazy var titleL: UILabel = {
        let lab = UILabel.init(frame: bounds)
        lab.backgroundColor = UIColor.gray
        lab.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        lab.textAlignment = .center
        lab.textColor = UIColor.black
        lab.isUserInteractionEnabled = true
        addSubview(lab)
        return lab
    }()
    override func layoutSubviews() {
        super.layoutSubviews()
//        _ = imgIV
//        _ = titleL
    }
    deinit {
        MBLog("")
    }
}
