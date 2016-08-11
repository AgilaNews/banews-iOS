//
//  BannerView.m
//  Agilanews
//
//  Created by 张思思 on 16/8/4.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "BannerView.h"

@implementation BannerView

static BannerView *_bannerView = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _bannerView = [[BannerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 29)];
        _bannerView.backgroundColor = SSColor(222, 239, 243);
        [_bannerView addSubview:_bannerView.textLabel];
    });
    return _bannerView;
}

- (void)showBannerWithText:(NSString *)text superView:(UIView *)view
{
    _bannerView.alpha = 1;
    _bannerView.textLabel.text = text;
    [view addSubview:_bannerView];
    _showTime = [[NSDate date] timeIntervalSince1970];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([[NSDate date] timeIntervalSince1970] - _showTime >= 1.5) {
            [UIView animateWithDuration:.5 animations:^{
                _bannerView.alpha = 0;
            } completion:^(BOOL finished) {
                [_bannerView removeFromSuperview];
            }];
        }
    });
}

- (UILabel *)textLabel
{
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _bannerView.width, _bannerView.height)];
        _textLabel.textColor = SSColor(0, 172, 215);
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont systemFontOfSize:14];
    }
    return _textLabel;
}

@end
