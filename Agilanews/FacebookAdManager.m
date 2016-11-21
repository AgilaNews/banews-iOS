//
//  FacebookAdManager.m
//  Agilanews
//
//  Created by 张思思 on 16/11/11.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "FacebookAdManager.h"

#if DEBUG
#define kListPlacementID    @"1188655531159250_1397507120274089"
#define kDetailPlacementID  @"YOUR_PLACEMENT_ID"
#else
#define kListPlacementID    @"1188655531159250_1397507120274089"
#define kDetailPlacementID  @"1188655531159250_1397507606940707"
#endif

@implementation FacebookAdManager

static FacebookAdManager *_manager = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[FacebookAdManager alloc] init];
        _manager.newadListArray = [NSMutableArray array];
        _manager.oldadListArray = [NSMutableArray array];
        _manager.newadDetailArray = [NSMutableArray array];
        _manager.oldadDetailArray = [NSMutableArray array];
    });
    return _manager;
}

- (void)loadNativeAdWithPlacementID:(NSString *)placementID
{
    // Create a native ad request with a unique placement ID (generate your own on the Facebook app settings).
    // Use different ID for each ad placement in your app.
    FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID:placementID];
    
    // Set a delegate to get notified when the ad was loaded.
    nativeAd.delegate = self;
    
    // Configure native ad to wait to call nativeAdDidLoad: until all ad assets are loaded
    nativeAd.mediaCachePolicy = FBNativeAdsCachePolicyCoverImage;
    
    // When testing on a device, add its hashed ID to force test ads.
    // The hash ID is printed to console when running on a device.
    [FBAdSettings addTestDevice:@"e94e40bf9ef497a17ada25682e65ef02d18e23ae"];
    
    // Initiate a request to load an ad.
    [nativeAd loadAd];
}

// 检查新广告数组是否足够，不够自动填充
- (void)checkNewAdNumWithType:(AdsType)adsType
{
    switch (adsType) {
        case ListAd:
        {
            if (self.newadListArray.count < 3) {
                [self loadNativeAdWithPlacementID:kListPlacementID];
            }
            break;
        }
        case DetailAd:
        {
            if (self.newadDetailArray.count < 3) {
                [self loadNativeAdWithPlacementID:kDetailPlacementID];
            }
            break;
        }
        case AllAd:
        {
            if (self.newadListArray.count < 3) {
                [self loadNativeAdWithPlacementID:kListPlacementID];
            }
            if (self.newadDetailArray.count < 3) {
                [self loadNativeAdWithPlacementID:kDetailPlacementID];
            }
        }
        default:
            break;
    }
}

#pragma mark - FBNativeAdDelegate
- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd
{
    if ([nativeAd.placementID isEqualToString:kListPlacementID]) {
        // 列表广告
        if (!self.newadListArray) {
            self.newadListArray = [NSMutableArray array];
        }
        NSMutableArray *adArray = [self.newadListArray copy];
        BOOL isHaveAd = NO;
        for (FBNativeAd *ad in adArray) {
            if ([ad.coverImage.url.absoluteString isEqualToString:nativeAd.coverImage.url.absoluteString]) {
                isHaveAd = YES;
            }
        }
        if (!isHaveAd) {
            [self.newadListArray addObject:nativeAd];
        }
    } else {
        // 详情广告
        if (!self.newadDetailArray) {
            self.newadDetailArray = [NSMutableArray array];
        }
        NSMutableArray *adArray = [self.newadDetailArray copy];
        BOOL isHaveAd = NO;
        for (FBNativeAd *ad in adArray) {
            if ([ad.coverImage.url.absoluteString isEqualToString:nativeAd.coverImage.url.absoluteString]) {
                isHaveAd = YES;
            }
        }
        if (!isHaveAd) {
            [self.newadDetailArray addObject:nativeAd];
        }
    }
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error
{
    SSLog(@"广告加载失败: %@", error);
}


/**
 获取列表广告

 @return 返回广告
 */
- (FBNativeAd *)getFBNativeAdFromListADArray
{
    if (self.newadListArray && self.newadListArray.count > 0) {
        // 取新广告
        FBNativeAd *nativeAd = [[FBNativeAd alloc] init];
        nativeAd = self.newadListArray.firstObject;
        if (!self.oldadListArray) {
            self.oldadListArray = [NSMutableArray array];
        }
        NSMutableArray *adArray = [self.oldadListArray copy];
        BOOL isHaveAd = NO;
        for (FBNativeAd *ad in adArray) {
            if ([ad.coverImage.url.absoluteString isEqualToString:nativeAd.coverImage.url.absoluteString]) {
                isHaveAd = YES;
            }
        }
        if (!isHaveAd) {
            if (self.oldadListArray.count >= 10) {
                [self.oldadListArray removeObjectAtIndex:0];
            }
            [self.oldadListArray addObject:nativeAd];
        }
        [self.newadListArray removeObjectAtIndex:0];
        // 检查新广告
        [self checkNewAdNumWithType:ListAd];
        return nativeAd;
    } else if (self.oldadListArray && self.oldadListArray.count > 0) {
        // 取旧广告
        FBNativeAd *nativeAd = [[FBNativeAd alloc] init];
        nativeAd = self.oldadListArray.firstObject;
        [self.oldadListArray removeObjectAtIndex:0];
        [self.oldadListArray addObject:nativeAd];
        // 检查新广告
        [self checkNewAdNumWithType:ListAd];
        return nativeAd;
    }
    return nil;
}

/**
 获取详情广告
 
 @return 返回广告
 */
- (FBNativeAd *)getFBNativeAdFromDetailADArray
{
    if (self.newadDetailArray && self.newadDetailArray.count > 0) {
        // 取新广告
        FBNativeAd *nativeAd = [[FBNativeAd alloc] init];
        nativeAd = self.newadDetailArray.firstObject;
        if (!self.oldadDetailArray) {
            self.oldadDetailArray = [NSMutableArray array];
        }
        NSMutableArray *adArray = [self.oldadDetailArray copy];
        BOOL isHaveAd = NO;
        for (FBNativeAd *ad in adArray) {
            if ([ad.coverImage.url.absoluteString isEqualToString:nativeAd.coverImage.url.absoluteString]) {
                isHaveAd = YES;
            }
        }
        if (!isHaveAd) {
            if (self.oldadDetailArray.count >= 10) {
                [self.oldadDetailArray removeObjectAtIndex:0];
            }
            [self.oldadDetailArray addObject:nativeAd];
        }
        [self.newadDetailArray removeObjectAtIndex:0];
        // 检查新广告
        [self checkNewAdNumWithType:DetailAd];
        return nativeAd;
    } else if (self.oldadDetailArray && self.oldadDetailArray.count > 0) {
        // 取旧广告
        FBNativeAd *nativeAd = [[FBNativeAd alloc] init];
        nativeAd = self.oldadDetailArray.firstObject;
        [self.oldadDetailArray removeObjectAtIndex:0];
        [self.oldadDetailArray addObject:nativeAd];
        // 检查新广告
        [self checkNewAdNumWithType:DetailAd];
        return nativeAd;
    }
    return nil;
}



@end
