//
//  LaunchAdManager.h
//  Agilanews
//
//  Created by 张思思 on 17/1/13.
//  Copyright © 2017年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LaunchAdModel.h"

typedef void(^NetworkSucess) (LaunchAdModel *model);

@interface LaunchAdManager : NSObject

@property (nonatomic, strong) NSMutableArray *launchAdArray;
@property (nonatomic, strong) NSMutableDictionary *checkDic;

+ (instancetype)sharedInstance;
- (void)getLaunchAdData:(NetworkSucess)success;

@end
