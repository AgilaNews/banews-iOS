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
#import "AppDelegate+LaunchAd.h"
#import "HomeTableViewController.h"
#import "NewsDetailViewController.h"
#import "VideoDetailViewController.h"
#import "GifDetailViewController.h"
#import "PicDetailViewController.h"
#import "LaunchAdManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - APP生命周期
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // 注册Flurry
#if DEBUG
    [Flurry startSession:@"XC84PTZ5BKW385XPBJ2N"];
#else
    [Flurry startSession:@"ZBQNRB8P9XRTS7T7W2ZC"];
#endif
    [Flurry setAppVersion:[NSString stringWithFormat:@"v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
    // 注册Twitter/Crashlytics
    [Fabric with:@[[Twitter class], [Crashlytics class]]];
    // 注册firebase
    [FIRApp configure];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification
                                               object:nil];
    // 注册AppsFlyer
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"vKsiczVKraASChBxaENvbe";
    [AppsFlyerTracker sharedTracker].appleAppID = @"1146695204";
    // 注册ShareSDK
    [self registerShareSDK];
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
#if DEBUG
//    _window = [[iConsoleWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = SSColor(0, 0, 0);
//    [iConsole sharedConsole].delegate = self;
//    [iConsole sharedConsole].logSubmissionEmail = @"1164063991@qq.com";
#else
    _window.backgroundColor = SSColor(255, 255, 255);
#endif
    [_window makeKeyAndVisible];
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    JTNavigationController *navCtrl = [[JTNavigationController alloc] initWithRootViewController:homeVC];
    // 设置根控制器
    _window.rootViewController = navCtrl;
    
    NSNumber *on = DEF_PERSISTENT_GET_OBJECT(SS_SPLASH_ON);
    if (on.integerValue) {
        // 开屏广告
        [self setupLaunchAd];
    }
    
//    //活动页面
//    NSString *launchImage = nil;
//    if (iPhone4) {
//        launchImage = @"LaunchImage-700";
//    } else if (iPhone5) {
//        launchImage = @"LaunchImage-700-568h";
//    } else if (iPhone6) {
//        launchImage = @"LaunchImage-800-667h";
//    } else if (iPhone6Plus) {
//        launchImage = @"LaunchImage-800-Portrait-736h";
//    }
//    UIImageView *launchView = [[UIImageView alloc] initWithFrame:self.window.bounds];
//    launchView.image = [UIImage imageNamed:launchImage];
//    launchView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.window addSubview:launchView];
//    SnowView *snowView = [[SnowView alloc] initWithFrame:self.window.bounds];
//    [launchView addSubview:snowView];
//    [snowView show];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:.5 animations:^{
//            launchView.alpha = 0;
//            snowView.alpha = 0;
//        } completion:^(BOOL finished) {
//            [snowView removeFromSuperview];
//            [launchView removeFromSuperview];
//        }];
//    });
    
    
    // 读取用户登录信息/配置信息
    [self loadUserData];
    // 监听网络状态
    [self networkMonitoring];
    // 注册通知
    [self registNotifications];
    // 开始定位
    [self locationServices];
    // 冷启动
    [self coldBoot:YES];
    // 创建图片文件夹
    [self createImageFolderAtPath];
    // 消除小红点
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.applicationIconBadgeNumber = -1;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
//    // 启动上报打点
//    NSString *logFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/log.data"];
//    NSMutableArray *logData = [NSKeyedUnarchiver unarchiveObjectWithFile:logFilePath];
//    if (logData.count > 0 && logData != nil) {
//        [self serverLogWithEventArray:logData];
//    }
    _eventArray = [NSMutableArray array];
    if (!on.integerValue) {
        //设置启动页面时间
        [NSThread sleepForTimeInterval:2.0];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    SSLog(@"进入不活跃状态");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    SSLog(@"进入后台");
    // FIRMessaging断开连接
    [[FIRMessaging messaging] disconnect];
    // 记录进入后台时间
    DEF_PERSISTENT_SET_OBJECT(@"BackgroundTime", [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]);
    // 打点-退出APP-010002
    JTNavigationController *navCtrl = (JTNavigationController *)_window.rootViewController;
    HomeViewController *homeVC = navCtrl.jt_viewControllers.firstObject;
    NSInteger index = homeVC.segmentVC.selectIndex - 10000;
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   homeVC.segmentVC.titleArray[index], @"channel",
                                   nil];
    [Flurry logEvent:@"App_Exit" withParameters:articleParams];
//    #if DEBUG
//    [iConsole info:[NSString stringWithFormat:@"App_Exit:%@",articleParams],nil];
//    #endif
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
    // 消除小红点
    UILocalNotification *notification=[[UILocalNotification alloc]init];
    notification.applicationIconBadgeNumber = -1;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    SSLog(@"处于活跃状态");
    // FIRMessaging连接
    [self connectToFcm];
    // 激活AppsFlyer
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
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
#pragma mark - 冷启动
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
//    [iConsole info:[NSString stringWithFormat:@"App_Lanch:%@",articleParams],nil];
    if (!isFirst) {
        [SVProgressHUD showInfoWithStatus:@"沙盒环境模式"];
    }
#endif
    // 设置IDFA（广告标识符）
    NSString *IDFA = DEF_PERSISTENT_GET_OBJECT(@"IDFA");
    if (!IDFA.length) {
        KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"IDFA" accessGroup:nil];
        IDFA = [keychain objectForKey:(id)kSecValueData];
        if (!IDFA.length) {
            IDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
            [keychain setObject:IDFA forKey:(__bridge id)kSecValueData];
        }
        DEF_PERSISTENT_SET_OBJECT(@"IDFA", IDFA);
    }
    
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
    __weak typeof(self) weakSelf = self;
    [[SSHttpRequest sharedInstance] get:@"" params:params contentType:UrlencodedType serverType:NetServer_Home success:^(id responseObj) {
        // 地址存入NSUserDefaults
        DEF_PERSISTENT_SET_OBJECT(Server_Home, responseObj[@"interfaces"][@"home"]);
        DEF_PERSISTENT_SET_OBJECT(Server_Log, responseObj[@"interfaces"][@"log"]);
        DEF_PERSISTENT_SET_OBJECT(Server_Mon, responseObj[@"interfaces"][@"mon"]);
        DEF_PERSISTENT_SET_OBJECT(Server_Referrer, responseObj[@"interfaces"][@"referrer"]);
        // 分类存入模型
        NSNumber *channelVersion = responseObj[@"channel_version"];
        NSNumber *currentVersion = DEF_PERSISTENT_GET_OBJECT(@"channel_version");
        if (currentVersion == nil || currentVersion.integerValue < channelVersion.integerValue) {
            // 请求下发频道
            if (!currentVersion) {
                [weakSelf getChannelWithVersion:channelVersion isFirst:YES];
            } else {
                [weakSelf getChannelWithVersion:channelVersion isFirst:NO];
            }
        }
        NSDictionary *splash = responseObj[@"ad"][@"splash"];
        NSNumber *on = splash[@"on"];
        DEF_PERSISTENT_SET_OBJECT(SS_SPLASH_ON, on);
        NSNumber *slot = splash[@"slot"];
        if (slot.integerValue > 0) {
            DEF_PERSISTENT_SET_OBJECT(SS_SPLASH_SLOT, slot);
        }
        NSNumber *stay_time = splash[@"stay_time"];
        if (stay_time.integerValue > 0 && stay_time.integerValue <= 5) {
            DEF_PERSISTENT_SET_OBJECT(SS_SPLASH_STAY_TIME, stay_time);
        }
        NSNumber *ad_time = splash[@"ad_time"];
        if (ad_time.integerValue > 0 && ad_time.integerValue <= 5) {
            DEF_PERSISTENT_SET_OBJECT(SS_SPLASH_AD_TIME, ad_time);
        }
        NSNumber *ad_ttl = splash[@"ad_ttl"];
        if (ad_ttl.integerValue > 0) {
            DEF_PERSISTENT_SET_OBJECT(SS_SPLASH_AD_TTL, ad_ttl);
        }
        NSNumber *reboot_time = splash[@"reboot_time"];
        if (reboot_time.integerValue > 0) {
            DEF_PERSISTENT_SET_OBJECT(SS_SPLASH_REBOOT_TIME, reboot_time);
        }
    } failure:^(NSError *error) {
        
    } isShowHUD:NO];
    
    // 检查是否有新广告
    [[FacebookAdManager sharedInstance] checkNewAdNumWithType:AllAd];
    [[FacebookAdManager sharedInstance] checkNewAdNumWithType:AllAd];
    // 更新搜索热词
    [self refreshHotwords];
}

