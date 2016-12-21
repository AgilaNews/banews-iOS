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
    NetServer_V3,
    NetServer_API1,
    NetServer_API2,
} NetServerType;

#if DEBUG
#define kHomeUrl        @"http://api.agilanews.info/v2"
#define kLogUrl         @"http://log.agilanews.info/v3"
#define kMonUrl         @"http://mon.agilanews.info"
#define kReferrerUrl    @"http://api.agilanews.info/referrer"
#define kV3Url          @"http://api.agilanews.info/v3"
#define kAPI1           @"http://api1.agilanews.info/v2"
#define kAPI2           @"http://api2.agilanews.info/v2"
#else
#define kHomeUrl        @"http://api.agilanews.today/v2"
#define kLogUrl         @"http://log.agilanews.today/v3"
#define kMonUrl         @"http://mon.agilanews.today"
#define kReferrerUrl    @"http://api.agilanews.today/referrer"
#define kV3Url          @"http://api.agilanews.today/v3"
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
#define kHomeUrl_Push       @"/firebase"
// 安装上传接口
#define kHomeUrl_Referrer   @"/login/referrer"
// 频道下发接口
#define kHomeUrl_Channel    @"/channel"
// 新闻推荐接口
#define kHomeUrl_Recommend  @"/news/recommend"
// 视频评论接口
#define kHomeUrl_VideoComment     @"/comment"
// 评论点赞接口
#define kHomeUrl_CommentLike      @"/comment/like"
// 通知中心接口
#define kHomeUrl_Notification     @"/notification"
// 通知详情接口
#define kHomeUrl_NotifDetail      @"/notification/related"
// 检查通知接口
#define kHomeUrl_NotifCheck       @"/notification/check"
// 阅读通知接口
#define kHomeUrl_NotifRead        @"/notification/read"
// 历史版本接口
#define kHomeUrl_CheckEarlier     @"/check/earlier"
// 点赞接口
#define kHomeUrl_NewsDislike      @"/user/unlike"
// 搜索接口
#define kHomeUrl_NewsSearch       @"/search"
// 热词接口
#define kHomeUrl_NewsHotwords     @"/search/hotwords"






#endif /* Interface_h */
