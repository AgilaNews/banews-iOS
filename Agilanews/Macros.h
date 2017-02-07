//
//  Header.h
//  Agilanews
//
//  Created by 张思思 on 16/7/12.
//  Copyright © 2016年 banews. All rights reserved.
//

#ifndef Macros_pch
#define Macros_pch

// Include any system framework and library headers here that should be included in all compilation units.
// You will also need to set the Prefix Header build setting of one or more of your targets to reference this file.

// 获取当前设备的宽和高
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

// 获取当前设备像素
#define kScreenWidth_DP  [UIScreen mainScreen].bounds.size.width * 2
#define kScreenHeight_DP [UIScreen mainScreen].bounds.size.height * 2

// 设备版本
#define IOS_VERSION_CODE   [[[UIDevice currentDevice] systemVersion] intValue]

// 判断当前设备是否是5.5寸屏
#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
// 判断当前设备是否是4.7寸屏
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
// 判断当前设备是否是3.5寸屏
#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ?( CGSizeEqualToSize(CGSizeMake(320, 480), [[UIScreen mainScreen] currentMode].size) ||CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size)) : NO)
// 判断当前设备是否是4寸屏
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

// 打印调试
#if DEBUG
#define SSLog(fmt,...)    NSLog((@"%s [Line %d] " fmt),__PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define SSLog(fmt, ...)
#endif

// 默认UserDefaults
#define DEF_PERSISTENT_SET_OBJECT(key,value) [[NSUserDefaults standardUserDefaults] setObject:value forKey:key]
#define DEF_PERSISTENT_GET_OBJECT(key) [[NSUserDefaults standardUserDefaults] valueForKey:key]

// 设置颜色
#define SSColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define SSColor_RGB(rgb) [UIColor colorWithRed:(rgb)/255.0 green:(rgb)/255.0 blue:(rgb)/255.0 alpha:1.0]

// 主色调颜色（橙色）
#define kOrangeColor [UIColor colorWithRed:255 / 255.0 green:136 / 255.0 blue:0 / 255.0 alpha:1.0]
// 黑色字体颜色
#define kBlackColor [UIColor colorWithRed:51 / 255.0 green:51 / 255.0 blue:51 / 255.0 alpha:1.0]
// 灰色字体颜色
#define kGrayColor [UIColor colorWithRed:153 / 255.0 green:153 / 255.0 blue:153 / 255.0 alpha:1.0]
// 白色背景颜色
#define kWhiteBgColor [UIColor colorWithRed:246 / 255.0 green:246 / 255.0 blue:246 / 255.0 alpha:1.0]


#define kHaveNewChannel @"HaveNewChannel"
#define kHaveNewNotif   @"HaveNewNotif"
#define kLastNotifID    @"kLastNotifID"


#define SS_LATITUDE     @"latitude"              // 纬度
#define SS_LONGITUDE    @"longitude"             // 经度
#define SS_netStatus    @"netStatus"             // 网络状态
#define SS_textOnlyMode @"textOnlyMode"          // 无图模式
#define SS_FontSize     @"FontSize"              // 字体大小
#define SS_GuideHomeKey @"SS_GuideHomeKey_v1.0.1"// 引导页——主页
#define SS_GuideFavKey  @"SS_GuideFavKey_v1.0.1" // 引导页——收藏
#define SS_GuideCnlKey  @"SS_GuideCnlKey_v1.0.1" // 引导页——频道
// 开屏广告参数
#define SS_SPLASH_ON            @"SS_SPLASH_ON"         // 开屏广告开关
#define SS_SPLASH_SLOT          @"SS_SPLASH_SLOT"       // 广告轮播位
#define SS_SPLASH_STAY_TIME     @"SS_SPLASH_STAY_TIME"  // 等待时间
#define SS_SPLASH_AD_TIME       @"SS_SPLASH_AD_TIME"    // 广告停留时间
#define SS_SPLASH_AD_TTL        @"SS_SPLASH_AD_TTL"     // 广告有效时间
#define SS_SPLASH_REBOOT_TIME   @"SS_SPLASH_REBOOT_TIME"// 广告间隔时间
#define SS_SPLASH_GET_TIME      @"SS_SPLASH_GET_TIME"   // 广告获取时间
#define SS_SPLASH_SHOW_TIME     @"SS_SPLASH_SHOW_TIME"  // 广告展示时间

