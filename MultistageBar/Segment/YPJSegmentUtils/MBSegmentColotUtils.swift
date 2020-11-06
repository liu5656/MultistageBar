//
//  File.swift
//  MultistageBar
//
//  Created by x on 2020/4/27.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

extension UIColor {
    enum Component: Int, CaseIterable {
        case red = 0
        case green
        case blue
//        case alpha
    }
    func component(type: Component) -> CGFloat {
        guard cgColor.numberOfComponents > type.rawValue else {return 0}
        return self.cgColor.components?[type.rawValue] ?? 0
    }
    func transition(to: UIColor, scale: CGFloat) -> UIColor {
        var tempComponent: [CGFloat] = []
        Component.allCases.forEach { (type) in
            let tempFrom = self.component(type: type)
            let tempTo = to.component(type: type)
            let result = tempFrom + (tempTo - tempFrom) * scale
            tempComponent.append(max(0, min(result, 1)))
        }
        return UIColor.init(red: tempComponent[0], green: tempComponent[1], blue: tempComponent[2], alpha: 1)
    }
}
