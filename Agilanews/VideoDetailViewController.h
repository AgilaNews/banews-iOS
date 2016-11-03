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

@interface VideoDetailViewController : BaseViewController<UINavigationControllerDelegate, FBSDKSharingDelegate, YTPlayerViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *toView;
@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) NSString *channelName;    // 频道名
@property (nonatomic, strong) YTPlayerView *playerView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) OnlyVideoCell *fromCell;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *noCommentView;        // 无评论视图
@property (nonatomic, strong) UIView *blankView;
@property (nonatomic, strong) UILabel *blankLabel;
@property (nonatomic, strong) UIImageView *failureView;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, assign) BOOL isContentOpen;


@end
