//
//  AppDelegate.m
//  Agilanews
//
//  Created by 张思思 on 16/7/12.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "BaseNavigationController.h"
#import "AppDelegate+ShareSDK.h"
#import "HomeTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // 注册Flurry
#if DEBUG
    [Flurry startSession:@"XC84PTZ5BKW385XPBJ2N"];
#else
    [Flurry startSession:@"ZBQNRB8P9XRTS7T7W2ZC"];
#endif
    [Flurry setAppVersion:[NSString stringWithFormat:@"v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
    // 注册ShareSDK
    [self registerShareSDK];
    // 注册Twitter/Crashlytics
    [Fabric with:@[[Twitter class], [Crashlytics class]]];
    // 读取用户登录信息/配置信息
    [self loadUserData];
    // 监听网络状态
    [self networkMonitoring];
    // 开始定位
    [self locationServices];
    // 冷启动
    [self coldBoot:YES];
    // 启动上报打点
    NSString *logFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/log.data"];
    NSMutableArray *logData = [NSKeyedUnarchiver unarchiveObjectWithFile:logFilePath];
    if (logData.count > 0 && logData != nil) {
        [self serverLogWithEventArray:logData];
    }
    //设置启动页面时间
    [NSThread sleepForTimeInterval:2.0];

#if DEBUG
    _window = [[iConsoleWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = SSColor(0, 0, 0);
    [iConsole sharedConsole].delegate = self;
    [iConsole sharedConsole].logSubmissionEmail = @"1164063991@qq.com";
#else
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = SSColor(255, 255, 255);
#endif
    [_window makeKeyAndVisible];
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    BaseNavigationController *navCtrl = [[BaseNavigationController alloc] initWithRootViewController:homeVC];
    // 设置根控制器
    _window.rootViewController = navCtrl;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    SSLog(@"进入后台");
    // 记录进入后台时间
    DEF_PERSISTENT_SET_OBJECT(@"BackgroundTime", [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]);
    // 打点-退出APP-010002
    UINavigationController *navCtrl = (UINavigationController *)_window.rootViewController;
    HomeViewController *homeVC = navCtrl.viewControllers.firstObject;
    NSInteger index = homeVC.segmentVC.selectIndex - 10000;
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   homeVC.segmentVC.titleArray[index], @"channel",
                                   nil];
    [Flurry logEvent:@"App_Exit" withParameters:articleParams];
    #if DEBUG
    [iConsole info:[NSString stringWithFormat:@"App_Exit:%@",articleParams],nil];
    #endif
    // 服务端打点上报
    [self serverLogWithEventArray:_eventArray];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    SSLog(@"将要进入前台");
    // 冷启动
    [self coldBoot:NO];
    // 开始定位
    [self locationServices];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    SSLog(@"处于活跃状态");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    SSLog(@"程序将要终止");
    // 缓存新闻查看记录
    NSString *checkFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/check.data"];
    NSDictionary *checkData = [NSDictionary dictionaryWithObject:_checkDic forKey:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]];
    [NSKeyedArchiver archiveRootObject:checkData toFile:checkFilePath];
    // 缓存新闻列表
    BaseNavigationController *baseNav = (BaseNavigationController *)_window.rootViewController;
    HomeViewController *homeVC = baseNav.viewControllers.firstObject;
    NSMutableDictionary *newsDic = [NSMutableDictionary dictionary];
    for (HomeTableViewController *homeTabVC in homeVC.segmentVC.subViewControllers) {
        if (homeTabVC.dataList.count > 0) {
            [newsDic setObject:homeTabVC.dataList forKey:homeTabVC.model.channelID];
        }
    }
    NSString *newsFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/news.data"];
    NSDictionary *newsData = [NSDictionary dictionaryWithObject:newsDic forKey:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]];
    [NSKeyedArchiver archiveRootObject:newsData toFile:newsFilePath];
    // 缓存打点记录
    NSString *logFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/log.data"];
    NSMutableArray *logData = [NSKeyedUnarchiver unarchiveObjectWithFile:logFilePath];
    if (logData.count > 0) {
        [logData addObjectsFromArray:_eventArray];
    } else {
        logData = [NSMutableArray arrayWithArray:_eventArray];
    }
    [NSKeyedArchiver archiveRootObject:logData toFile:logFilePath];
    // 缓存频道刷新记录
    NSString *refreshFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/refresh.data"];
    [NSKeyedArchiver archiveRootObject:_refreshTimeDic toFile:refreshFilePath];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/**
 *  冷启动
 */
- (void)coldBoot:(BOOL)isFirst
{
    // 打点-启动app-010001
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   nil];
    [Flurry logEvent:@"App_Lanch" withParameters:articleParams];
#if DEBUG
    [iConsole info:[NSString stringWithFormat:@"App_Lanch:%@",articleParams],nil];
#endif
    // 设置IDFA（广告标识符）
    NSString *IDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    DEF_PERSISTENT_SET_OBJECT(@"IDFA", IDFA);
    NSString *uuid = [[NSUUID UUID] UUIDString];
    // 刷新session
    NSNumber *backgroundTime = DEF_PERSISTENT_GET_OBJECT(@"BackgroundTime");
    if ([[NSDate date] timeIntervalSince1970] - backgroundTime.longLongValue > 3600) {
        DEF_PERSISTENT_SET_OBJECT(@"UUID", uuid);
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // 手机厂商
    [params setObject:@"apple" forKey:@"vendor"];
    // 国家编号
    [params setObject:[[NSLocale currentLocale] localeIdentifier] forKey:@"mcc"];
    // 设备宽高
    [params setObject:[NSNumber numberWithInt:(int)kScreenWidth_DP] forKey:@"r_w"];
    [params setObject:[NSNumber numberWithInt:(int)kScreenHeight_DP] forKey:@"r_h"];
    // 网络运营商
    CTTelephonyNetworkInfo *networInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networInfo subscriberCellularProvider];
    if ([carrier carrierName] == nil) {
        [params setObject:@"" forKey:@"isp"];
    } else {
        [params setObject:[carrier carrierName] forKey:@"isp"];
    }
    // 网络情况
    NSString *netType = networInfo.currentRadioAccessTechnology;
    if ([@"WiFi" isEqualToString:DEF_PERSISTENT_GET_OBJECT(@"netStatus")]) {
        netType = @"wifi";
    } else {
        if ([netType isEqualToString:@"CTRadioAccessTechnologyGPRS"] || [netType isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
            netType = @"2G";
        } else if ([netType isEqualToString:@"CTRadioAccessTechnologyHSDPA"] || [netType isEqualToString:@"CTRadioAccessTechnologyWCDMA"] || [netType isEqualToString:@"CTRadioAccessTechnologyHSUPA"] || [netType isEqualToString:@"CTRadioAccessTechnologyCDMA1x"] || [netType isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"] || [netType isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"] || [netType isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"] || [netType isEqualToString:@"CTRadioAccessTechnologyeHRPD"]) {
            netType = @"3G";
        } else if ([netType isEqualToString:@"CTRadioAccessTechnologyLTE"]){
            netType = @"4G";
        } else {
            netType = @"unknow";
        }
    }
    [params setObject:netType forKey:@"net"];
    // 时间戳
    [params setObject:[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] forKey:@"client_time"];
    [[SSHttpRequest sharedInstance] get:@"" params:params contentType:UrlencodedType serverType:NetServer_Home success:^(id responseObj) {
        // 地址存入NSUserDefaults
        DEF_PERSISTENT_SET_OBJECT(Server_Home, responseObj[@"interfaces"][@"home"]);
        DEF_PERSISTENT_SET_OBJECT(Server_Log, responseObj[@"interfaces"][@"log"]);
        DEF_PERSISTENT_SET_OBJECT(Server_Mon, responseObj[@"interfaces"][@"mon"]);
        DEF_PERSISTENT_SET_OBJECT(Server_Referrer, responseObj[@"interfaces"][@"referrer"]);
        // 分类存入模型
        if (responseObj[@"categories"] == nil) {
            return;
        }
        _categoriesArray = [NSMutableArray array];
        for (NSDictionary *dic in responseObj[@"categories"]) {
            CategoriesModel *categoriesModel = [CategoriesModel mj_objectWithKeyValues:dic];
            [_categoriesArray addObject:categoriesModel];
        }
        if (isFirst && _categoriesArray.count > 0) {
            // 通知刷新
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Categories object:nil];
        }
    } failure:^(NSError *error) {
        
    } isShowHUD:NO];
}

/**
 *  监听网络状态
 */
- (void)networkMonitoring
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //当网络状态发生变化时会调用这个block
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                SSLog(@"WiFi");
                DEF_PERSISTENT_SET_OBJECT(SS_netStatus, @"WiFi");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                SSLog(@"手机网络");
                DEF_PERSISTENT_SET_OBJECT(SS_netStatus, @"WWAN");
                CTTelephonyNetworkInfo *networInfo = [[CTTelephonyNetworkInfo alloc] init];
                NSString *netType = networInfo.currentRadioAccessTechnology;
                if ([netType isEqualToString:@"CTRadioAccessTechnologyGPRS"] || [netType isEqualToString:@"CTRadioAccessTechnologyEdge"] || [netType isEqualToString:@"CTRadioAccessTechnologyWCDMA"] || [netType isEqualToString:@"CTRadioAccessTechnologyHSDPA"] || [netType isEqualToString:@"CTRadioAccessTechnologyHSUPA"] || [netType isEqualToString:@"CTRadioAccessTechnologyCDMA1x"] || [netType isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"] || [netType isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"] || [netType isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"] || [netType isEqualToString:@"CTRadioAccessTechnologyeHRPD"])
                {
                    // 弹出无图模式提示框
                    [self showTextOnlyAlert];
                }
                break;
            }
            case AFNetworkReachabilityStatusNotReachable:
                SSLog(@"没有网络");
                break;
            case AFNetworkReachabilityStatusUnknown:
                SSLog(@"未知网络");
                break;
            default:
                break;
        }
    }];
    [manager startMonitoring];
}

