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

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *categoriesArray;
@property (strong, nonatomic) LoginModel *model;
@property (strong, nonatomic) NSMutableDictionary *likedDic;    // 点赞记录
@property (strong, nonatomic) NSMutableDictionary *checkDic;    // 新闻查看记录
@property (strong, nonatomic) NSMutableArray *eventArray;       // 打点记录

@end

