//
//  NetType.h
//  Agilanews
//
//  Created by 张思思 on 16/8/8.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/types.h>
#include <sys/sysctl.h>

@interface NetType : NSObject

+ (NSString *)getNetType;

+ (NSString *)getCurrentDeviceModel;

@end
