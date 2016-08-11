//
//  BannerView.h
//  Agilanews
//
//  Created by 张思思 on 16/8/4.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BannerView : UIView

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, assign) long long showTime;

+ (instancetype)sharedInstance;
- (void)showBannerWithText:(NSString *)text superView:(UIView *)view;

@end
