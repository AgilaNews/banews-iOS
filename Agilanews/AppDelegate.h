//
//  AppDelegate.h
//  Agilanews
//
//  Created by 张思思 on 16/7/12.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoriesModel.h"
#import "LoginModel.h"
//#import "iConsole.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate>

//#if DEBUG
//@property (strong, nonatomic) iConsoleWindow *window; //这是关键，必须使用iConsoleWindow
//#else
//#endif
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *categoriesArray;
@property (strong, nonatomic) LoginModel *model;
@property (strong, nonatomic) NSMutableDictionary *likedDic;        // 点赞记录
@property (strong, nonatomic) NSMutableDictionary *checkDic;        // 新闻查看记录
@property (strong, nonatomic) NSMutableArray *eventArray;           // 打点记录
@property (strong, nonatomic) NSMutableDictionary *refreshTimeDic;  // 刷新时间
@property (strong, nonatomic) NSMutableDictionary *hotwordsDic;     // 热词记录
@property (strong, nonatomic) LaunchAdModel *launchAdModel;
@property (assign, nonatomic) long long launchAdShowTime;           // 开屏广告展示时间
@property (assign, nonatomic) BOOL isStart;                         // 启动状态

@end

