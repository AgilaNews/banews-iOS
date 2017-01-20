//
//  LaunchAdManager.m
//  Agilanews
//
//  Created by 张思思 on 17/1/13.
//  Copyright © 2017年 banews. All rights reserved.
//

#import "LaunchAdManager.h"

@implementation LaunchAdManager

static LaunchAdManager *_manager = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[LaunchAdManager alloc] init];
        _manager.launchAdArray = [NSMutableArray array];
        NSString *launchAdFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/launchAd.data"];
        NSDictionary *launchAdDic = [NSKeyedUnarchiver unarchiveObjectWithFile:launchAdFilePath];
        _manager.launchAdArray = launchAdDic[@"launchAdArray"];
        _manager.checkDic = launchAdDic[@"checkDic"];
    });
    return _manager;
}

// 加载广告数据
- (void)loadLaunchAdData
{
    // 判断广告是否过期
    NSNumber *ad_ttl = DEF_PERSISTENT_GET_OBJECT(SS_SPLASH_AD_TTL);
    NSNumber *get_time = DEF_PERSISTENT_GET_OBJECT(SS_SPLASH_GET_TIME);
    if ([[NSDate date] timeIntervalSince1970] - get_time.longLongValue > ad_ttl.longLongValue) {
        // 广告过期
        __weak typeof(self) weakSelf = self;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSNumber *slot = DEF_PERSISTENT_GET_OBJECT(SS_SPLASH_SLOT);
        if (slot && slot.integerValue > 0) {
            [params setObject:slot forKey:@"pn"];
        } else {
            [params setObject:@3 forKey:@"pn"];
        }
        [[SSHttpRequest sharedInstance] get:kHomeUrl_Splash params:params contentType:UrlencodedType serverType:NetServer_V3 success:^(id responseObj) {
            for (NSDictionary *dic in responseObj[@"ads"]) {
                LaunchAdModel *model = [LaunchAdModel mj_objectWithKeyValues:dic];
                DEF_PERSISTENT_SET_OBJECT(SS_SPLASH_GET_TIME, [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]);
                NSInteger find = 0;
                for (LaunchAdModel *ad in weakSelf.launchAdArray) {
                    if ([ad.dataid isEqualToString:model.dataid]) {
                        find = 1;
                    }
                }
                if (!find) {
                    if (!weakSelf.launchAdArray) {
                        weakSelf.launchAdArray = [NSMutableArray array];
                    }
                    [weakSelf.launchAdArray addObject:model];
                    NSString *imageUrl = [model.image stringByReplacingOccurrencesOfString:@"{w}" withString:[NSString stringWithFormat:@"%d",(int)(kScreenWidth * 2)]];
                    imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{h}" withString:[NSString stringWithFormat:@"%d",(int)(kScreenHeight * .81 * 2)]];
                    [[XHLaunchAdImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imageUrl] options:XHLaunchAdImageCacheInBackground progress:^(unsigned long long total, unsigned long long current) {
//                        SSLog(@"+++++++%llu",current);
                    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, NSURL * _Nullable imageURL) {
                        SSLog(@"-------%@",image);
                    }];
                }
            }
        } failure:nil isShowHUD:NO];
    }
}

// 请求广告数据
- (void)getLaunchAdData:(NetworkSucess)success
{
    // 判断广告是否过期
    NSNumber *ad_ttl = DEF_PERSISTENT_GET_OBJECT(SS_SPLASH_AD_TTL);
    NSNumber *get_time = DEF_PERSISTENT_GET_OBJECT(SS_SPLASH_GET_TIME);
    if ([[NSDate date] timeIntervalSince1970] - get_time.longLongValue > ad_ttl.longLongValue) {
        // 广告过期
        __weak typeof(self) weakSelf = self;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSNumber *slot = DEF_PERSISTENT_GET_OBJECT(SS_SPLASH_SLOT);
        if (slot && slot.integerValue > 0) {
            [params setObject:slot forKey:@"pn"];
        } else {
            [params setObject:@3 forKey:@"pn"];
        }
        [[SSHttpRequest sharedInstance] get:kHomeUrl_Splash params:params contentType:UrlencodedType serverType:NetServer_V3 success:^(id responseObj) {
            for (NSDictionary *dic in responseObj[@"ads"]) {
                LaunchAdModel *model = [LaunchAdModel mj_objectWithKeyValues:dic];
                DEF_PERSISTENT_SET_OBJECT(SS_SPLASH_GET_TIME, [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]);
                NSInteger find = 0;
                for (LaunchAdModel *ad in weakSelf.launchAdArray) {
                    if ([ad.dataid isEqualToString:model.dataid]) {
                        find = 1;
                    }
                }
                if (!find) {
                    if (!weakSelf.launchAdArray) {
                        weakSelf.launchAdArray = [NSMutableArray array];
                    }
                    [weakSelf.launchAdArray addObject:model];
                }
            }
            if (weakSelf.launchAdArray.count) {
                LaunchAdModel *ad = [weakSelf.launchAdArray objectAtIndex:(arc4random() % weakSelf.launchAdArray.count)];
                NSNumber *count = [weakSelf.checkDic valueForKey:ad.dataid];
                if (count && count > 0) {
                    count = [NSNumber numberWithInteger:count.integerValue + 1];
                } else {
                    count = @1;
                }
                if (!weakSelf.checkDic) {
                    weakSelf.checkDic = [NSMutableDictionary dictionary];
                }
                [weakSelf.checkDic setObject:count forKey:ad.dataid];
                success(ad);
            } else {
                success(nil);
            }
        } failure:nil isShowHUD:NO];
    } else {
        // 广告未过期
        for (NSString *key in self.checkDic.allKeys) {
            NSNumber *count = [self.checkDic valueForKey:key];
            NSArray *ads = [self.launchAdArray copy];
            for (LaunchAdModel *ad in ads) {
                if ([ad.dataid isEqualToString:key]) {
                    if (count.integerValue >= ad.display.integerValue) {
                        for (LaunchAdModel *ad in ads) {
                            if ([ad.dataid isEqualToString:key]) {
                                [self.launchAdArray removeObject:ad];
                            }
                        }
                    }
                }
            }
        }
        if (self.launchAdArray.count) {
            LaunchAdModel *ad = [self.launchAdArray objectAtIndex:(arc4random() % self.launchAdArray.count)];
            NSNumber *count = [self.checkDic valueForKey:ad.dataid];
            if (count && count > 0) {
                count = [NSNumber numberWithInteger:count.integerValue + 1];
            } else {
                count = @1;
            }
            if (!self.checkDic) {
                self.checkDic = [NSMutableDictionary dictionary];
            }
            [self.checkDic setObject:count forKey:ad.dataid];
            success(ad);
        } else {
            success(nil);
        }
    }
}

@end