- (void)refreshHotwords
{
    if (!self.hotwordsDic.count) {
        self.hotwordsDic = [NSMutableDictionary dictionary];
    }
    NSNumber *time = self.hotwordsDic[@"time"];
    if (!time || [[NSDate date] timeIntervalSince1970] - time.longLongValue > 3600 * 4) {
        __weak typeof(self) weakSelf = self;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:@10 forKey:@"size"];
        [[SSHttpRequest sharedInstance] get:kHomeUrl_NewsHotwords params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
            [weakSelf.hotwordsDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
            [weakSelf.hotwordsDic setObject:responseObj[@"hotwords"] forKey:@"hotwords"];
        } failure:nil isShowHUD:NO];
    }
}

#pragma mark - 请求下发频道
- (void)getChannelWithVersion:(NSNumber *)version isFirst:(BOOL)isFirst
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:version forKey:@"version"];
    [[SSHttpRequest sharedInstance] get:kHomeUrl_Channel params:params contentType:UrlencodedType serverType:NetServer_Home success:^(id responseObj) {
        NSMutableArray *categoryArray = [NSMutableArray array];
        for (NSDictionary *newDic in responseObj) {
            CategoriesModel *categoriesModel = [CategoriesModel mj_objectWithKeyValues:newDic];
            [categoryArray addObject:categoriesModel];
        }
        if (isFirst) {
            // 首次安装无频道
            _categoriesArray = categoryArray;
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Categories object:version];
        } else {
            NSMutableArray *newArray = [NSMutableArray array];
            // 查找是否有新频道
            for (CategoriesModel *newModel in categoryArray) {
                BOOL isNew = YES;
                for (CategoriesModel *model in _categoriesArray) {
                    if ([newModel.channelID isEqualToNumber:model.channelID]) {
                        isNew = NO;
                        break;
                    }
                }
                if (isNew) {
                    // 发现新频道
                    newModel.isNew = YES;
                    [newArray addObject:newModel];
                }
            }
            // 插入新频道
            for (CategoriesModel *newModel in newArray) {
                [_categoriesArray insertObject:newModel atIndex:newModel.index.integerValue];
            }
            if (newArray.count > 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_FindNewChannel object:nil];
            }
            // 查找是否有删除频道
            NSMutableArray *deleteArray = [NSMutableArray array];
            for (CategoriesModel *model in _categoriesArray) {
                BOOL isHave = NO;
                for (CategoriesModel *newModel in categoryArray) {
                    if ([newModel.channelID isEqualToNumber:model.channelID]) {
                        isHave = YES;
                        break;
                    }
                }
                if (!isHave) {
                    // 发现删除频道
                    [deleteArray addObject:model];
                }
            }
            // 删除频道
            if (deleteArray.count <= 3) {
                for (CategoriesModel *model in deleteArray) {
                    [_categoriesArray removeObject:model];
                }
            }
            if (newArray.count > 0 || deleteArray.count > 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Categories object:version];
                return;
            }
            // 判断是否有调整顺序
            if (_categoriesArray.count == categoryArray.count) {
                for (int i = 0; i < _categoriesArray.count; i++) {
                    CategoriesModel *model = _categoriesArray[i];
                    CategoriesModel *newModel = categoryArray[i];
                    if (![model.channelID isEqualToNumber:newModel.channelID]) {
                        _categoriesArray = categoryArray;
                        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Categories object:version];
                    }
                }
            }
        }
    } failure:^(NSError *error) {
        
    } isShowHUD:NO];
}

