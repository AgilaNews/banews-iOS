//
//  FacebookAdManager.h
//  Agilanews
//
//  Created by 张思思 on 16/11/11.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookAdManager : NSObject <FBNativeAdsManagerDelegate>

@property (strong, nonatomic) FBNativeAdsManager *adsManager;

- (void)loadNativeAd;

@end
