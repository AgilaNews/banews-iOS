//
//  BaseNavigationController.m
//  Agilanews
//
//  Created by 张思思 on 16/7/14.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "BaseNavigationController.h"

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 将导航栏设置为透明
    //self.navigationBar.translucent = YES;
    // 设置导航栏背景颜色
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        [self.navigationBar setBarTintColor:kOrangeColor];
        UIView *barBgView = self.navigationBar.subviews.firstObject;
        for (UIView *subview in barBgView.subviews) {
            if([subview isKindOfClass:[UIVisualEffectView class]]) {
                subview.backgroundColor = kOrangeColor;
                [subview removeAllSubviews];
            }
        }
    } else {
        [self.navigationBar lt_setBackgroundColor:kOrangeColor];
    }
    // 设置导航栏阴影
    self.navigationBar.shadowImage = [UIImage new];
    // 设置手势返回代理对象
    __weak typeof (self) weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.isCanSideBack;
}

- (void)dealloc
{
    // 释放手势返回代理对象
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
