//
//  Interface.h
//  Agilanews
//
//  Created by 张思思 on 16/7/12.
//  Copyright © 2016年 banews. All rights reserved.
//

#ifndef Interface_h
#define Interface_h

// 接口类型名称
#define Server_Home      @"Server_Home"
#define Server_Log       @"Server_Log"
#define Server_Mon       @"Server_Mon"
#define Server_Referrer  @"Server_Referrer"

// 接口类型
typedef enum {
    NetServer_Home = 1,     /* 普通请求接口 */
    NetServer_Log,          /* 打点接口 */
    NetServer_Mon,          /* 反馈接口 */
    NetServer_Referrer,     /* 推荐接口 */
} NetServerType;

#if DEBUG
#define kHomeUrl        @"https://api.agilanews.info/v1"
//#define kHomeUrl        @"https://api.agilanews.today/v1"
#define kLogUrl         @"https://log.agilanews.info/v1"
#define kMonUrl         @"https://mon.agilanews.info/v1"
#define kReferrerUrl    @"https://api.agilanews.info/referrer/v1"
#else
#define kHomeUrl        @"https://api.agilanews.today/v1"
#define kLogUrl         @"https://log.agilanews.today/v1"
#define kMonUrl         @"https://mon.agilanews.today/v1"
#define kReferrerUrl    @"https://api.agilanews.today/referrer/v1"
#endif

// 新闻列表刷新接口
#define kHomeUrl_NewsList   @"/news/list"
// 新闻详情接口
#define kHomeUrl_NewsDetail @"/news/detail"
// 第三方登录接口
#define kHomeUrl_Login      @"/login"
// 评论接口
#define kHomeUrl_Comment    @"/user/comment/"
// 点赞接口
#define kHomeUrl_Like       @"/news/like/"
// 添加收藏接口
#define kHomeUrl_Collect    @"/user/collect/"
// 反馈接口
#define kHomeUrl_Feedback   @"/feedback/"



#endif /* Interface_h */
