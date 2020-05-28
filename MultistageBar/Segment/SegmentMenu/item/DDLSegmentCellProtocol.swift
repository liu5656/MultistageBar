//
//  DDLSegmentCellProtocol.swift
//  MultistageBar
//
//  Created by x on 2020/4/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

protocol DDLSegmentCellProtocol: AnyObject {
    func ddl_update(model: DDLSegmentModelProtocol)
    func ddl_update(style: DDLSegmentItemProtocol)
    func ddl_willFocus(_ focus: Bool, scale: CGFloat)
}

class DDLSegmentTitleCell: UICollectionViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let temp = model.style {
            let size = titleL.sizeThatFits(bounds.size)
            titleL.frame.size = CGSize.init(width: size.width + temp.ddl_widthPadding() * 2, height: size.height + temp.ddl_heightPadding() * 2)
            titleL.center = contentView.center
        }
    }
    
    var model: DDLSegmentModelProtocol!
    lazy var titleL: UILabel = {
        let lab = UILabel.init()
        lab.textAlignment = .center
        contentView.addSubview(lab)
        return lab
    }()
}

extension DDLSegmentTitleCell: DDLSegmentCellProtocol {
    
    func ddl_willFocus(_ focus: Bool, scale: CGFloat) {
        guard let style = model?.style as? DDLSegmentItemTitle else {return}
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
    
    func ddl_update(style: DDLSegmentItemProtocol) {
        guard let style = style as? DDLSegmentItemTitle else {return}
        titleL.font = style.normalFont
        titleL.textColor = style.normalColor
    }
    
    func ddl_update(model: DDLSegmentModelProtocol) {
        self.model = model
        guard let model = model as? DDLSegmentModelTitleProtocol else {return}
        titleL.text = model.name
    }
}
