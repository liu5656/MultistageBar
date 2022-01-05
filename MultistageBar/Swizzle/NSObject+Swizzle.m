//
//  NSObject+Swizzle.m
//  MultistageBar
//
//  Created by x on 2022/1/5.
//  Copyright © 2022 x. All rights reserved.
//

#import "NSObject+Swizzle.h"
#import <objc/runtime.h>


@implementation NSObject (Swizzle)

+ (BOOL)swizzleMethod:(SEL)originalSel withMethod:(SEL)targetSel {
    
    
    Method originalMethod = class_getInstanceMethod(self, originalSel);
        if (originalMethod == nil) {
            return NO;
        }

        Method targetMethod = class_getInstanceMethod(self, targetSel);
        if (targetMethod == nil) {
            return NO;
        }

        class_addMethod(self, originalSel, class_getMethodImplementation(self, originalSel), method_getTypeEncoding(originalMethod));
        class_addMethod(self, targetSel, class_getMethodImplementation(self, targetSel), method_getTypeEncoding(targetMethod));
        method_exchangeImplementations(class_getInstanceMethod(self, originalSel), class_getInstanceMethod(self, targetSel));

        return YES;
    
//    Method originMethod = class_getInstanceMethod(self, originalSel);
//    IMP originImp = class_getMethodImplementation(self, originalSel);
//    if (originMethod == nil) {
//        return  NO;
//    }
//
//    Method targetMethod = class_getInstanceMethod(self, targetSel);
//    IMP targetImp = class_getMethodImplementation(self, targetSel);
//    if (targetMethod == nil) {
//        return NO;
//    }
//
//    class_addMethod(self, originalSel, originImp, method_getTypeEncoding(originMethod));
//    class_addMethod(self, targetSel, targetImp, method_getTypeEncoding(targetMethod));
//
//    method_exchangeImplementations(originMethod, targetMethod);
//
//    return YES;
}

+ (BOOL)swizzleClassMethod:(SEL)originalSel withMethod:(SEL)targetSel {
    Class metaClass = object_getClass(self);
    return [metaClass swizzleMethod:originalSel withMethod:targetSel];
}

@end
