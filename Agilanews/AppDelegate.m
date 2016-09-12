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
    // 注册AppsFlyer
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"vKsiczVKraASChBxaENvbe";
    [AppsFlyerTracker sharedTracker].appleAppID = @"1146695204";
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
    
    // 读取用户登录信息/配置信息
    [self loadUserData];
    // 监听网络状态
    [self networkMonitoring];
    // 开始定位
    [self locationServices];
    // 冷启动
    [self coldBoot:YES];
    // 创建图片文件夹
    [self createImageFolderAtPath];
    // 启动上报打点
    NSString *logFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/log.data"];
    NSMutableArray *logData = [NSKeyedUnarchiver unarchiveObjectWithFile:logFilePath];
    if (logData.count > 0 && logData != nil) {
        [self serverLogWithEventArray:logData];
    }
    _eventArray = [NSMutableArray array];
    //设置启动页面时间
    [NSThread sleepForTimeInterval:2.0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _isStart = YES;
    });
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    SSLog(@"进入不活跃状态");
    if (_isStart) {
        // 刷新页面
        UINavigationController *navCtrl = (UINavigationController *)_window.rootViewController;
        HomeViewController *homeVC = navCtrl.viewControllers.firstObject;
        // 缓存新闻列表
        NSMutableDictionary *newsDic = [NSMutableDictionary dictionary];
        for (HomeTableViewController *homeTabVC in homeVC.segmentVC.subViewControllers) {
            if (homeTabVC.dataList.count > 0) {
                NSInteger length = 30;
                if (homeTabVC.dataList.count > length) {
                    [newsDic setObject:[NSMutableArray arrayWithArray:[homeTabVC.dataList subarrayWithRange:NSMakeRange(0, length)]] forKey:homeTabVC.model.channelID];
                } else {
                    [newsDic setObject:[NSMutableArray arrayWithArray:homeTabVC.dataList] forKey:homeTabVC.model.channelID];
                }
                [homeTabVC.dataList removeAllObjects];
            }
            [homeTabVC.tableView reloadData];
        }
        NSString *newsFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/news.data"];
        NSDictionary *newsData = [NSDictionary dictionaryWithObject:newsDic forKey:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]];
        [NSKeyedArchiver archiveRootObject:newsData toFile:newsFilePath];
    }
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
    
    // 清除详情缓存图片
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageFolder/"];
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSArray* filesArray = [fileMgr contentsOfDirectoryAtPath:folderPath error:nil];
    long long folderSize = 0 ;
    for (NSString *fileName in filesArray) {
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    if ((folderSize / (1024.0 * 1024.0) > 50)) {
        for (NSString *branchPath in filesArray)
        {
            @autoreleasepool {
                NSError *error = nil ;
                NSString *path = [folderPath stringByAppendingPathComponent:branchPath];
                if ([[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                }
            }
        }
    }
    
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
    // 激活AppsFlyer
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    if (_isStart) {
        NSString *newsFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/news.data"];
        NSDictionary *newsData = [NSKeyedUnarchiver unarchiveObjectWithFile:newsFilePath];
        NSNumber *checkNum = newsData.allKeys.firstObject;
        // 刷新页面
        UINavigationController *navCtrl = (UINavigationController *)_window.rootViewController;
        HomeViewController *homeVC = navCtrl.viewControllers.firstObject;
        for (HomeTableViewController *homeTabVC in homeVC.segmentVC.subViewControllers) {
            NSMutableArray *dataList = newsData[checkNum][homeTabVC.model.channelID];
            if (dataList == nil) {
                dataList = [NSMutableArray array];
            }
            homeTabVC.dataList = dataList;
            [homeTabVC.tableView reloadData];
        }
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    SSLog(@"程序将要终止");
    // 缓存所有数据
    [self cacheAllData];
    // 缓存打点记录
    NSString *logFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/log.data"];
    NSMutableArray *logData = [NSKeyedUnarchiver unarchiveObjectWithFile:logFilePath];
    if (logData.count > 0) {
        [logData addObjectsFromArray:_eventArray];
    } else {
        logData = [NSMutableArray arrayWithArray:_eventArray];
    }
    [NSKeyedArchiver archiveRootObject:logData toFile:logFilePath];
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
    // 时间戳
    [params setObject:[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] forKey:@"client_time"];
    [[SSHttpRequest sharedInstance] get:@"" params:params contentType:UrlencodedType serverType:NetServer_Home success:^(id responseObj) {
        // 地址存入NSUserDefaults
        DEF_PERSISTENT_SET_OBJECT(Server_Home, responseObj[@"interfaces"][@"home"]);
        DEF_PERSISTENT_SET_OBJECT(Server_Log, responseObj[@"interfaces"][@"log"]);
        DEF_PERSISTENT_SET_OBJECT(Server_Mon, responseObj[@"interfaces"][@"mon"]);
        DEF_PERSISTENT_SET_OBJECT(Server_Referrer, responseObj[@"interfaces"][@"referrer"]);
        // 分类存入模型
        NSArray *categories = responseObj[@"categories"];
        if (categories.count <= 0) {
            return;
        }
        NSMutableArray *newArray = [NSMutableArray array];
        for (NSDictionary *newDic in categories) {
            CategoriesModel *categoriesModel = [CategoriesModel mj_objectWithKeyValues:newDic];
            [newArray addObject:categoriesModel];
        }
        // 频道数不相同通知刷新
        if (_categoriesArray.count != categories.count) {
            _categoriesArray = newArray;
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Categories object:nil];
            return;
        }
        // 频道顺序不同通知刷新
        for (int i = 0; i < newArray.count; i++) {
            CategoriesModel *newModel = newArray[i];
            CategoriesModel *model = _categoriesArray[i];
            if (![newModel.name isEqualToString:model.name]) {
                _categoriesArray = newArray;
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Categories object:nil];
                return;
            }
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
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @autoreleasepool {
            // 加载登录信息
            NSString *loginFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userinfo.data"];
            _model = [NSKeyedUnarchiver unarchiveObjectWithFile:loginFilePath];
            // 加载点赞记录
            _likedDic = [NSMutableDictionary dictionary];
            NSString *likeFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/like.data"];
            NSDictionary *likeData = [NSKeyedUnarchiver unarchiveObjectWithFile:likeFilePath];
            NSNumber *likeNum = likeData.allKeys.firstObject;
            if ([[NSDate date] timeIntervalSince1970] - likeNum.longLongValue < 3600) {
                _likedDic = likeData[likeData.allKeys.firstObject];
            }
            // 加载新闻查看记录
            _checkDic = [NSMutableDictionary dictionary];
            NSString *checkFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/check.data"];
            NSDictionary *checkData = [NSKeyedUnarchiver unarchiveObjectWithFile:checkFilePath];
            NSNumber *checkNum = checkData.allKeys.firstObject;
            if ([[NSDate date] timeIntervalSince1970] - checkNum.longLongValue < 3600) {
                _checkDic = checkData[checkData.allKeys.firstObject];
            }
            // 加载频道刷新记录
            NSString *refreshFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/refresh.data"];
            _refreshTimeDic = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:refreshFilePath]];
        }
    });
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

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    SDWebImageManager *mgr = [SDWebImageManager sharedManager];
    // 取消正在下载的图片
    [mgr cancelAll];
    // 清除内存缓存
    [mgr.imageCache clearMemory];
}

