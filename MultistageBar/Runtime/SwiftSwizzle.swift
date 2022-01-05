//
//  SwiftSwizzle.swift
//  MultistageBar
//
//  Created by x on 2022/1/5.
//  Copyright © 2022 x. All rights reserved.
//

import Foundation

extension NSObject {

    class func swizzle(originalSel: Selector, targetSel: Selector) -> Bool {
        let originMethod = class_getInstanceMethod(self, originalSel)
        let originImp = class_getMethodImplementation(self, originalSel)
        guard let oMethod = originMethod, let oImp = originImp else {
            return false
        }
        let originalType = method_getTypeEncoding(oMethod)



        let targetMethod = class_getInstanceMethod(self, targetSel)
        let targetImp = class_getMethodImplementation(self, targetSel)
        guard let tMethod = targetMethod, let tImp = targetImp else {
            return false
        }
        let targetType = method_getTypeEncoding(tMethod)

        guard let oType = originalType, let tType = targetType else {
            return false
        }

        class_addMethod(self, originalSel, oImp, oType)
        class_addMethod(self, targetSel, tImp, tType)
        
        method_exchangeImplementations(oMethod, tMethod)
        
        return true
    }

    class func swizzleClass(originalSel: Selector, targetSel: Selector) -> Bool {
        guard let obj = object_getClass(self) as? NSObject.Type else {
            return false
        }
        return obj.swizzleClass(originalSel: originalSel, targetSel: targetSel)
    }

}
