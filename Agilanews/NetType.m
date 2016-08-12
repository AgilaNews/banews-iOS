//
//  NetType.m
//  Agilanews
//
//  Created by 张思思 on 16/8/8.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "NetType.h"

@implementation NetType

+ (NSString *)getNetType
{
    CTTelephonyNetworkInfo *networInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *netType = networInfo.currentRadioAccessTechnology;
    if ([@"WiFi" isEqualToString:DEF_PERSISTENT_GET_OBJECT(@"netStatus")]) {
        return @"wifi";
    } else {
        if ([netType isEqualToString:@"CTRadioAccessTechnologyGPRS"] || [netType isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
            return @"2G";
        } else if ([netType isEqualToString:@"CTRadioAccessTechnologyHSDPA"] || [netType isEqualToString:@"CTRadioAccessTechnologyWCDMA"] || [netType isEqualToString:@"CTRadioAccessTechnologyHSUPA"] || [netType isEqualToString:@"CTRadioAccessTechnologyCDMA1x"] || [netType isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"] || [netType isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"] || [netType isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"] || [netType isEqualToString:@"CTRadioAccessTechnologyeHRPD"]) {
            return @"3G";
        } else if ([netType isEqualToString:@"CTRadioAccessTechnologyLTE"]){
            return @"4G";
        } else {
            return @"unknow";
        }
    }
}

@end
