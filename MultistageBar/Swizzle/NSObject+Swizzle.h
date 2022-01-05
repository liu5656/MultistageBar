//
//  NSObject+Swizzle.h
//  MultistageBar
//
//  Created by x on 2022/1/5.
//  Copyright © 2022 x. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Swizzle)

+ (BOOL)swizzleMethod:(SEL)originalSel withMethod:(SEL)targetSel;
+ (BOOL)swizzleClassMethod:(SEL)originalSel withMethod:(SEL)targetSel;

@end

NS_ASSUME_NONNULL_END