/**
 *  定位
 */
- (void)locationServices
{
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse))
    {
        //定位功能可用，开始定位
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 10;
        if (IOS_VERSION_CODE >= 8) {
            //使用程序其间允许访问位置数据（iOS8定位需要）
            [_locationManager requestWhenInUseAuthorization];
        }
        [_locationManager startUpdatingLocation];
    }
}

/**
 *  定位成功回调
 *
 *  @param manager   定位管理
 *  @param locations 位置
 */
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [_locationManager stopUpdatingLocation];
    CLLocationCoordinate2D location = locations.lastObject.coordinate;
    NSString *latitude = [NSString stringWithFormat:@"%f",location.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",location.longitude];
    DEF_PERSISTENT_SET_OBJECT(SS_LATITUDE, latitude);
    DEF_PERSISTENT_SET_OBJECT(SS_LONGITUDE,longitude);
}

/**
 *  读取用户登录信息/配置信息
 */
- (void)loadUserData
{
    NSString *loginFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userinfo.data"];
    LoginModel *model = [NSKeyedUnarchiver unarchiveObjectWithFile:loginFilePath];
    _model = model;
    _likedDic = [NSMutableDictionary dictionary];
    _checkDic = [NSMutableDictionary dictionary];
    _eventArray = [NSMutableArray array];
    NSString *checkFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/check.data"];
    NSDictionary *checkData = [NSKeyedUnarchiver unarchiveObjectWithFile:checkFilePath];
    NSNumber *checkNum = checkData.allKeys.firstObject;
    if ([[NSDate date] timeIntervalSince1970] - checkNum.longLongValue < 3600) {
        _checkDic = checkData[checkData.allKeys.firstObject];
    }
    NSString *refreshFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/refresh.data"];
    _refreshTimeDic = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:refreshFilePath]];
}

