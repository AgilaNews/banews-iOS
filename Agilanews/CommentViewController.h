//
//  CommentViewController.h
//  Agilanews
//
//  Created by 张思思 on 17/1/4.
//  Copyright © 2017年 banews. All rights reserved.
//

#import "BaseViewController.h"
#import "CommentTextView.h"
#import "RecommendedView.h"

@interface CommentViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *commentArray; // 评论数组
@property (nonatomic, strong) NSMutableArray *hotCommentArray;// 热评数组

@property (nonatomic, strong) CommentTextView *commentTextView; // 评论输入框
@property (nonatomic, strong) UIView *commentsView;         // 底部评论框
@property (nonatomic, strong) RecommendedView *recommentsView;

@property (nonatomic, strong) NSNumber *commentID;
@property (nonatomic, strong) UIView *noCommentView;        // 无评论视图

@property (nonatomic, strong) NSMutableArray *tasks;
@property (nonatomic, strong) UIView *blankView;
@property (nonatomic, strong) UILabel *blankLabel;
@property (nonatomic, strong) UIImageView *failureView;

@end
