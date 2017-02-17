//
//  NewsDetailModel.h
//  Agilanews
//
//  Created by 张思思 on 16/7/19.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsDetailModel : NSObject

@property (nonatomic, strong) NSString *body;           //
@property (nonatomic, strong) NSNumber *channel_id;     // 频道ID
@property (nonatomic, strong) NSString *collect_id;     // 收藏ID
@property (nonatomic, strong) NSNumber *commentCount;   // 评论数
@property (nonatomic, strong) NSArray *comments;        // 新评论
@property (nonatomic, strong) NSArray *hotComments;     // 热门评论
@property (nonatomic, strong) NSArray *imgs;            // 图片
@property (nonatomic, strong) NSString *news_id;        // 新闻ID
@property (nonatomic, strong) NSNumber *likedCount;     // 点赞数
@property (nonatomic, strong) NSNumber *public_time;    // 发布时间
@property (nonatomic, strong) NSArray *recommend_news;  // 推荐新闻
@property (nonatomic, strong) NSString *title;          // 标题
@property (nonatomic, strong) NSString *source;         // 来源
@property (nonatomic, strong) NSString *source_url;     // 来源链接
@property (nonatomic, strong) NSString *share_url;      // 分享链接
@property (nonatomic, strong) NSArray *youtube_videos;  // 视频
@property (nonatomic, strong) NSArray *sns_widgets;     // sns标签
@property (nonatomic, strong) NSArray *tags;            // 关键词

@end
