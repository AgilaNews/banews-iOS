//
//  AppDelegate+LaunchAd.m
//  Agilanews
//
//  Created by 张思思 on 17/1/13.
//  Copyright © 2017年 banews. All rights reserved.
//

#import "AppDelegate+LaunchAd.h"
#import "LaunchAdManager.h"
#import "DrawCircleProgressButton.h"

@implementation AppDelegate (LaunchAd)

- (void)setupLaunchAd
{
    NSNumber *stayTime = DEF_PERSISTENT_GET_OBJECT(SS_SPLASH_STAY_TIME);
    [XHLaunchAd setWaitDataDuration:stayTime.integerValue ? stayTime.integerValue : 3];//请求广告数据前,必须设置

    [[LaunchAdManager sharedInstance] getLaunchAdData:^(LaunchAdModel *model) {
        if (!model) {
            return;
        }
        XHLaunchImageAdConfiguration *imageAdconfiguration = [XHLaunchImageAdConfiguration new];
        // 广告停留时间
        NSNumber *adTime = DEF_PERSISTENT_GET_OBJECT(SS_SPLASH_AD_TIME);
        imageAdconfiguration.duration = adTime.integerValue ? adTime.integerValue : 3;
        // 广告frame
        imageAdconfiguration.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight * .81);
        // 广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
        NSString *imageUrl = [model.image stringByReplacingOccurrencesOfString:@"{w}" withString:[NSString stringWithFormat:@"%d",(int)(kScreenWidth * 2)]];
        imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{h}" withString:[NSString stringWithFormat:@"%d",(int)(kScreenHeight * .81 * 2)]];
        imageAdconfiguration.imageNameOrURLString = imageUrl;
        // 网络图片缓存机制
        imageAdconfiguration.imageOption = XHLaunchAdImageDefault;
        // 图片填充模式
        imageAdconfiguration.contentMode = UIViewContentModeScaleAspectFit;
        // 广告点击打开链接
        imageAdconfiguration.openURLString = @"";
        // 广告显示完成动画
        imageAdconfiguration.showFinishAnimate = ShowFinishAnimateFadein;
        // 跳过按钮类型
        imageAdconfiguration.skipButtonType = SkipTypeTimeText;
        // 后台返回时,是否显示广告
        imageAdconfiguration.showEnterForeground = YES;
        // 自定义跳过按钮
        imageAdconfiguration.customSkipView = [self customSkipView];
        // 设置要添加的子视图(可选)
        // imageAdconfiguration.subViews = ...
        // 显示图片开屏广告
        [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
    }];
}

- (UIView *)customSkipView
{
    DrawCircleProgressButton *drawCircleView = [[DrawCircleProgressButton alloc]initWithFrame:CGRectMake(kScreenWidth - 34 - 18, 16, 34, 34)];
    [drawCircleView setTitle:@"Skip" forState:UIControlStateNormal];
    [drawCircleView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    drawCircleView.titleLabel.font = [UIFont systemFontOfSize:14];
    drawCircleView.lineWidth = 2;
    return drawCircleView;
}

// 跳过按钮点击事件
- (void)skipAction
{
    [XHLaunchAd skipAction];
}

/**
 *  倒计时回调
 *
 *  @param launchAd XHLaunchAd
 *  @param duration 倒计时时间
 */
- (void)xhLaunchAd:(XHLaunchAd *)launchAd customSkipView:(UIView *)customSkipView duration:(NSInteger)duration
{
    DrawCircleProgressButton *drawCircleView = (DrawCircleProgressButton *)customSkipView;
    NSNumber *adTime = DEF_PERSISTENT_GET_OBJECT(SS_SPLASH_AD_TIME);
    if (adTime && duration == adTime.integerValue) {
        [drawCircleView startAnimationDuration:duration withBlock:^{
            [drawCircleView removeFromSuperview];
        }];
    } else if (duration == 3){
        [drawCircleView startAnimationDuration:3 withBlock:^{
            [drawCircleView removeFromSuperview];
        }];
    }
//    //设置自定义跳过按钮时间
//    UIButton *button = (UIButton *)customSkipView;//此处转换为你之前的类型
//    //设置时间
//    [button setTitle:[NSString stringWithFormat:@"自定义%lds",duration] forState:UIControlStateNormal];
}

// 广告显示完成
- (void)xhLaunchShowFinish:(XHLaunchAd *)launchAd
{
    DEF_PERSISTENT_SET_OBJECT(SS_SPLASH_SHOW_TIME, [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]);
}

@end
