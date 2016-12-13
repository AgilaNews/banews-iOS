//
//  NewsModel.h
//  Agilanews
//
//  Created by 张思思 on 16/7/14.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FBNativeAd;
@interface NewsModel : NSObject

@property (nonatomic, strong) NSString *issuedID;   // 下发ID
@property (nonatomic, strong) NSArray  *imgs;       // 图片数组
@property (nonatomic, strong) NSString *news_id;    // 新闻ID
@property (nonatomic, strong) NSNumber *public_time;// 发布时间
@property (nonatomic, strong) NSString *source;     // 新闻来源
@property (nonatomic, strong) NSString *source_url; // 来源地址
@property (nonatomic, strong) NSString *title;      // 新闻标题
@property (nonatomic, strong) NSNumber *likedCount; // 点赞数
@property (nonatomic, strong) NSNumber *tpl;        // 模版号
@property (nonatomic, strong) NSNumber *commentCount; // 评论数
@property (nonatomic, strong) NSString *collect_id; // 收藏ID
@property (nonatomic, strong) NSString *share_url;  // 分享链接
@property (nonatomic, strong) NSArray  *videos;     // 视频数组
@property (nonatomic, strong) NSString *tag;        // 新闻标签
@property (nonatomic, strong) NSNumber *views;      // 观看量
@property (nonatomic, strong) NSNumber *channel_id; // 频道id
@property (nonatomic, strong) FBNativeAd *nativeAd; // facebook广告
@property (nonatomic, strong) NSNumber *ad_id;      // 广告id
@property (nonatomic, strong) NSArray *filter_tags; // 不喜欢标签

@end
