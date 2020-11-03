//
//  ZVDynamicClipImageViewController.m
//  ZVDynamicClipImage
//
//  Created by CNTP on 2020/6/9.
//  Copyright © 2020 CNTP. All rights reserved.
//

#import "ZVDynamicClipImageViewController.h"
#import "ZVShapeLayer.h"
#import "ZVPanGestureRecognizer.h"

typedef NS_ENUM(NSInteger, ZVAcitveGestureViewType) {
    ZVAcitveGestureViewTypeLeft     = 0,
    ZVAcitveGestureViewTypeRight    = 2,
    ZVAcitveGestureViewTypeTop      = 3,
    ZVAcitveGestureViewTypeBottom   = 4,
    ZVAcitveGestureViewTypeView     = 5,
};

typedef void(^ZVDynamicClipImageComplete)(UIImage *image);

@interface ZVDynamicClipImageViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *cropView;
@property (nonatomic, assign) ZVAcitveGestureViewType gestureViewType;
@property (nonatomic, assign) CGRect originalFrame; //图片view 原始frame
//裁剪区域属性
@property (nonatomic, assign) CGFloat cropAreaX;
@property (nonatomic, assign) CGFloat cropAreaY;
@property (nonatomic, assign) CGFloat cropAreaWidth;
@property (nonatomic, assign) CGFloat cropAreaHeight;

@property (nonatomic, assign) CGFloat clipHeight;
@property (nonatomic, assign) CGFloat clipWidth;

@property (nonatomic, copy) ZVDynamicClipImageComplete dynamicClipImageComplete;

@end

@implementation ZVDynamicClipImageViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)showAndComplete:(void(^)(UIImage *image))complete {
    UIViewController *vc = [[UIApplication sharedApplication].windows lastObject].rootViewController;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [vc presentViewController:self animated:YES completion:nil];
    self.dynamicClipImageComplete = complete;
}

- (void)dismissWithCompletion:(void(^)(void))completion{
    [self dismissViewControllerAnimated:YES completion:completion];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.backgroundColor;
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.cropView];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.confirmButton];

    CGFloat tempWidth = 0.0;
    CGFloat tempHeight = 0.0;

    self.clipWidth = CGRectGetWidth(self.view.frame);
    self.clipHeight = self.clipWidth * 9/16;

    self.cropAreaX = (CGRectGetWidth(self.view.frame) - self.clipWidth)/2;
    self.cropAreaY = (CGRectGetHeight(self.view.frame) - self.clipHeight)/2;
    self.cropAreaWidth = self.clipWidth;
    self.cropAreaHeight = self.clipHeight;
    self.imageView.image = self.clipImage;

    if (self.clipImage.size.width/self.cropAreaWidth <= self.clipImage.size.height/self.cropAreaHeight) {
        tempWidth = self.cropAreaWidth;
        tempHeight = (tempWidth/self.clipImage.size.width) * self.clipImage.size.height;
    } else if (self.clipImage.size.width/self.cropAreaWidth > self.clipImage.size.height/self.cropAreaHeight) {
        tempHeight = self.cropAreaHeight;
        tempWidth = (tempHeight/self.clipImage.size.height) * self.clipImage.size.width;
    }
    self.imageView.frame = CGRectMake(self.cropAreaX - (tempWidth - self.cropAreaWidth)/2, self.cropAreaY - (tempHeight - self.cropAreaHeight)/2, tempWidth, tempHeight);
    self.originalFrame = CGRectMake(self.cropAreaX - (tempWidth - self.cropAreaWidth)/2, self.cropAreaY - (tempHeight - self.cropAreaHeight)/2, tempWidth, tempHeight);
    [self addAllGesture];
    [self setUpCropLayer];

    [self.backButton addTarget:self
                        action:@selector(backButtonAction:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.confirmButton addTarget:self
                           action:@selector(confirmButtonAction:)
                 forControlEvents:UIControlEventTouchUpInside];
}

