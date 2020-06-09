//
//  ViewController.m
//  ZVDynamicClipImageDemo
//
//  Created by CNTP on 2020/6/9.
//  Copyright © 2020 CNTP. All rights reserved.
//

#import "ViewController.h"
#import <ZVDynamicClipImage/ZVDynamicClipImage.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)clipImageButtonAction:(id)sender {
    ZVDynamicClipImageViewController *viewController = [[ZVDynamicClipImageViewController alloc] init];
    viewController.clipImage = [UIImage imageNamed:@"IMG_0085"];
    viewController.cropLineColor = [UIColor redColor];
    viewController.maskBackgroundColor = [UIColor blueColor];
    [viewController showAndComplete:^(UIImage * _Nonnull image) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }];
}

@end
