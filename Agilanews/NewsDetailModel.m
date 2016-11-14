//
//  NewsDetailModel.m
//  Agilanews
//
//  Created by 张思思 on 16/7/19.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "NewsDetailModel.h"
#import "ImageModel.h"
#import "NewsModel.h"
#import "CommentModel.h"
#import "VideoModel.h"

@implementation NewsDetailModel

MJCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"comments":@"comments.new",
             @"hotComments":@"comments.hot"
             };
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"body":@"body",
             @"channel_id":@"channel_id",
             @"collect_id":@"collect_id",
             @"commentCount":@"commentCount",
             @"comments":@"CommentModel",
             @"hotComments":@"CommentModel",
             @"imgs":@"ImageModel",
             @"news_id":@"news_id",
             @"likedCount":@"likedCount",
             @"public_time":@"public_time",
             @"recommend_news":@"NewsModel",
             @"title":@"title",
             @"source":@"source",
             @"share_url":@"share_url",
             @"youtube_videos":@"VideoModel"
             };
}

@end
