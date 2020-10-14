//
//  DDLSegmentModelTitle.swift
//  MultistageBar
//
//  Created by x on 2020/10/14.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

class DDLSegmentModelTitle: DDLSegmentModelProtocol {
    var name: String = ""
    
    init(style: DDLSegmentModelStyleProtocol) {
        self.style = style
    }
    
    var style: DDLSegmentModelStyleProtocol
    func ddl_size() -> CGSize {
        guard let style = style as? DDLSegmentModelTitleStyle else {return .zero}
        let size = name.boundingRect(with: CGSize(width: Double.infinity, height: Double.infinity),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     attributes: [NSAttributedString.Key.font : style.normalFont],
                                     context: nil).size
        return CGSize.init(width: Int(size.width + 15 * 2),
                           height: Int(size.height + 4 * 2))
    }
}
