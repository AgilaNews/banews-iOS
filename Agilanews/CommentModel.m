//
//  CommentModel.m
//  Agilanews
//
//  Created by 张思思 on 16/7/19.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "CommentModel.h"

@implementation CommentModel

MJCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"commentID":@"id",
             @"time":@"time",
             @"comment":@"comment",
             @"user_id":@"user_id",
             @"user_name":@"user_name",
             @"user_portrait_url":@"user_portrait_url"
             };
}

@end