-(void)addAllGesture {
    // 捏合手势
    UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleCenterPinGesture:)];
    [self.view addGestureRecognizer:pinGesture];

    // 拖动手势
    ZVPanGestureRecognizer *panGesture = [[ZVPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleDynamicPanGesture:)
                                                                                 inview:self.cropView];
    [self.cropView addGestureRecognizer:panGesture];
}

-(void)handleDynamicPanGesture:(ZVPanGestureRecognizer *)panGesture
{
    UIView * view = self.imageView;
    CGPoint translation = [panGesture translationInView:view.superview];

    CGPoint beginPoint = panGesture.beginPoint;
    CGPoint movePoint = panGesture.movePoint;
    CGFloat judgeWidth = 20;

    // 开始滑动时判断滑动对象是 ImageView 还是 Layer 上的 Line
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (beginPoint.x >= self.cropAreaX - judgeWidth && beginPoint.x <= self.cropAreaX + judgeWidth && beginPoint.y >= self.cropAreaY && beginPoint.y <= self.cropAreaY + self.cropAreaHeight && self.cropAreaWidth >= 50) {
            self.gestureViewType = ZVAcitveGestureViewTypeLeft;
        } else if (beginPoint.x >= self.cropAreaX + self.cropAreaWidth - judgeWidth && beginPoint.x <= self.cropAreaX + self.cropAreaWidth + judgeWidth && beginPoint.y >= self.cropAreaY && beginPoint.y <= self.cropAreaY + self.cropAreaHeight &&  self.cropAreaWidth >= 50) {
            self.gestureViewType = ZVAcitveGestureViewTypeRight;
        } else if (beginPoint.y >= self.cropAreaY - judgeWidth && beginPoint.y <= self.cropAreaY + judgeWidth && beginPoint.x >= self.cropAreaX && beginPoint.x <= self.cropAreaX + self.cropAreaWidth && self.cropAreaHeight >= 50) {
            self.gestureViewType = ZVAcitveGestureViewTypeTop;
        } else if (beginPoint.y >= self.cropAreaY + self.cropAreaHeight - judgeWidth && beginPoint.y <= self.cropAreaY + self.cropAreaHeight + judgeWidth && beginPoint.x >= self.cropAreaX && beginPoint.x <= self.cropAreaX + self.cropAreaWidth && self.cropAreaHeight >= 50) {
            self.gestureViewType = ZVAcitveGestureViewTypeBottom;
        } else {
            self.gestureViewType = ZVAcitveGestureViewTypeView;
            [view setCenter:CGPointMake(view.center.x + translation.x, view.center.y + translation.y)];
            [panGesture setTranslation:CGPointZero inView:view.superview];
        }
    }

    // 滑动过程中进行位置改变
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGFloat diff = 0;
        switch (self.gestureViewType) {
            case ZVAcitveGestureViewTypeLeft: {
                diff = movePoint.x - self.cropAreaX;
                if (diff >= 0 && self.cropAreaWidth > 50) {
                    self.cropAreaWidth -= diff;
                    self.cropAreaX += diff;
                } else if (diff < 0 && self.cropAreaX > self.imageView.frame.origin.x && self.cropAreaX >= 15) {
                    self.cropAreaWidth -= diff;
                    self.cropAreaX += diff;
                }
                [self setUpCropLayer];
                break;
            }
            case ZVAcitveGestureViewTypeRight: {
                diff = movePoint.x - self.cropAreaX - self.cropAreaWidth;
                if (diff >= 0 && (self.cropAreaX + self.cropAreaWidth) < MIN(self.imageView.frame.origin.x + self.imageView.frame.size.width, self.cropView.frame.origin.x + self.cropView.frame.size.width - 15)){
                    self.cropAreaWidth += diff;
                } else if (diff < 0 && self.cropAreaWidth >= 50) {
                    self.cropAreaWidth += diff;
                }
                [self setUpCropLayer];
                break;
            }
            case ZVAcitveGestureViewTypeTop: {
                diff = movePoint.y - self.cropAreaY;
                if (diff >= 0 && self.cropAreaHeight > 50) {
                    self.cropAreaHeight -= diff;
                    self.cropAreaY += diff;
                } else if (diff < 0 && self.cropAreaY > self.imageView.frame.origin.y && self.cropAreaY >= 15) {
                    self.cropAreaHeight -= diff;
                    self.cropAreaY += diff;
                }
                [self setUpCropLayer];
                break;
            }
            case ZVAcitveGestureViewTypeBottom: {
                diff = movePoint.y - self.cropAreaY - self.cropAreaHeight;
                if (diff >= 0 && (self.cropAreaY + self.cropAreaHeight) < MIN(self.imageView.frame.origin.y + self.imageView.frame.size.height, self.cropView.frame.origin.y + self.cropView.frame.size.height - 15)){
                    self.cropAreaHeight += diff;
                } else if (diff < 0 && self.cropAreaHeight >= 50) {
                    self.cropAreaHeight += diff;
                }
                [self setUpCropLayer];
                break;
            }
            case ZVAcitveGestureViewTypeView: {
                [view setCenter:CGPointMake(view.center.x + translation.x, view.center.y + translation.y)];
                [panGesture setTranslation:CGPointZero inView:view.superview];
                break;
            }
            default:
                break;
        }
    }

    // 滑动结束后进行位置修正
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        switch (self.gestureViewType) {
            case ZVAcitveGestureViewTypeLeft: {
                if (self.cropAreaWidth < 50) {
                    self.cropAreaX -= 50 - self.cropAreaWidth;
                    self.cropAreaWidth = 50;
                }
                if (self.cropAreaX < MAX(self.imageView.frame.origin.x, 15)) {
                    CGFloat temp = self.cropAreaX + self.cropAreaWidth;
                    self.cropAreaX = MAX(self.imageView.frame.origin.x, 15);
                    self.cropAreaWidth = temp - self.cropAreaX;
                }
                [self setUpCropLayer];
                break;
            }
            case ZVAcitveGestureViewTypeRight: {
                if (self.cropAreaWidth < 50) {
                    self.cropAreaWidth = 50;
                }
                if (self.cropAreaX + self.cropAreaWidth > MIN(self.imageView.frame.origin.x + self.imageView.frame.size.width, self.cropView.frame.origin.x + self.cropView.frame.size.width - 15)) {
                    self.cropAreaWidth = MIN(self.imageView.frame.origin.x + self.imageView.frame.size.width, self.cropView.frame.origin.x + self.cropView.frame.size.width - 15) - self.cropAreaX;
                }
                [self setUpCropLayer];
                break;
            }
            case ZVAcitveGestureViewTypeTop: {
                if (self.cropAreaHeight < 50) {
                    self.cropAreaY -= 50 - self.cropAreaHeight;
                    self.cropAreaHeight = 50;
                }
                if (self.cropAreaY < MAX(self.imageView.frame.origin.y, 15)) {
                    CGFloat temp = self.cropAreaY + self.cropAreaHeight;
                    self.cropAreaY = MAX(self.imageView.frame.origin.y, 15);
                    self.cropAreaHeight = temp - self.cropAreaY;
                }
                [self setUpCropLayer];
                break;
            }
            case ZVAcitveGestureViewTypeBottom: {
                if (self.cropAreaHeight < 50) {
                    self.cropAreaHeight = 50;
                }
                if (self.cropAreaY + self.cropAreaHeight > MIN(self.imageView.frame.origin.y + self.imageView.frame.size.height, self.cropView.frame.origin.y + self.cropView.frame.size.height - 15)) {
                    self.cropAreaHeight = MIN(self.imageView.frame.origin.y + self.imageView.frame.size.height, self.cropView.frame.origin.y + self.cropView.frame.size.height - 15) - self.cropAreaY;
                }
                [self setUpCropLayer];
                break;
            }
            case ZVAcitveGestureViewTypeView: {
                CGRect currentFrame = view.frame;

                if (currentFrame.origin.x >= self.cropAreaX) {
                    currentFrame.origin.x = self.cropAreaX;

                }
                if (currentFrame.origin.y >= self.cropAreaY) {
                    currentFrame.origin.y = self.cropAreaY;
                }
                if (currentFrame.size.width + currentFrame.origin.x < self.cropAreaX + self.cropAreaWidth) {
                    CGFloat movedLeftX = fabs(currentFrame.size.width + currentFrame.origin.x - (self.cropAreaX + self.cropAreaWidth));
                    currentFrame.origin.x += movedLeftX;
                }
                if (currentFrame.size.height + currentFrame.origin.y < self.cropAreaY + self.cropAreaHeight) {
                    CGFloat moveUpY = fabs(currentFrame.size.height + currentFrame.origin.y - (self.cropAreaY + self.cropAreaHeight));
                    currentFrame.origin.y += moveUpY;
                }
                [UIView animateWithDuration:0.3 animations:^{
                    [view setFrame:currentFrame];
                }];
                break;
            }
            default:
                break;
        }
    }
}

