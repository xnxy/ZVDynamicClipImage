//
//  ZVShapeLayer.h
//  ZVDynamicClipImage
//
//  Created by CNTP on 2020/6/9.
//  Copyright © 2020 CNTP. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZVShapeLayer : CAShapeLayer

@property(assign, nonatomic) NSInteger cropAreaLeft;
@property(assign, nonatomic) NSInteger cropAreaTop;
@property(assign, nonatomic) NSInteger cropAreaRight;
@property(assign, nonatomic) NSInteger cropAreaBottom;

@property (nonatomic, assign) NSUInteger    cropLineWidth;
@property (nonatomic, assign) NSUInteger    cropLineShadow;
@property (nonatomic, strong) UIColor       *cropLineColor;

@end

NS_ASSUME_NONNULL_END
