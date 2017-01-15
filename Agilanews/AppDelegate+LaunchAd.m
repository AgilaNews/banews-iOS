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
#import "AppDelegate.h"

@implementation AppDelegate (LaunchAd)

- (void)setupLaunchAd
{
    NSNumber *stayTime = DEF_PERSISTENT_GET_OBJECT(SS_SPLASH_STAY_TIME);
    [XHLaunchAd setWaitDataDuration:stayTime.integerValue ? stayTime.integerValue : 3];//请求广告数据前,必须设置

    __weak typeof(self) weakSelf = self;
    [[LaunchAdManager sharedInstance] getLaunchAdData:^(LaunchAdModel *model) {
        if (!model) {
            return;
        }
        weakSelf.launchAdModel = model;
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
    [drawCircleView addTarget:self action:@selector(skipAction) forControlEvents:UIControlEventTouchUpInside];
    return drawCircleView;
}

// 跳过按钮点击事件
- (void)skipAction
{
    if (self.launchAdModel) {
        __weak typeof(self) weakSelf = self;
        // 服务器打点-开屏广告结束-060202
        NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
        [eventDic setObject:@"060202" forKey:@"id"];
        [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
        [eventDic setObject:self.launchAdModel.dataid forKey:@"data_id"];
        if (self.launchAdModel.impression_id) {
            [eventDic setObject:self.launchAdModel.impression_id forKey:@"impression_id"];
        }
        long long finishTime = [[NSDate date] timeIntervalSince1970] * 1000;
        long long duration = finishTime - self.launchAdShowTime;
        if (duration > 0) {
            [eventDic setObject:[NSNumber numberWithLongLong:finishTime - self.launchAdShowTime] forKey:@"show_period"];
        }
        self.launchAdModel.is_skip = @1;
        [eventDic setObject:@1 forKey:@"is_skip"];
        [eventDic setObject:[NetType getNetType] forKey:@"net"];
        if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
            [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
            [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
        } else {
            [eventDic setObject:@"" forKey:@"lng"];
            [eventDic setObject:@"" forKey:@"lat"];
        }
        NSString *abflag = DEF_PERSISTENT_GET_OBJECT(@"abflag");
        if (abflag && abflag.length > 0) {
            [eventDic setObject:abflag forKey:@"abflag"];
        }
        NSDictionary *sessionDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                    DEF_PERSISTENT_GET_OBJECT(@"UUID"), @"id",
                                    [NSArray arrayWithObject:eventDic], @"events",
                                    nil];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[NSArray arrayWithObject:sessionDic] forKey:@"sessions"];
        [[SSHttpRequest sharedInstance] post:@"" params:params contentType:JsonType serverType:NetServer_Log success:^(id responseObj) {
            // 打点成功
        } failure:^(NSError *error) {
            // 打点失败
            [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(@"UUID") forKey:@"session"];
            [weakSelf.eventArray addObject:eventDic];
        } isShowHUD:NO];
    }
    [XHLaunchAd skipAction];
}

- (void)xhLaunchAd:(XHLaunchAd *)launchAd imageDownLoadFinish:(UIImage *)image configuration:(XHLaunchAdConfiguration *)configuration
{
    if (!self.launchAdModel) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    // 服务器打点-开屏广告展示-060201
    NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
    [eventDic setObject:@"060201" forKey:@"id"];
    long long showTime = [[NSDate date] timeIntervalSince1970] * 1000;
    self.launchAdShowTime = showTime;
    [eventDic setObject:[NSNumber numberWithLongLong:showTime] forKey:@"time"];
    [eventDic setObject:self.launchAdModel.dataid forKey:@"data_id"];
    NSString *uuid = [[NSUUID UUID] UUIDString];
    self.launchAdModel.impression_id = uuid;
    [eventDic setObject:uuid forKey:@"impression_id"];
    [eventDic setObject:[NetType getNetType] forKey:@"net"];
    if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
    } else {
        [eventDic setObject:@"" forKey:@"lng"];
        [eventDic setObject:@"" forKey:@"lat"];
    }
    NSString *abflag = DEF_PERSISTENT_GET_OBJECT(@"abflag");
    if (abflag && abflag.length > 0) {
        [eventDic setObject:abflag forKey:@"abflag"];
    }
    NSDictionary *sessionDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                DEF_PERSISTENT_GET_OBJECT(@"UUID"), @"id",
                                [NSArray arrayWithObject:eventDic], @"events",
                                nil];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[NSArray arrayWithObject:sessionDic] forKey:@"sessions"];
    [[SSHttpRequest sharedInstance] post:@"" params:params contentType:JsonType serverType:NetServer_Log success:^(id responseObj) {
        // 打点成功
    } failure:^(NSError *error) {
        // 打点失败
        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(@"UUID") forKey:@"session"];
        [weakSelf.eventArray addObject:eventDic];
    } isShowHUD:NO];
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
        [drawCircleView startAnimationDuration:duration - 1 withBlock:^{
            [drawCircleView removeFromSuperview];
        }];
    } else if (duration == 3) {
        [drawCircleView startAnimationDuration:duration - 1 withBlock:^{
            [drawCircleView removeFromSuperview];
        }];
    }
}

// 广告显示完成
- (void)xhLaunchShowFinish:(XHLaunchAd *)launchAd
{
    DEF_PERSISTENT_SET_OBJECT(SS_SPLASH_SHOW_TIME, [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]);
    if (self.launchAdModel  && ![self.launchAdModel.is_skip isEqualToNumber:@1]) {
        __weak typeof(self) weakSelf = self;
        // 服务器打点-开屏广告结束-060202
        NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
        [eventDic setObject:@"060202" forKey:@"id"];
        [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
        [eventDic setObject:self.launchAdModel.dataid forKey:@"data_id"];
        if (self.launchAdModel.impression_id) {
            [eventDic setObject:self.launchAdModel.impression_id forKey:@"impression_id"];
        }
        long long finishTime = [[NSDate date] timeIntervalSince1970] * 1000;
        long long duration = finishTime - self.launchAdShowTime;
        if (duration > 0) {
            [eventDic setObject:[NSNumber numberWithLongLong:finishTime - self.launchAdShowTime] forKey:@"show_period"];
        }
        [eventDic setObject:@0 forKey:@"is_skip"];
        [eventDic setObject:[NetType getNetType] forKey:@"net"];
        if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
            [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
            [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
        } else {
            [eventDic setObject:@"" forKey:@"lng"];
            [eventDic setObject:@"" forKey:@"lat"];
        }
        NSString *abflag = DEF_PERSISTENT_GET_OBJECT(@"abflag");
        if (abflag && abflag.length > 0) {
            [eventDic setObject:abflag forKey:@"abflag"];
        }
        NSDictionary *sessionDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                    DEF_PERSISTENT_GET_OBJECT(@"UUID"), @"id",
                                    [NSArray arrayWithObject:eventDic], @"events",
                                    nil];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[NSArray arrayWithObject:sessionDic] forKey:@"sessions"];
        [[SSHttpRequest sharedInstance] post:@"" params:params contentType:JsonType serverType:NetServer_Log success:^(id responseObj) {
            // 打点成功
        } failure:^(NSError *error) {
            // 打点失败
            [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(@"UUID") forKey:@"session"];
            [weakSelf.eventArray addObject:eventDic];
        } isShowHUD:NO];
    }
}

@end
