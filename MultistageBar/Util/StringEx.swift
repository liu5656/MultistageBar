//
//  StringEx.swift
//  MultistageBar
//
//  Created by x on 2020/10/14.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

extension String {
    func calculateText(size: CGSize, attr: [NSAttributedString.Key: Any], options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .truncatesLastVisibleLine]) -> CGSize {
        let size = self.boundingRect(with: size, options: options, attributes: attr, context: nil).size
        return size
    }
}