// 新闻模板
#define NEWS_BigPic      2   // 大图模板
#define NEWS_ManyPic     3   // 多图模板
#define NEWS_SinglePic   4   // 单图模板
#define NEWS_NoPic       5   // 无图模板
#define NEWS_OnlyPic     6   // 图片模板
#define NEWS_GifPic      7   // gif图模板
#define NEWS_HotVideo    10  // hot视频模板
#define NEWS_HaveVideo   11  // 含视频模板
#define NEWS_OnlyVideo   12  // 纯视频模板
#define NEWS_SingleVideo 13  // 单视频模板
#define NEWS_Topics      14  // 专题模板
#define NEWS_Interest    15  // 兴趣模板
#define ADS_List         5000// 广告模板
#define Top_List         1001// 置顶模板

// 通知
#define KNOTIFICATION_Categories      @"KNOTIFICATION_Categories"     // 频道刷新通知
#define KNOTIFICATION_Refresh         @"KNOTIFICATION_Refresh"        // 首页刷新按钮通知
#define KNOTIFICATION_Refresh_Success @"KNOTIFICATION_Refresh_Success"// 首页刷新成功通知
#define KNOTIFICATION_Login_Success   @"KNOTIFICATION_Login_Success"  // 第三方登录成功通知
#define KNOTIFICATION_Logout_Success  @"KNOTIFICATION_Logout_Success" // 退出登录通知
#define KNOTIFICATION_Secect_Channel  @"KNOTIFICATION_Secect_Channel" // 选中频道通知
#define KNOTIFICATION_Scroll_Channel  @"KNOTIFICATION_Scroll_Channel" // 滑动频道通知
#define KNOTIFICATION_TextOnly_ON     @"KNOTIFICATION_TextOnly_ON"    // 无图模式开启通知
#define KNOTIFICATION_TextOnly_OFF    @"KNOTIFICATION_TextOnly_OFF"   // 无图模式关闭通知
#define KNOTIFICATION_FontSize_Change @"KNOTIFICATION_FontSize_Change"// 字体大小改变通知
#define KNOTIFICATION_PushToFavorite  @"KNOTIFICATION_PushToFavorite" // 跳转到收藏通知
#define KNOTIFICATION_TouchFavorite   @"KNOTIFICATION_TouchFavorite"  // 点击收藏通知
#define KNOTIFICATION_FindNewChannel  @"KNOTIFICATION_FindNewChannel" // 发现新频道通知
#define KNOTIFICATION_CleanNewChannel @"KNOTIFICATION_CleanNewChannel"// 删除新频道通知
#define KNOTIFICATION_PushExit        @"KNOTIFICATION_PushExit"       // 从推送页面退出
#define KNOTIFICATION_RecoverVideo    @"KNOTIFICATION_RecoverVideo"   // 视频从详情页回位
#define KNOTIFICATION_PausedVideo     @"KNOTIFICATION_PausedVideo"    // 暂停视频
#define KNOTIFICATION_FindNewNotif    @"KNOTIFICATION_FindNewNotif"   // 发现新频道通知
#define KNOTIFICATION_CleanNewNotif   @"KNOTIFICATION_CleanNewNotif"  // 删除新频道通知
#define KNOTIFICATION_CheckNewNotif   @"KNOTIFICATION_CheckNewNotif"  // 检查新频道通知
#define KNOTIFICATION_AddRedPoint     @"KNOTIFICATION_AddRedPoint"    // 添加小红点通知
#define KNOTIFICATION_RemoveRedPoint  @"KNOTIFICATION_RemoveRedPoint" // 移除小红点通知


// 刷新成功提示banner
#define DEF_banner(num) [NSString stringWithFormat:@"Found %ld stories for you",num]


#endif /* Macros_pch */
