//
//  MBSegmentModelTitle.swift
//  MultistageBar
//
//  Created by x on 2020/10/14.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class MBSegmentModelTitle: MBSegmentModelProtocol {
    var name: String = ""
    var badge: Int = 0 {
        didSet{
            var temp: CGRect = .zero
            let maxWidth: CGFloat = 30
            let minWidth: CGFloat = 16
            let height: CGFloat = 16
            if badge == 1 {
                temp = CGRect.init(x: mb_size().width - 8, y: 0, width: 8, height: 8)
            }else if badge > 1, badge <= 99 {
                let calculateWidth = "\(badge)".calculateText(size: CGSize.init(width: maxWidth, height: height), attr: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular)]).width
                let badgeWidth = min(max(minWidth, calculateWidth), maxWidth)
                temp = CGRect.init(x: mb_size().width - badgeWidth, y: 0, width: badgeWidth, height: height)
            }else if badge > 99 {
                temp = CGRect.init(x: mb_size().width - maxWidth, y: 0, width: maxWidth, height: height)
            }
            badgeFrame = temp
        }
    }
    var badgeFrame: CGRect = .zero
    
    init(style: MBSegmentModelStyleProtocol) {
        self.style = style
    }
    
    var style: MBSegmentModelStyleProtocol
    func mb_size() -> CGSize {
        guard let style = style as? MBSegmentModelTitleStyle else {return .zero}
        let size = name.boundingRect(with: CGSize(width: Double.infinity, height: Double.infinity),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     attributes: [NSAttributedString.Key.font : style.normalFont],
                                     context: nil).size
        return CGSize.init(width: Int(size.width + 15 * 2),
                           height: Int(size.height + 4 * 2))
    }
}
