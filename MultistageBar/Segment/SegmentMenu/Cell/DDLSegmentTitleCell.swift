//
//  DDLSegmentTitleCell.swift
//  MultistageBar
//
//  Created by x on 2020/10/14.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class DDLSegmentTitleCell: UICollectionViewCell, DDLSegmentCellProtocol {
    
    func ddl_willFocus(_ focus: Bool, scale: CGFloat) {
        guard let style = model?.style as? DDLSegmentModelTitleStyle else {return}
        let delta = (style.selectedFont.pointSize - style.normalFont.pointSize) * scale
        let temp: CGFloat
        if focus {
            temp = style.normalFont.pointSize + delta
            titleL.textColor = style.normalColor.transition(to: style.selectedColor, scale: scale)
        }else{
            temp = style.selectedFont.pointSize - delta
            titleL.textColor = style.selectedColor.transition(to: style.normalColor, scale: scale)
        }
        titleL.font = UIFont.systemFont(ofSize: temp, weight: .regular)
        setNeedsLayout()
    }
    
    func ddl_update(style: DDLSegmentModelStyleProtocol) {
        guard let style = style as? DDLSegmentModelTitleStyle else {return}
        titleL.font = style.normalFont
        titleL.textColor = style.normalColor
    }
    
    func ddl_update(model: DDLSegmentModelProtocol) {
        self.model = model
        guard let model = model as? DDLSegmentModelTitle else {return}
        titleL.text = model.name
        cornerMarkL.frame = model.badgeFrame
        
        if model.badge == 1 {
            cornerMarkL.layer.borderWidth = 0
            cornerMarkL.layer.cornerRadius = 4
        }else if model.badge > 1 {
            cornerMarkL.text = model.badge > 99 ? "99+" : "\(model.badge)"
            cornerMarkL.layer.cornerRadius = model.badgeFrame.height * 0.5
            cornerMarkL.layer.borderWidth = 2
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        if let temp = model.style {
//            let size = titleL.sizeThatFits(bounds.size)
//            titleL.frame.size = CGSize.init(width: size.width + temp.paddingWidth * 2, height: size.height + temp.paddingHeight * 2)
        if let size = model?.ddl_size() {
            titleL.frame.size = size
        }else{
            titleL.sizeToFit()
        }
        titleL.center = contentView.center
//        }
    }
    
    var model: DDLSegmentModelProtocol?
    lazy var titleL: UILabel = {
        let lab = UILabel.init()
        lab.textAlignment = .center
        contentView.addSubview(lab)
        return lab
    }()
    lazy var cornerMarkL: UILabel = {
        let lab = UILabel.init()
        lab.textAlignment = .center
        lab.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lab.textColor = UIColor.white
        lab.layer.backgroundColor = UIColor.red.cgColor
        lab.layer.cornerRadius = 8
        lab.layer.borderColor = UIColor.white.cgColor
        lab.layer.borderWidth = 2
        contentView.addSubview(lab)
        return lab
    }()
}

