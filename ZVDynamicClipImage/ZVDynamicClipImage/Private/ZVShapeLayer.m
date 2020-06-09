//
//  ZVShapeLayer.m
//  ZVDynamicClipImage
//
//  Created by CNTP on 2020/6/9.
//  Copyright © 2020 CNTP. All rights reserved.
//

#import "ZVShapeLayer.h"

@implementation ZVShapeLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        CGFloat space = 50.f;
        _cropLineWidth = 2.f;
        _cropLineColor = [UIColor whiteColor];
        _cropLineShadow = 2.f;

        _cropAreaLeft = space;
        _cropAreaTop = space;
        _cropAreaRight = [UIScreen mainScreen].bounds.size.width - space;
        _cropAreaBottom = space * 8;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx{
    UIGraphicsPushContext(ctx);

    CGContextSetStrokeColorWithColor(ctx, self.cropLineColor.CGColor);
    CGContextSetLineWidth(ctx, self.cropLineWidth);
    CGContextMoveToPoint(ctx, self.cropAreaLeft, self.cropAreaTop);
    CGContextAddLineToPoint(ctx, self.cropAreaLeft, self.cropAreaBottom);
    CGContextSetShadow(ctx, CGSizeMake(2, 0), 2.0);
    CGContextStrokePath(ctx);

    CGContextSetStrokeColorWithColor(ctx, self.cropLineColor.CGColor);
    CGContextSetLineWidth(ctx, self.cropLineWidth);
    CGContextMoveToPoint(ctx, self.cropAreaLeft, self.cropAreaTop);
    CGContextAddLineToPoint(ctx, self.cropAreaRight, self.cropAreaTop);
    CGContextSetShadow(ctx, CGSizeMake(0, 2), 2.0);
    CGContextStrokePath(ctx);

    CGContextSetStrokeColorWithColor(ctx, self.cropLineColor.CGColor);
    CGContextSetLineWidth(ctx, self.cropLineWidth);
    CGContextMoveToPoint(ctx, self.cropAreaRight, self.cropAreaTop);
    CGContextAddLineToPoint(ctx, self.cropAreaRight, self.cropAreaBottom);
    CGContextSetShadow(ctx, CGSizeMake(-2, 0), 2.0);
    CGContextStrokePath(ctx);

    CGContextSetStrokeColorWithColor(ctx, self.cropLineColor.CGColor);
    CGContextSetLineWidth(ctx, self.cropLineWidth);
    CGContextMoveToPoint(ctx, self.cropAreaLeft, self.cropAreaBottom);
    CGContextAddLineToPoint(ctx, self.cropAreaRight, self.cropAreaBottom);
    CGContextSetShadow(ctx, CGSizeMake(0, -2), 2.0);
    CGContextStrokePath(ctx);

    UIGraphicsPopContext();
}

- (void)setCropAreaLeft:(NSInteger)cropAreaLeft{
    _cropAreaLeft = cropAreaLeft;
    [self setNeedsDisplay];
}

- (void)setCropAreaTop:(NSInteger)cropAreaTop{
    _cropAreaTop = cropAreaTop;
    [self setNeedsDisplay];
}

- (void)setCropAreaRight:(NSInteger)cropAreaRight{
    _cropAreaRight = cropAreaRight;
    [self setNeedsDisplay];
}

- (void)setCropAreaBottom:(NSInteger)cropAreaBottom{
    _cropAreaBottom = cropAreaBottom;
    [self setNeedsDisplay];
}

- (void)setCropLineWidth:(NSUInteger)cropLineWidth{
    _cropLineWidth = cropLineWidth;
    [self setNeedsDisplay];
}

- (void)setCropLineColor:(UIColor *)cropLineColor{
    _cropLineColor = cropLineColor;
    [self setNeedsDisplay];
}

@end
