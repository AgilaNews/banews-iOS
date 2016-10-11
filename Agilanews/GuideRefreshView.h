//
//  GuideRefreshView.h
//  Agilanews
//
//  Created by 张思思 on 16/8/5.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideRefreshView : UIView

@property (nonatomic, strong) UIImageView *refreshView;
@property (nonatomic, strong) UIImageView *handView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipe;
@property (nonatomic, strong) UIImageView *channelView;
@property (nonatomic, strong) UIImageView *menuView;
@property (nonatomic, assign) BOOL isRefreshAnimation;
@property (nonatomic, assign) BOOL isNoTouch;

+ (instancetype)sharedInstance;

@end
