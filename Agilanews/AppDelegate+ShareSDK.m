//
//  AppDelegate+ShareSDK.m
//  Agilanews
//
//  Created by 张思思 on 16/7/19.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "AppDelegate+ShareSDK.h"

@implementation AppDelegate (ShareSDK)

- (void)registerShareSDK
{
    /**
     *  设置ShareSDK的appKey
     *  在将生成的AppKey传入到此方法中。
     *  方法中的第二个第三个参数为需要连接社交平台SDK时触发，
     *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
     *  如果您使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
     */
    
    [ShareSDK registerApp:@"1520692e50787"
          activePlatforms:@[
                            @(SSDKPlatformTypeFacebook),
                            @(SSDKPlatformTypeTwitter),
                            @(SSDKPlatformTypeGooglePlus)]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
//             case SSDKPlatformTypeFacebook:
//                 [ShareSDKConnector connectFacebookMessenger:[FBSDKMessengerSharer class]];
//                 break;
//             case SSDKPlatformTypeQQ:
//                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
//                 break;
//             case SSDKPlatformTypeSinaWeibo:
//                 [ShareSDKConnector connectWeibo:[WeiboSDK class]];
//                 break;
//             case SSDKPlatformTypeRenren:
//                 [ShareSDKConnector connectRenren:[RennClient class]];
//                 break;
//             case SSDKPlatformTypeGooglePlus:
//                 [ShareSDKConnector connectGooglePlus:[GPPSignIn class]
//                                           shareClass:[GPPShare class]];
//                 break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeFacebook:
                 [appInfo SSDKSetupFacebookByApiKey:@"1188655531159250"
                                          appSecret:@"fa3aaac3805c9b004bfec6dac06d0e7d"
                                           authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeTwitter:
                 [appInfo SSDKSetupTwitterByConsumerKey:@"AYjlOtTLN2fsKfuqgjPYh76IK"
                            consumerSecret:@"KnsnE9olzbTAIShqTaxttRJIizwEWMV6kolFUb5lHYmUKSCfRX"
                                            redirectUri:@"http://www.agilanews.com"];
                 break;
             case SSDKPlatformTypeGooglePlus:
                 [appInfo SSDKSetupGooglePlusByClientID:@"220913118121-tsfqho6sgkbh2frs2k8h3kludcnnunf1.apps.googleusercontent.com"
                                           clientSecret:@""
                                            redirectUri:@"http://www.agilanews.com"];
                 break;
             default:
                 break;
         }
     }];
}

@end