#pragma mark - Notifications
/**
 *  注册通知
 */
- (void)registNotifications
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
    }
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    NSString *refreshedToken = DEF_PERSISTENT_GET_OBJECT(@"refreshToken");
    if (refreshedToken.length) {
        [self uploadRefreshedToken:refreshedToken];
    }
}
// 注册deviceToken成功
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    SSLog(@"%@", deviceToken);
}
// 注册deviceToken失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    SSLog(@"%@", error);
}
// 刷新推送token回调
- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    SSLog(@"InstanceID token: %@", refreshedToken);
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
    if (refreshedToken.length) {
        DEF_PERSISTENT_SET_OBJECT(@"refreshToken", refreshedToken);
        [self uploadRefreshedToken:refreshedToken];
    }
}
- (void)connectToFcm {
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            SSLog(@"Unable to connect to FCM. %@", error);
        } else {
            SSLog(@"Connected to FCM.");
        }
    }];
}
/**
 *  绑定PushToken
 *
 *  @param refreshedToken 刷新token
 */
- (void)uploadRefreshedToken:(NSString *)refreshedToken
{
    NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSString stringWithFormat:@"v%@",version] forKey:@"client_version"];
    __weak typeof(self) weakSelf = self;
    [[SSHttpRequest sharedInstance] get:kHomeUrl_CheckEarlier params:params contentType:JsonType serverType:NetServer_Check success:^(id responseObj) {
        NSArray *versions = responseObj[@"belows"];
        if (versions.count > 0) {
            // 取消注册topics
            for (NSString *subVersion in versions) {
                [[FIRMessaging messaging] unsubscribeFromTopic:[NSString stringWithFormat:@"/topics/ios_%@",subVersion]];
            }
            // 注册topics
            [[FIRMessaging messaging] subscribeToTopic:@"/topics/notification"];
            [[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/ios_v%@",version]];
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:refreshedToken forKey:@"token"];
            [params setObject:@"ios" forKey:@"os"];
            [params setObject:@"apple" forKey:@"vendor"];
            [params setObject:DEF_PERSISTENT_GET_OBJECT(@"IDFA") forKey:@"ios_did"];
            [params setObject:[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemVersion]] forKey:@"os_version"];
            [[SSHttpRequest sharedInstance] post:kHomeUrl_Push params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
                DEF_PERSISTENT_SET_OBJECT(@"refreshToken", @"");
            } failure:^(NSError *error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf uploadRefreshedToken:refreshedToken];
                });
            } isShowHUD:NO];
        }
    } failure:^(NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf uploadRefreshedToken:refreshedToken];
        });
    } isShowHUD:NO];
}
// 收到推送回调
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    SSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    SSLog(@"userInfo: %@", userInfo);
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    NSNumber *type = userInfo[@"type"];
    switch (type.integerValue) {
        case 1:
        {
            if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
                return;
            }
            // 普通推送消息
            if (userInfo[@"news_id"]) {
                if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                    // 在前台时收到推送
                    NSString *title = @"Breaking News";
                    NSString *message = userInfo[@"aps"][@"alert"];
                    UIAlertController *notificationAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Do not care" style:UIAlertActionStyleDefault handler:nil];
                    __weak typeof(self) weakSelf = self;
                    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Go to veiw" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        [weakSelf pushEnterWithUserInfo:userInfo];
                    }];
                    [notificationAlert addAction:noAction];
                    [notificationAlert addAction:yesAction];
                    [_window.rootViewController presentViewController:notificationAlert animated:YES completion:nil];
                } else {
                    // 在后台收到推送
                    [self pushEnterWithUserInfo:userInfo];
                }
            }
            break;
        }
        case 3:
        {
            // 透传推送消息
            NSString *refreshedToken = [[FIRInstanceID instanceID] token];
            if (refreshedToken.length) {
                DEF_PERSISTENT_SET_OBJECT(@"refreshToken", refreshedToken);
                [self uploadRefreshedToken:refreshedToken];
            }
            break;
        }
        case 4:
        {
            NSString *user_id = userInfo[@"user_id"];
            if (user_id && [self.model.user_id isEqualToString:user_id]) {
                // 检查是否有新通知
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CheckNewNotif object:nil];
            }
        }
        case 5:
        {
            NSString *user_id = userInfo[@"user_id"];
            if (user_id && [self.model.user_id isEqualToString:user_id]) {
                // 检查是否有新通知
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CheckNewNotif object:nil];
            }
        }
        default:
            break;
    }
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // 应用在前台收到通知
    SSLog(@"========%@", notification);
    // 如果需要在应用在前台也展示通知
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // 点击通知进入应用
    SSLog(@"response:%@", response);
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSNumber *type = userInfo[@"type"];
    switch (type.integerValue) {
        case 1:
        {
            // 普通推送消息
            if (userInfo[@"news_id"]) {
                [self pushEnterWithUserInfo:userInfo];
            }
            break;
        }
        case 3:
        {
            // 透传推送消息
            NSString *refreshedToken = [[FIRInstanceID instanceID] token];
            if (refreshedToken.length) {
                DEF_PERSISTENT_SET_OBJECT(@"refreshToken", refreshedToken);
                [self uploadRefreshedToken:refreshedToken];
            }
            break;
        }
        default:
            break;
    }
}
// 服务器打点并跳转到详情页
- (void)pushEnterWithUserInfo:(NSDictionary *)userInfo
{
    // 消除小红点
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.applicationIconBadgeNumber = -1;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    // 服务器打点-用户从推送点击详情页-020105
    NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
    [eventDic setObject:@"020105" forKey:@"id"];
    [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
    [eventDic setObject:userInfo[@"news_id"] forKey:@"news_id"];
    [eventDic setObject:userInfo[@"push_id"] forKey:@"push_id"];
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
        [_eventArray addObject:eventDic];
    } isShowHUD:NO];
    
    NewsModel *model = [[NewsModel alloc] init];
    model.news_id = userInfo[@"news_id"];
    if (model.news_id == nil) {
        return;
    }
    JTNavigationController *navCtrl = (JTNavigationController *)_window.rootViewController;
    HomeViewController *homeVC = navCtrl.jt_viewControllers.firstObject;
    NSNumber *tpl = userInfo[@"tpl"];
    switch (tpl.integerValue) {
        case 2:
        {
            NewsDetailViewController *newsDetailVC = [[NewsDetailViewController alloc] init];
            newsDetailVC.model = model;
            newsDetailVC.isPushEnter = YES;
            [homeVC.navigationController pushViewController:newsDetailVC animated:NO];
            return;
        }
        case 3:
        {
            VideoDetailViewController *videoDetailVC = [[VideoDetailViewController alloc] init];
            videoDetailVC.model = model;
            videoDetailVC.isPushEnter = YES;
            videoDetailVC.isNoModel = YES;
            [homeVC.navigationController pushViewController:videoDetailVC animated:YES];
            return;
        }
        case 4:
        {
            GifDetailViewController *gifDetailVC = [[GifDetailViewController alloc] init];
            gifDetailVC.model = model;
            gifDetailVC.isNoModel = YES;
            [homeVC.navigationController pushViewController:gifDetailVC animated:NO];
            return;
        }
        case 5:
        {
            PicDetailViewController *picDetail = [[PicDetailViewController alloc] init];
            picDetail.model = model;
            [homeVC.navigationController pushViewController:picDetail animated:NO];
            return;
        }
        default:
            break;
    }
}
#pragma mark - 监听网络状态
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
#pragma mark - 获取定位信息
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
#pragma mark - 读取用户信息
/**
 *  读取用户登录信息/配置信息
 */
