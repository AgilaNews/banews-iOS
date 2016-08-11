//
//  LoginModel.m
//  Agilanews
//
//  Created by 张思思 on 16/7/19.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "LoginModel.h"

@implementation LoginModel

MJCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"user_id":@"id",
             @"name":@"name",
             @"gender":@"gender",
             @"portrait":@"portrait",
             @"email":@"email",
             @"create_time":@"create_time",
             @"source":@"source"
             };
}

@end