/**
 *  无图模式弹出提示框
 */
- (void)showTextOnlyAlert
{
    NSString *title = @"Tips";
    NSString *message = @"Do you want to choose 'Text-only Mode' to save data usage?";
    UIAlertController *textOnlyAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:title];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:kBlackColor range:NSMakeRange(0, title.length)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, title.length)];
    [textOnlyAlert setValue:alertControllerStr forKey:@"attributedTitle"];
    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:message];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:SSColor(102, 102, 102) range:NSMakeRange(0, message.length)];
    [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, message.length)];
    [textOnlyAlert setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No,Thanks" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 打点-点击无图模式提醒对话框No选项-010011
        [Flurry logEvent:@"LowDataTips_No_Click"];
#if DEBUG
        [iConsole info:@"LowDataTips_No_Click",nil];
#endif
    }];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes,Please" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 打点-点击无图模式提醒对话框中YES选项-010010
        [Flurry logEvent:@"LowDataTips_YES_Click"];
#if DEBUG
        [iConsole info:@"LowDataTips_YES_Click",nil];
#endif
        DEF_PERSISTENT_SET_OBJECT(SS_textOnlyMode, @1);
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_TextOnly_ON object:nil];
    }];
    [textOnlyAlert addAction:noAction];
    [textOnlyAlert addAction:yesAction];
    [self.window.rootViewController presentViewController:textOnlyAlert animated:YES completion:nil];
}

