//
//  BaseNavigationController.h
//  Agilanews
//
//  Created by 张思思 on 16/7/14.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseNavigationController : UINavigationController<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL isCanSideBack;

@end