// 创建图片文件夹
- (void)createImageFolderAtPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageFolder"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:filePath];
    if (!existed) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

// 计算文件大小
- (long long)fileSizeAtPath:(NSString *)filePath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0 ;
}

// 缓存数据
- (void)cacheAllData
{
    @autoreleasepool {
        UINavigationController *navCtrl = (UINavigationController *)_window.rootViewController;
        HomeViewController *homeVC = navCtrl.viewControllers.firstObject;
        // 缓存新闻列表
        NSMutableDictionary *newsDic = [NSMutableDictionary dictionary];
        for (HomeTableViewController *homeTabVC in homeVC.segmentVC.subViewControllers) {
            if (homeTabVC.dataList.count > 0) {
                NSInteger length = 30;
                if (homeTabVC.dataList.count > length) {
                    [newsDic setObject:[NSMutableArray arrayWithArray:[homeTabVC.dataList subarrayWithRange:NSMakeRange(0, length)]] forKey:homeTabVC.model.channelID];
                } else {
                    [newsDic setObject:[NSMutableArray arrayWithArray:homeTabVC.dataList] forKey:homeTabVC.model.channelID];
                }
            }
        }
        NSString *newsFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/news.data"];
        NSDictionary *newsData = [NSDictionary dictionaryWithObject:newsDic forKey:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]];
        [NSKeyedArchiver archiveRootObject:newsData toFile:newsFilePath];
        // 缓存点赞记录
        NSString *likeFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/like.data"];
        NSDictionary *likeData = [NSDictionary dictionaryWithObject:_likedDic forKey:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]];
        [NSKeyedArchiver archiveRootObject:likeData toFile:likeFilePath];
        // 缓存新闻查看记录
        NSString *checkFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/check.data"];
        NSDictionary *checkData = [NSDictionary dictionaryWithObject:_checkDic forKey:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]];
        [NSKeyedArchiver archiveRootObject:checkData toFile:checkFilePath];
        // 缓存频道刷新记录
        NSString *refreshFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/refresh.data"];
        [NSKeyedArchiver archiveRootObject:_refreshTimeDic toFile:refreshFilePath];
    }
}

@end