-(void)handleCenterPinGesture:(UIPinchGestureRecognizer *)pinGesture
{
    CGFloat scaleRation = 3;
    UIView * view = self.imageView;

    // 缩放开始与缩放中
    if (pinGesture.state == UIGestureRecognizerStateBegan || pinGesture.state == UIGestureRecognizerStateChanged) {
        // 移动缩放中心到手指中心
        CGPoint pinchCenter = [pinGesture locationInView:view.superview];
        CGFloat distanceX = view.frame.origin.x - pinchCenter.x;
        CGFloat distanceY = view.frame.origin.y - pinchCenter.y;
        CGFloat scaledDistanceX = distanceX * pinGesture.scale;
        CGFloat scaledDistanceY = distanceY * pinGesture.scale;
        CGRect newFrame = CGRectMake(view.frame.origin.x + scaledDistanceX - distanceX, view.frame.origin.y + scaledDistanceY - distanceY, view.frame.size.width * pinGesture.scale, view.frame.size.height * pinGesture.scale);
        view.frame = newFrame;
        pinGesture.scale = 1;
    }

    // 缩放结束
    if (pinGesture.state == UIGestureRecognizerStateEnded) {
        CGFloat ration =  view.frame.size.width / self.originalFrame.size.width;

        // 缩放过大
        if (ration > 5) {
            CGRect newFrame = CGRectMake(0, 0, self.originalFrame.size.width * scaleRation, self.originalFrame.size.height * scaleRation);
            view.frame = newFrame;
        }

        // 缩放过小
        if (ration < 0.25) {
            view.frame = self.originalFrame;
        }
        // 对图片进行位置修正
        CGRect resetPosition = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);

        if (resetPosition.origin.x >= self.cropAreaX) {
            resetPosition.origin.x = self.cropAreaX;
        }
        if (resetPosition.origin.y >= self.cropAreaY) {
            resetPosition.origin.y = self.cropAreaY;
        }
        if (resetPosition.size.width + resetPosition.origin.x < self.cropAreaX + self.cropAreaWidth) {
            CGFloat movedLeftX = fabs(resetPosition.size.width + resetPosition.origin.x - (self.cropAreaX + self.cropAreaWidth));
            resetPosition.origin.x += movedLeftX;
        }
        if (resetPosition.size.height + resetPosition.origin.y < self.cropAreaY + self.cropAreaHeight) {
            CGFloat moveUpY = fabs(resetPosition.size.height + resetPosition.origin.y - (self.cropAreaY + self.cropAreaHeight));
            resetPosition.origin.y += moveUpY;
        }
        view.frame = resetPosition;

        // 对图片缩放进行比例修正，防止过小
        if (self.cropAreaX < self.imageView.frame.origin.x
            || ((self.cropAreaX + self.cropAreaWidth) > self.imageView.frame.origin.x + self.imageView.frame.size.width)
            || self.cropAreaY < self.imageView.frame.origin.y
            || ((self.cropAreaY + self.cropAreaHeight) > self.imageView.frame.origin.y + self.imageView.frame.size.height)) {
            view.frame = self.originalFrame;
        }
    }
}

