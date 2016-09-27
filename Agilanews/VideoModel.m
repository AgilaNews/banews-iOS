//
//  VideoModel.m
//  Agilanews
//
//  Created by 张思思 on 16/9/20.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "VideoModel.h"

@implementation VideoModel

MJCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"height":@"height",
             @"width":@"width",
             @"duration":@"duration",
             @"size":@"size",
             @"src":@"src"
             };
}

@end
