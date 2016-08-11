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
    if ([netType isEqualToString:@"WiFi"]) {
        return @"wifi";
    } else {
        if ([netType isEqualToString:@"CTRadioAccessTechnologyGPRS"] || [netType isEqualToString:@"CTRadioAccessTechnologyEdge"] || [netType isEqualToString:@"CTRadioAccessTechnologyWCDMA"]) {
            return @"2G";
        } else if ([netType isEqualToString:@"CTRadioAccessTechnologyHSDPA"] || [netType isEqualToString:@"CTRadioAccessTechnologyHSUPA"] || [netType isEqualToString:@"CTRadioAccessTechnologyCDMA1x"] || [netType isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"] || [netType isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"] || [netType isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"] || [netType isEqualToString:@"CTRadioAccessTechnologyeHRPD"]) {
            return @"3G";
        } else {
            return @"4G";
        }
    }
}

@end