// 裁剪图片并调用返回Block
- (UIImage *)cropImage{
    CGFloat imageScale = MIN(self.imageView.frame.size.width/self.clipImage.size.width, self.imageView.frame.size.height/self.clipImage.size.height);
    CGFloat cropX = (self.cropAreaX - self.imageView.frame.origin.x)/imageScale;
    CGFloat cropY = (self.cropAreaY - self.imageView.frame.origin.y)/imageScale;
    CGFloat cropWidth = self.cropAreaWidth/imageScale;
    CGFloat cropHeight = self.cropAreaHeight/imageScale;
    CGRect cropRect = CGRectMake(cropX, cropY, cropWidth, cropHeight);

    CGImageRef sourceImageRef = [self.clipImage CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, cropRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}

- (void)setUpCropLayer
{
    self.cropView.layer.sublayers = nil;
    ZVShapeLayer * layer = [[ZVShapeLayer alloc] init];

    CGRect cropframe = CGRectMake(self.cropAreaX, self.cropAreaY, self.cropAreaWidth, self.cropAreaHeight);
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.cropView.frame cornerRadius:0];
    UIBezierPath * cropPath = [UIBezierPath bezierPathWithRect:cropframe];
    [path appendPath:cropPath];
    layer.path = path.CGPath;

    layer.fillRule = kCAFillRuleEvenOdd;
    layer.fillColor = [self.maskBackgroundColor CGColor];
    layer.opacity = self.maskOpacity;

    layer.frame = self.cropView.bounds;
    layer.cropAreaLeft = self.cropAreaX;
    layer.cropAreaTop = self.cropAreaY;
    layer.cropAreaRight = self.cropAreaX + self.cropAreaWidth;
    layer.cropAreaBottom = self.cropAreaY + self.cropAreaHeight;

    layer.cropLineWidth = self.cropLineWidth;
    layer.cropLineColor = self.cropLineColor;

    [self.cropView.layer addSublayer:layer];
//    [self.view bringSubviewToFront:self.cropView];
}

