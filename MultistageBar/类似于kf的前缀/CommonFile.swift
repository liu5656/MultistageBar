//
//  CommonFile.swift
//  MultistageBar
//
//  Created by x on 2021/3/17.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit


public final class CommonFile<Base> {
    public let base: Base
    init(_ base: Base) {
        self.base = base
    }
}
public protocol CommonFileProtocol {

}
extension CommonFileProtocol {
    public var lj: CommonFile<Self> {
        return CommonFile.init(self)
    }
}

// 这样所有的UIview及其子类都可以调用lj
extension UIView: CommonFileProtocol {}

extension CommonFile where Base: UIView {
    func add(corner radius: CGFloat) {
        self.base.layer.cornerRadius = radius
    }
}
