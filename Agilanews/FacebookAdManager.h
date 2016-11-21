//
//  FacebookAdManager.h
//  Agilanews
//
//  Created by 张思思 on 16/11/11.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>

//@protocol FacebookAdManagerDelegate <NSObject>
//- (void)facebookAdsLoadedWithManager:(FBNativeAdsManager *)manager;
//@end
typedef enum : NSUInteger {
    ListAd,
    DetailAd,
    AllAd,
} AdsType;

@interface FacebookAdManager : NSObject <FBNativeAdDelegate>

@property (nonatomic, assign) AdsType adsType;

// 列表广告数组
@property (atomic, strong) NSMutableArray *newadListArray;
@property (atomic, strong) NSMutableArray *oldadListArray;

// 详情广告数组
@property (atomic, strong) NSMutableArray *newadDetailArray;
@property (atomic, strong) NSMutableArray *oldadDetailArray;

+ (instancetype)sharedInstance;

- (void)checkNewAdNumWithType:(AdsType)adsType;
- (FBNativeAd *)getFBNativeAdFromListADArray;
- (FBNativeAd *)getFBNativeAdFromDetailADArray;

@end
