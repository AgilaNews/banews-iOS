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
#import "iConsole.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate,iConsoleDelegate>

#if DEBUG
@property (strong, nonatomic) iConsoleWindow *window; //这是关键，必须使用iConsoleWindow
#else
@property (strong, nonatomic) UIWindow *window;
#endif
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *categoriesArray;
@property (strong, nonatomic) LoginModel *model;
@property (strong, nonatomic) NSMutableDictionary *likedDic;        // 点赞记录
@property (strong, nonatomic) NSMutableDictionary *checkDic;        // 新闻查看记录
@property (strong, nonatomic) NSMutableArray *eventArray;           // 打点记录
@property (strong, nonatomic) NSMutableDictionary *refreshTimeDic;  // 刷新时间

@end

