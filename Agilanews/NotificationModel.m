//
//  NotificationModel.m
//  Agilanews
//
//  Created by 张思思 on 16/11/15.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "NotificationModel.h"

@implementation NotificationModel

MJCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"commentID":@"id",
             @"time":@"time",
             @"comment":@"comment",
             @"user_id":@"user_id",
             @"user_name":@"user_name",
             @"user_portrait_url":@"user_portrait_url",
             @"liked":@"liked",
             @"notify_id":@"notify_id",
             @"status":@"status"
             };
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"reply":@"CommentModel"
             };
}

@end