/**
 *  服务端打点上报
 */
- (void)serverLogWithEventArray:(NSMutableArray *)eventArray
{
    __weak typeof(self) weakSelf = self;
    if ([[NetType getNetType] isEqualToString:@"wifi"] && eventArray.count > 0) {
        // 上报打点信息
        NSArray *logArray = [NSArray array];
        if (eventArray.count >= 10) {
            logArray = [eventArray subarrayWithRange:NSMakeRange(0, 10)];
            [eventArray removeObjectsInRange:NSMakeRange(0, 10)];
        } else {
            logArray = [NSArray arrayWithArray:eventArray];
            [eventArray removeAllObjects];
        }
        NSMutableDictionary *sessionDic = [NSMutableDictionary dictionary];
        for (NSMutableDictionary *eventDic in logArray) {
            NSString *session = eventDic[@"session"];
            [eventDic removeObjectForKey:@"session"];
            if (sessionDic[session] != nil) {
                // 字典中有session
                NSMutableArray *events = sessionDic[session];
                [events addObject:eventDic];
                [sessionDic setObject:events forKey:session];
            } else {
                // 字典中无session
                NSMutableArray *events = [NSMutableArray array];
                [events addObject:eventDic];
                [sessionDic setObject:events forKey:session];
            }
        }
        NSMutableArray *sessions = [NSMutableArray array];
        for (NSString *session in sessionDic.allKeys) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 session, @"id",
                                 sessionDic[session], @"events",
                                 nil];
            [sessions addObject:dic];
        }
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[NSArray arrayWithObject:sessionDic] forKey:@"sessions"];
        [[SSHttpRequest sharedInstance] post:@"" params:params contentType:JsonType serverType:NetServer_Log success:^(id responseObj) {
            // 打点成功
            [weakSelf serverLogWithEventArray:eventArray];
        } failure:^(NSError *error) {
            // 打点失败
            [weakSelf serverLogWithEventArray:eventArray];
        } isShowHUD:NO];
    }
}

- (void)handleConsoleCommand:(NSString *)command
{
    if ([command isEqualToString:@"version"])
    {
        [iConsole info:@"%@ version %@",
         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"],
         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    }
    else
    {
        [iConsole error:@"unrecognised command, try 'version' instead"];
    }
}

@end
