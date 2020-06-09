//
//  ZVPanGestureRecognizer.h
//  ZVDynamicClipImage
//
//  Created by CNTP on 2020/6/9.
//  Copyright © 2020 CNTP. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZVPanGestureRecognizer : UIPanGestureRecognizer

@property(assign, nonatomic) CGPoint beginPoint;
@property(assign, nonatomic) CGPoint movePoint;

-(instancetype)initWithTarget:(id)target action:(SEL)action inview:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