- (void)loadUserData
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @autoreleasepool {
            // 上传安装ID
            NSString *referrerID = DEF_PERSISTENT_GET_OBJECT(@"referrer");
            if (!referrerID.length) {
                referrerID = [[NSUUID UUID] UUIDString];
                [self uploadReferrerWithReferrerID:referrerID];
            }
            // 加载频道列表
            NSString *categoryFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/category.data"];
            _categoriesArray = [NSKeyedUnarchiver unarchiveObjectWithFile:categoryFilePath];
            // 加载登录信息
            NSString *loginFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userinfo.data"];
            _model = [NSKeyedUnarchiver unarchiveObjectWithFile:loginFilePath];
            // 加载点赞记录
            _likedDic = [NSMutableDictionary dictionary];
            NSString *likeFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/like.data"];
            NSDictionary *likeData = [NSKeyedUnarchiver unarchiveObjectWithFile:likeFilePath];
            NSNumber *likeKey = likeData.allKeys.firstObject;
            if (likeData) {
                _likedDic = likeData[likeKey];
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
//#if DEBUG
//        [iConsole info:@"LowDataTips_No_Click",nil];
//#endif
    }];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes,Please" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 打点-点击无图模式提醒对话框中YES选项-010010
        [Flurry logEvent:@"LowDataTips_YES_Click"];