- (void)backButtonAction:(UIButton *)button{
    [self dismissWithCompletion:nil];
}

- (void)confirmButtonAction:(UIButton *)button{
    __weak typeof(self) weakSelf = self;
    [self dismissWithCompletion:^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf.dynamicClipImageComplete) {
            strongSelf.dynamicClipImageComplete([strongSelf cropImage]);
        }
    }];
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UIView *)cropView{
    if (!_cropView) {
        _cropView = [[UIView alloc] init];
        _cropView.frame = self.view.frame;
    }
    return _cropView;
}

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setTitle:@"取消" forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _backButton.frame = CGRectMake(10, 20, 80, 50);
    }
    return _backButton;
}

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:@"确认" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 80 - 10, 20, 80, 50);
    }
    return _confirmButton;
}

- (UIColor *)backgroundColor{
    if (!_backgroundColor) {
        _backgroundColor = [UIColor blackColor];//页面底部背景色 默认黑色
    }
    return _backgroundColor;
}

- (UIColor *)maskBackgroundColor{
    if (!_maskBackgroundColor) {
        _maskBackgroundColor = [UIColor blackColor];//遮罩背景色 默认黑色
    }
    return _maskBackgroundColor;
}

- (UIColor *)cropLineColor{
    if (!_cropLineColor) {
        self.cropLineColor = [UIColor whiteColor];//裁剪框线的颜色 默认白色
    }
    return _cropLineColor;
}

- (NSUInteger)cropLineWidth{
    if (!_cropLineWidth) {
        _cropLineWidth = 2;//裁剪框线的宽度  默认2
    }
    return _cropLineWidth;
}

- (CGFloat)maskOpacity{
    if (!_maskOpacity) {
        _maskOpacity = 0.5;
    }
    return _maskOpacity;
}

@end
