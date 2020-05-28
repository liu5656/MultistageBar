//
//  DDLSegmentModel.swift
//  MultistageBar
//
//  Created by x on 2020/4/24.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

protocol DDLSegmentModelProtocol: AnyObject {
    var style: DDLSegmentItemProtocol? {set get}
    func ddl_size() -> CGSize
}

protocol DDLSegmentModelTitleProtocol: DDLSegmentModelProtocol {
    var name: String {set get}
}

class DDLSegmentModelTitle: DDLSegmentModelTitleProtocol {
    var style: DDLSegmentItemProtocol?
    
    var name: String = ""
    
    func ddl_size() -> CGSize {
        guard let style = style as? DDLSegmentItemTitle else {return .zero}
        let size = name.boundingRect(with: CGSize(width: Double.infinity, height: Double.infinity),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     attributes: [NSAttributedString.Key.font : style.normalFont],
                                     context: nil).size
        return CGSize.init(width: Int(size.width + style.ddl_widthPadding() * 2), height: Int(size.height + style.ddl_heightPadding() * 2))
    }
}
