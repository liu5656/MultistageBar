//
//  MACropViewController.h
//  WeexDemo
//
//  Created by lj on 2019/3/1.
//  Copyright © 2019 taobao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MACropViewController;
@protocol MACropViewControllerDelegate <NSObject>
- (void)ma_cancle;
- (void)ma_cropImage:(UIImage *)image;

@end

@interface MACropViewController : UIViewController

@property(nonatomic,weak)id<MACropViewControllerDelegate>delegate;

/**
 裁剪的图片
 */
@property(nonatomic,strong)UIImage *image;

/**
 裁剪区域
 */
@property(nonatomic,assign)CGSize cropSize;


/**
 是否裁剪成圆形
 */
@property(nonatomic,assign)BOOL isRound;

@end


NS_ASSUME_NONNULL_END
