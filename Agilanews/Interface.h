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
    NetServer_Check,        /* 检查版本接口 */
} NetServerType;

#if DEBUG
#define kHomeUrl        @"http://api.agilanews.info/v1"
#define kLogUrl         @"http://log.agilanews.info"
#define kMonUrl         @"http://mon.agilanews.info"
#define kReferrerUrl    @"http://api.agilanews.info/referrer"
#else
#define kHomeUrl        @"http://api.agilanews.today/v1"
#define kLogUrl         @"http://log.agilanews.today"
#define kMonUrl         @"http://mon.agilanews.today"
#define kReferrerUrl    @"http://api.agilanews.today/referrer"
#endif

// 新闻列表刷新接口
#define kHomeUrl_NewsList   @"/news/list"
// 新闻详情接口
#define kHomeUrl_NewsDetail @"/news/detail"
// 第三方登录接口
#define kHomeUrl_Login      @"/login"
// 评论接口
#define kHomeUrl_Comment    @"/user/comment"
// 点赞接口
#define kHomeUrl_Like       @"/news/like"
// 添加收藏接口
#define kHomeUrl_Collect    @"/user/collect"
// 反馈接口
#define kHomeUrl_Feedback   @"/feedback"
// 检查更新接口
#define kHomeUrl_Check      @"/check"
// push绑定接口
#define kHomeUrl_Push      @"/firebase"


#endif /* Interface_h */
