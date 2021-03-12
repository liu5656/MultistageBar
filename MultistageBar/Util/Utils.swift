//
//  Utils.swift
//  MultistageBar
//
//  Created by x on 2021/3/12.
//  Copyright © 2021 x. All rights reserved.
//

import UIKit

class Util {
    static func keyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene}).first?.windows
                .first(where: \.isKeyWindow)
        }else{
            return UIApplication.shared.keyWindow
        }
    }
    static func interfaceOrientation() -> UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene}).first?.interfaceOrientation ?? UIInterfaceOrientation.portrait
        }else{
            return UIApplication.shared.statusBarOrientation
        }
    }
}
