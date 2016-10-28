//
//  PushTransitionAnimate.h
//  Agilanews
//
//  Created by 张思思 on 16/10/28.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushTransitionAnimate : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@end
