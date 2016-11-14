//
//  PopTransitionAnimate.m
//  Agilanews
//
//  Created by 张思思 on 16/10/28.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "PopTransitionAnimate.h"

@implementation PopTransitionAnimate

- (instancetype)initWithToView:(UIView *)toView
{
    self = [super init];
    if (self) {
        _toView = toView;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    
    // 获取动画的源控制器和目标控制器
    UIViewController *fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    //获取容器视图
    UIView *contView = [transitionContext containerView];
    [contView addSubview:toVC.view];
    [contView addSubview:_toView];
    [contView addSubview:fromVC.view];
    toVC.view.right = kScreenWidth / 2;
    _toView.right = kScreenWidth / 2;
    fromVC.view.left = 0;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    // 添加动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromVC.view.left = kScreenWidth;
        _toView.left = 0;
        toVC.view.left = 0;
    } completion:^(BOOL finished) {
        [_toView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

@end
