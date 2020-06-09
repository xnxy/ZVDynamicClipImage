//
//  ZVPanGestureRecognizer.m
//  ZVDynamicClipImage
//
//  Created by CNTP on 2020/6/9.
//  Copyright © 2020 CNTP. All rights reserved.
//

#import "ZVPanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface ZVPanGestureRecognizer()

@property (nonatomic, strong) UIView *targetView;

@end

@implementation ZVPanGestureRecognizer

-(instancetype)initWithTarget:(id)target action:(SEL)action inview:(UIView *)view {
    self = [super initWithTarget:target action:action];
    if(self) {
        self.targetView = view;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent*)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    self.beginPoint = [touch locationInView:self.targetView];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    self.movePoint = [touch locationInView:self.targetView];
}


@end
