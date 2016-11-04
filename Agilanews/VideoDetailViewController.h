//
//  VideoDetailViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/10/27.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "BaseViewController.h"
#import "NewsModel.h"
#import "OnlyVideoCell.h"
#import "RecommendedView.h"
#import "CommentTextView.h"

@interface VideoDetailViewController : BaseViewController<UINavigationControllerDelegate, FBSDKSharingDelegate, YTPlayerViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) UIView *toView;
@property (nonatomic, strong) NSDictionary *playerVars;
@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) NSString *channelName;    // 频道名
@property (nonatomic, strong) YTPlayerView *playerView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) OnlyVideoCell *fromCell;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *commentsView;
@property (nonatomic, strong) UILabel *commentsLabel;   // 评论数标签
@property (nonatomic, strong) CommentTextView *commentTextView; // 评论输入框
@property (nonatomic, strong) NSMutableArray *recommend_news;
@property (nonatomic, strong) RecommendedView *recommendedView;
@property (nonatomic, strong) NSMutableArray *commentArray; // 评论数组
@property (nonatomic, strong) RecommendedView *recommentsView;
@property (nonatomic, strong) UIView *noCommentView;        // 无评论视图
@property (nonatomic, assign) NSInteger pullupCount;    // 上拉加载次数
@property (nonatomic, strong) UIView *blankView;
@property (nonatomic, strong) UILabel *blankLabel;
@property (nonatomic, strong) UIImageView *failureView;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, assign) BOOL isContentOpen;
@property (nonatomic, assign) BOOL isOther;


@end
