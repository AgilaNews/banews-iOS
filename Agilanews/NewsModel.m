//
//  NewsModel.m
//  Agilanews
//
//  Created by 张思思 on 16/7/14.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "NewsModel.h"
#import "ImageModel.h"
#import "VideoModel.h"

@implementation NewsModel

MJCodingImplementation

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"issuedID":@"issuedID",
             @"imgs":@"ImageModel",
             @"news_id":@"news_id",
             @"public_time":@"public_time",
             @"source":@"source",
             @"source_url":@"source_url",
             @"title":@"title",
             @"likedCount":@"likedCount",
             @"tpl":@"tpl",
             @"collect_id":@"collect_id",
             @"commentCount":@"commentCount",
             @"share_url":@"share_url",
             @"videos":@"VideoModel",
             @"tag":@"tag"
             };
}




@end
