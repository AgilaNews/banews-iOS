//
//  GuideRefreshView.m
//  Agilanews
//
//  Created by 张思思 on 16/8/5.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "GuideRefreshView.h"
#import "HomeViewController.h"

@implementation GuideRefreshView

static GuideRefreshView *_guideView = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _guideView = [[GuideRefreshView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _guideView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
        [_guideView _initSubviews];
    });
    return _guideView;
}

/**
 *  初始化刷新引导视图
 */
- (void)_initSubviews
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeAction)];
    [_guideView addGestureRecognizer:tap];
    _swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(removeAction)];
    _swipe.direction = UISwipeGestureRecognizerDirectionDown;
    [_guideView addGestureRecognizer:_swipe];
    
    _refreshView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 93, kScreenWidth - (kScreenWidth - 320) * .5, 220)];
    _refreshView.image = [self stretchableImageWithPic:[UIImage imageNamed:@"guide_refresh"]];
    [_guideView addSubview:_refreshView];
    // 拉伸图片
    CGFloat tempWidth = kScreenWidth / 2.0 + 320 / 2.0;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(tempWidth, 220), NO, [UIScreen mainScreen].scale);
    [_refreshView.image drawInRect:CGRectMake(0, 0, tempWidth, 220)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _refreshView.frame = CGRectMake(0, 93, kScreenWidth, 220);
    _refreshView.image = [self stretchableImage:image];
    
    _handView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth *.5 + 15, 170, 58, 46)];
    _handView.image = [UIImage imageWithCGImage:[UIImage imageNamed:@"hand"].CGImage scale:1 orientation:UIImageOrientationLeft];
    [_guideView addSubview:_handView];
    _isRefreshAnimation = YES;
    [self startAnimation];
}

/**
 *  初始化频道引导视图
 */
- (void)_initChannelGuide
{
    _isNoTouch = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _channelView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - (kScreenWidth - 320) * .5, 225)];
        _channelView.image = [self stretchableImageWithPic:[UIImage imageNamed:@"swipe"]];
        [_guideView addSubview:_channelView];
        // 拉伸图片
        CGFloat tempWidth = kScreenWidth / 2.0 + 320 / 2.0;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(tempWidth, 225), NO, [UIScreen mainScreen].scale);
        [_channelView.image drawInRect:CGRectMake(0, 0, tempWidth, 225)];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        _channelView.frame = CGRectMake(0, 0, kScreenWidth, 225);
        _channelView.image = [[self stretchableImage:image] stretchableImageWithLeftCapWidth:0 topCapHeight:10];
        
        UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, _channelView.bottom, kScreenWidth, kScreenHeight - _channelView.bottom)];
        shadowView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
        [_guideView addSubview:shadowView];
        
        _handView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth *.5 + 44, 135, 46, 58)];
        _handView.image = [UIImage imageNamed:@"hand"];
        [_guideView addSubview:_handView];
        _isNoTouch = NO;
    });
}

/**
 *  拉伸图片方法
 *
 *  @return 被拉伸图片
 */
- (UIImage *)stretchableImageWithPic:(UIImage *)image
{
    return [image stretchableImageWithLeftCapWidth:image.size.width *.97 topCapHeight:image.size.height *0.5];
}
- (UIImage *)stretchableImage:(UIImage *)image
{
    return [image stretchableImageWithLeftCapWidth:image.size.width *.03 topCapHeight:image.size.height *0.5];
}

/**
 *  移除动画
 */
- (void)removeAction
{
    if (_isNoTouch) {
        return;
    }
    if (_refreshView) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Refresh object:nil];
        [GuideRefreshView sharedInstance].swipe.direction = UISwipeGestureRecognizerDirectionLeft;
        [[GuideRefreshView sharedInstance] removeAllSubviews];
        [GuideRefreshView sharedInstance].refreshView = nil;
        [GuideRefreshView sharedInstance].handView = nil;
        [UIView animateWithDuration:.3 animations:^{
            [GuideRefreshView sharedInstance].backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
            _isRefreshAnimation = NO;
            [[GuideRefreshView sharedInstance] _initChannelGuide];
        }];
    } else {
        UINavigationController *navCtrl = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        HomeViewController *homeVC = navCtrl.viewControllers.firstObject;
        UIButton *button = [UIButton new];
        button.tag = 10001;
        [homeVC.segmentVC btnClick:button];
        [UIView animateWithDuration:.3 animations:^{
            [GuideRefreshView sharedInstance].backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
            DEF_PERSISTENT_SET_OBJECT(SS_GuideHomeKey, @1);
            [[GuideRefreshView sharedInstance] removeFromSuperview];
        }];
    }
}

/**
 *  开始动画
 */
- (void)startAnimation
{
    if (_isRefreshAnimation) {
        [UIView animateWithDuration:.8 delay:.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _handView.top = 170 + 80;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.15 delay:.6 options:UIViewAnimationOptionCurveLinear animations:^{
                _handView.top = 170;
            } completion:^(BOOL finished) {
                [self startAnimation];
            }];
        }];
    } else {
        [UIView animateWithDuration:.8 delay:.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _handView.right = kScreenWidth * .5 - 44;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.15 delay:.6 options:UIViewAnimationOptionCurveLinear animations:^{
                _handView.left = kScreenWidth * .5 + 44;
            } completion:^(BOOL finished) {
                if (![DEF_PERSISTENT_GET_OBJECT(SS_GuideHomeKey) isEqualToNumber:@1]) {
                    [self startAnimation];
                }
            }];
        }];
    }
}


@end
