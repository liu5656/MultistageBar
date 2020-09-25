//
//  Screen.swift
//  MultistageBar
//
//  Created by x on 2020/9/25.
//  Copyright © 2020 x. All rights reserved.
//

import UIKit

struct Screen {
    static let bounds = UIScreen.main.bounds
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
    
    static let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    static let scale = min(Screen.width, Screen.height) / 375
    static let fakeSafeTop: CGFloat = UIScreen.main.bounds.size.height >= 812 ? 22 : 0
    static let fakeNavBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height + 44
    static let fakeSafeBottom: CGFloat = UIScreen.main.bounds.size.height >= 812 ? 34 : 0
    static let fakeTabBarHeight: CGFloat = fakeSafeBottom + 49
}