//#if DEBUG
//        [iConsole info:@"LowDataTips_YES_Click",nil];
//#endif
        DEF_PERSISTENT_SET_OBJECT(SS_textOnlyMode, @1);
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_TextOnly_ON object:nil];
    }];
    [textOnlyAlert addAction:noAction];
    [textOnlyAlert addAction:yesAction];
    [self.window.rootViewController presentViewController:textOnlyAlert animated:YES completion:nil];
}
#pragma mark - 服务端打点上报
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
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:sessions forKey:@"sessions"];
        [[SSHttpRequest sharedInstance] post:@"" params:params contentType:JsonType serverType:NetServer_Log success:^(id responseObj) {
            // 打点成功
            [weakSelf serverLogWithEventArray:eventArray];
        } failure:^(NSError *error) {
            // 打点失败
            [weakSelf serverLogWithEventArray:eventArray];
        } isShowHUD:NO];
    }
}

// 安装上报
- (void)uploadReferrerWithReferrerID:(NSString *)referrerID
{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSString stringWithFormat:@"install_id=%@",referrerID] forKey:@"referrer"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [params setObject:[NSString stringWithFormat:@"v%@",version] forKey:@"version"];
    [[SSHttpRequest sharedInstance] post:@"" params:params contentType:JsonType serverType:NetServer_Referrer success:^(id responseObj) {
        DEF_PERSISTENT_SET_OBJECT(@"referrer", referrerID);
    } failure:^(NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf uploadReferrerWithReferrerID:referrerID];
        });
    } isShowHUD:NO];
}

