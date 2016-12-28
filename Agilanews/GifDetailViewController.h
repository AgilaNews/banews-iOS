//
//  GifDetailViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/12/28.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "BaseViewController.h"
#import "CommentTextView.h"
#import "RecommendedView.h"

@interface GifDetailViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, FBSDKSharingDelegate>

@property (nonatomic, strong) NSString *channelName;    // 频道名
@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) NewsDetailModel *detailModel; // 新闻详情model
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *commentArray; // 评论数组
@property (nonatomic, strong) NSMutableArray *hotCommentArray;// 热评数组

@property (nonatomic, strong) UIView *commentsView;
@property (nonatomic, strong) UILabel *commentsLabel;   // 评论数标签
@property (nonatomic, strong) CommentTextView *commentTextView; // 评论输入框
@property (nonatomic, strong) RecommendedView *recommentsView;  // 评论头视图
@property (nonatomic, strong) UIView *noCommentView;        // 无评论视图

@property (nonatomic, strong) NSMutableArray *tasks;
@property (nonatomic, strong) NSString *collectID;          // 收藏新闻ID
@property (nonatomic, strong) NSNumber *commentID;



@end
