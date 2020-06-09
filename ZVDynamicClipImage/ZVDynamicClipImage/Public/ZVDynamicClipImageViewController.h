//
//  ZVDynamicClipImageViewController.h
//  ZVDynamicClipImage
//
//  Created by CNTP on 2020/6/9.
//  Copyright © 2020 CNTP. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZVDynamicClipImageViewController : UIViewController

@property (nonnull, nonatomic, strong) UIImage *clipImage; //需要裁剪的图片 必须设置

@property (nonatomic, strong) UIColor *backgroundColor;//页面底部背景色 默认黑色
@property (nonatomic, strong) UIColor *maskBackgroundColor;//遮罩背景色 默认黑色
@property (nonatomic, assign) CGFloat maskOpacity; //遮罩opacity 默认0.5

@property (nonatomic, strong) UIColor       *cropLineColor;//裁剪框线的颜色 默认白色
@property (nonatomic, assign) NSUInteger    cropLineWidth;//裁剪框线的宽度  默认2

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *confirmButton;

/**
 * @brief 展示页面返回裁剪图片
 * @param complete  裁剪图片
 */
- (void)showAndComplete:(void(^)(UIImage *image))complete;

@end

NS_ASSUME_NONNULL_END
