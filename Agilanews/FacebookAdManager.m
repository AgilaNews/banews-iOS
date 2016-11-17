//
//  FacebookAdManager.m
//  Agilanews
//
//  Created by 张思思 on 16/11/11.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "FacebookAdManager.h"

@implementation FacebookAdManager

- (void)loadNativeAd
{
    if (!self.adsManager) {
        // Create a native ad manager with a unique placement ID (generate your own on the Facebook app settings)
        // and how many ads you would like to create. Note that you may get fewer ads than you ask for.
        // Use different ID for each ad placement in your app.
        self.adsManager = [[FBNativeAdsManager alloc] initWithPlacementID:@"YOUR_PLACEMENT_ID"
                                                        forNumAdsRequested:5];
        // Set a delegate to get notified when the ads are loaded.
        self.adsManager.delegate = self;
        
        // Configure native ad manager to wait to call nativeAdsLoaded until all ad assets are loaded
        self.adsManager.mediaCachePolicy = FBNativeAdsCachePolicyAll;
        
        // When testing on a device, add its hashed ID to force test ads.
        // The hash ID is printed to console when running on a device.
        // [FBAdSettings addTestDevice:@"THE HASHED ID AS PRINTED TO CONSOLE"];
    }
    
    // Load some ads
    [self.adsManager loadAds];
}

#pragma mark - FBNativeAdsManagerDelegate implementation
- (void)nativeAdsLoaded
{
    NSLog(@"%@",self.adsManager);
}
- (void)nativeAdsFailedToLoadWithError:(NSError *)error
{
    
}
@end