//- (void)handleConsoleCommand:(NSString *)command
//{
//    if ([command isEqualToString:@"version"])
//    {
//        [iConsole info:@"%@ version %@",
//         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"],
//         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
//    }
//    else
//    {
//        [iConsole error:@"unrecognised command, try 'version' instead"];
//    }
//}
#pragma mark - 缓存管理
// 内存警告
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
        NSString *newsFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/news.data"];
        // 取旧新闻数据
        NSDictionary *oldNewsData = [NSKeyedUnarchiver unarchiveObjectWithFile:newsFilePath];
        NSNumber *oldNewsDataKey = oldNewsData.allKeys.firstObject;

        JTNavigationController *navCtrl = (JTNavigationController *)_window.rootViewController;
        HomeViewController *homeVC = navCtrl.jt_viewControllers.firstObject;
        // 缓存新闻列表
        NSMutableDictionary *newsDic = [NSMutableDictionary dictionary];
        for (HomeTableViewController *homeTabVC in homeVC.segmentVC.subViewControllers) {
            if (homeTabVC.dataList.count > 0) {
                // 有新数据
                NSInteger length = 30;
                if (homeTabVC.dataList.count > length) {
                    NSMutableArray *listArray = [NSMutableArray arrayWithArray:[homeTabVC.dataList subarrayWithRange:NSMakeRange(0, length)]];
                    for (NewsModel *model in [listArray copy]) {
                        if (model && [model isKindOfClass:[NewsModel class]] && model.nativeAd) {
                            [listArray removeObject:model];
                        }
                    }
                    [newsDic setObject:listArray forKey:homeTabVC.model.channelID];
                } else {
                    NSMutableArray *listArray = [NSMutableArray arrayWithArray:homeTabVC.dataList];
                    for (NewsModel *model in [listArray copy]) {
                        if (model && [model isKindOfClass:[NewsModel class]] && model.nativeAd) {
                            [listArray removeObject:model];
                        }
                    }
                    [newsDic setObject:listArray forKey:homeTabVC.model.channelID];
                }
            } else {
                // 无新数据
                NSArray *dataList = oldNewsData[oldNewsDataKey][homeTabVC.model.channelID];
                if (dataList.count) {
                    [newsDic setObject:dataList forKey:homeTabVC.model.channelID];
                }
            }
        }
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
        // 缓存开屏广告
        NSString *launchAdFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/launchAd.data"];
        if ([LaunchAdManager sharedInstance].launchAdArray && [LaunchAdManager sharedInstance].checkDic) {
            NSDictionary *launchAdDic = @{@"launchAdArray":[LaunchAdManager sharedInstance].launchAdArray,
                                          @"checkDic":[LaunchAdManager sharedInstance].checkDic};
            [NSKeyedArchiver archiveRootObject:launchAdDic toFile:launchAdFilePath];
        }
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options
{
    if ([[Twitter sharedInstance] application:app openURL:url options:options]) {
        return YES;
    }
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

// 全屏播放支持横屏
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    //    if ([NSStringFromClass([[[window subviews] lastObject] class]) isEqualToString:@"UITransitionView"]) {
    //        return UIInterfaceOrientationMaskAll;
    //    }
    if ([NSStringFromClass([window.subviews.firstObject.subviews.firstObject class]) isEqualToString:@"AVPlayerView"]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

@end
