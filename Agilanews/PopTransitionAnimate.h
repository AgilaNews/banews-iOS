//
//  PopTransitionAnimate.h
//  Agilanews
//
//  Created by 张思思 on 16/10/28.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PopTransitionAnimate : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, strong) UIView *toView;

- (instancetype)initWithToView:(UIView *)toView;

@end
