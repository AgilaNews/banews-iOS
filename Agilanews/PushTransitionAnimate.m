//
//  PushTransitionAnimate.m
//  Agilanews
//
//  Created by 张思思 on 16/10/28.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "PushTransitionAnimate.h"
#import "BaseViewController.h"

@implementation PushTransitionAnimate

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    
    // 获取动画的源控制器和目标控制器
//    UIViewController *fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSString *deviceModel = [NetType getCurrentDeviceModel];
    UIView *fromView = nil;
    if ([deviceModel isEqualToString:@"iPhone7"] || [deviceModel isEqualToString:@"iPhone7Plus"]) {
        //        if ([deviceModel isEqualToString:@"iPhoneSimulator"]) {
        UIImage *image = [self imageFromView:[UIApplication sharedApplication].keyWindow];
        fromView = [[UIImageView alloc] initWithImage:image];
    } else {
        fromView = [[UIApplication sharedApplication].keyWindow snapshotViewAfterScreenUpdates:NO];
    }
    
    //获取容器视图
    UIView *contView = [transitionContext containerView];
    [contView addSubview:fromView];
    [contView addSubview:toVC.view];
    toVC.view.left = kScreenWidth;

    // 添加动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromView.right = kScreenWidth / 2;
        toVC.view.left = 0;
    } completion:^(BOOL finished) {
        [fromView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

- (UIImage *)imageFromView:(UIView *)snapView {
    UIGraphicsBeginImageContext(snapView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [snapView.layer renderInContext:context];
    UIImage *targetImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return targetImage;
}

@end
