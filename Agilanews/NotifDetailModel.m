//
//  NotifDetailModel.m
//  Agilanews
//
//  Created by 张思思 on 16/11/15.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "NotifDetailModel.h"

@implementation NotifDetailModel

MJCodingImplementation

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"related_news":@"NewsModel",
             @"comments":@"CommentModel"
             };
}

@end
