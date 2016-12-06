//
//  NewsDetailViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/7/19.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "NewsModel.h"
#import "NewsDetailModel.h"
#import "AppDelegate.h"
#import "CommentTextView.h"
#import "FacebookAdView.h"
#import "LSEmojiFly.h"

@interface NewsDetailViewController : BaseViewController <UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITextViewDelegate, FBSDKSharingDelegate>

@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) WebViewJavascriptBridge *bridge;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *commentsView;         
@property (nonatomic, strong) UIButton *likeButton;         // 点赞按钮
@property (nonatomic, assign) float webViewHeight;          // webView高度
@property (nonatomic, strong) NewsDetailModel *detailModel; // 新闻详情model
@property (nonatomic, strong) NSMutableArray *commentArray; // 评论数组
@property (nonatomic, strong) NSMutableArray *hotCommentArray;// 热评数组
@property (nonatomic, strong) NSString *collectID;          // 收藏新闻ID
@property (nonatomic, strong) CommentTextView *commentTextView; // 评论输入框
@property (nonatomic, strong) UIView *noCommentView;        // 无评论视图
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, assign) BOOL isShowGuide;         // 是否展示引导页
@property (nonatomic, assign) NSInteger pullupCount;    // 上拉加载次数
@property (nonatomic, strong) NSString *channelName;    // 频道名
@property (nonatomic, assign) long long enterTime;      // 文章进入时间
@property (nonatomic, assign) BOOL isRecommendShow;     // 推荐文章展示
@property (nonatomic, strong) UILabel *commentsLabel;   // 评论数标签
@property (nonatomic, strong) UIView *blankView;
@property (nonatomic, strong) UILabel *blankLabel;
@property (nonatomic, strong) UIImageView *failureView;
@property (nonatomic, assign) float webviewOffsetY;
@property (nonatomic, assign) BOOL isPushEnter;
@property (nonatomic, strong) NSNumber *commentID;
@property (nonatomic, assign) BOOL isHaveAd;
@property (nonatomic, strong) NSDictionary *adInfo;
@property (nonatomic, strong) FacebookAdView *facebookAdView;
@property (strong, nonatomic) LSEmojiFly *emojiFlay;


@end
