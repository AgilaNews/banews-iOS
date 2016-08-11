//
//  CategoriesModel.m
//  Agilanews
//
//  Created by 张思思 on 16/7/13.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "CategoriesModel.h"

@implementation CategoriesModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"fixed":@"fixed",
             @"channelID":@"id",
             @"index":@"index",
             @"name":@"name"
             };
}

@end
