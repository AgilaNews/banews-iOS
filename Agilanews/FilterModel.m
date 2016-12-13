//
//  FilterModel.m
//  Agilanews
//
//  Created by 张思思 on 16/12/12.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "FilterModel.h"

@implementation FilterModel

MJCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"name":@"name",
             @"filterID":@"id",
             };
}

@end
