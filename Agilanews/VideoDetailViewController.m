//
//  VideoDetailViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/10/27.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "PopTransitionAnimate.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ImageModel.h"
#import "VideoModel.h"
#import "CommentCell.h"
#import "SinglePicCell.h"
#import "NoPicCell.h"
#import "VideoDetailCell.h"
#import "SingleVideoCell.h"
#import "CommentTextField.h"

#define titleFont_Normal        [UIFont systemFontOfSize:16]
#define titleFont_ExtraLarge    [UIFont systemFontOfSize:20]
#define titleFont_Large         [UIFont systemFontOfSize:18]
#define titleFont_Small         [UIFont systemFontOfSize:14]

@import SafariServices;
@interface VideoDetailViewController ()

@end

@implementation VideoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        NSArray *list=self.navigationController.navigationBar.subviews;
        for (id obj in list) {
            if ([UIDevice currentDevice].systemVersion.integerValue >= 10) {
                UIView *view = (UIView *)obj;
                for (id obj2 in view.subviews) {
                    if ([obj2 isKindOfClass:[UIImageView class]]) {
                        UIImageView *image = (UIImageView *)obj2;
                        image.hidden = YES;
                    }
                }
            }
        }
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.isBackButton = YES;
    _toView = [[UIApplication sharedApplication].keyWindow snapshotViewAfterScreenUpdates:NO];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(0, 0, 40, 40);
    [shareBtn setImage:[UIImage imageNamed:@"icon_article_share_default"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc]initWithCustomView:shareBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, shareItem];
    
    [self.view addSubview:_playerView];
    self.playerView.delegate = self;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _playerView.bottom, kScreenWidth, kScreenHeight - _playerView.bottom - 50) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = kWhiteBgColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.sectionHeaderHeight = 0;
    _tableView.sectionFooterHeight = 0;
    _tableView.separatorColor = SSColor(235, 235, 235);
    [self.view addSubview:_tableView];
    [self.view addSubview:self.commentsView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        // 新闻推荐网络请求
        [self recommendWithNewsID:_model.news_id AppDelegate:appDelegate];
        // 评论网络请求
        [self requsetCommentsListWithNewsID:_model.news_id];
        // 详情网络请求
#warning todo - 详情网络请求
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.delegate = self;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor clearColor]];
        UIView *barBgView = self.navigationController.navigationBar.subviews.firstObject;
        for (UIView *subview in barBgView.subviews) {
            if([subview isKindOfClass:[UIVisualEffectView class]]) {
                subview.backgroundColor = [UIColor clearColor];
                [subview removeAllSubviews];
            }
        }
    } else {
        [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    }
    
    // 判断播放器状态
    if (self.playerView.playerState == kYTPlayerStatePaused || self.playerView.playerState == kYTPlayerStateEnded) {
        [self.playerView playVideo];
    } else if (self.playerView.playerState != kYTPlayerStatePlaying) {
        _playerVars = @{@"autohide" : @2,          // 参数设为1，则视频进度条和播放器控件将会在视频开始播放几秒钟后退出播放界面。
                                                   // 仅在用户将鼠标移动到视频播放器上方或按键盘上的某个键时，进度条和控件才会重新显示。
                                                   // 参数设为0，则视频进度条和视频播放器控件在视频播放全程和全屏状态下均会显示。
                        @"iv_load_policy" : @3,    // 将此值设为1会在默认情况下显示视频注释，而将其设为3则默认不显示。
                        @"playsinline" : @1,       // 以内嵌方式播放还是以全屏形式播放。  1:内嵌模式  0:全屏模式
                        @"loop" : @1,              // 是否循环播放。  0:不循环  1:循环
                        @"rel" : @0,               // 视频播放结束时，播放器是否应显示相关视频。  0:不显示  1:显示
                        @"autoplay" : @1,          // 自动播放
                        @"modestbranding" : @1,    // 将参数值设为1可以阻止YouTube徽标显示在控件栏中。
                        @"origin" : @"http://www.youtube.com",
                        @"showinfo" : @0};         // 播放器是否显示视频标题和上传者等信息。  0:不显示  1:显示
        VideoModel *model = _model.videos.firstObject;
        [self.playerView loadWithVideoId:model.youtube_id playerVars:_playerVars];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_RecoverVideo
                                                        object:@{@"index":_indexPath,
                                                                 @"playerView":_playerView,
                                                                 @"stop":_isOther ? @1 : @0}];
}

- (void)dealloc
{
    self.playerView.delegate = nil;
}

#pragma mark - Network
/**
 新闻推荐网络请求

 @param newsID      新闻ID
 @param appDelegate
 */
- (void)recommendWithNewsID:(NSString *)newsID AppDelegate:(AppDelegate *)appDelegate
{
    [_recommendedView startAnimation];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:newsID forKey:@"news_id"];
    [[SSHttpRequest sharedInstance] get:kHomeUrl_Recommend params:params contentType:JsonType serverType:NetServer_Video success:^(id responseObj) {
        [_recommendedView stopAnimation];
        [appDelegate.likedDic setValue:@1 forKey:newsID];
        NSArray *recommends = responseObj[@"recommend_news"];
        _recommend_news = [NSMutableArray array];
        for (NSDictionary *dic in recommends) {
            NewsModel *model = [NewsModel mj_objectWithKeyValues:dic];
            [_recommend_news addObject:model];
        }
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    } failure:^(NSError *error) {
        [_recommendedView stopAnimation];
        _recommendedView.retryLabel.hidden = NO;
    } isShowHUD:NO];
}

/**
 // 评论网络请求
 */
- (void)requsetCommentsListWithNewsID:(NSString *)newsID
{
    [_recommentsView startAnimation];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:newsID forKey:@"news_id"];
    [params setObject:@"later" forKey:@"prefer"];
    [params setObject:@3 forKey:@"pn"];
    [[SSHttpRequest sharedInstance] get:kHomeUrl_VideoRecommend params:params contentType:UrlencodedType serverType:NetServer_Video success:^(id responseObj) {
        [_recommentsView stopAnimation];
        NSArray *array = responseObj;
        NSMutableArray *models = [NSMutableArray array];
        @autoreleasepool {
            for (NSDictionary *dic in array) {
                CommentModel *model = [CommentModel mj_objectWithKeyValues:dic];
                [models addObject:model];
            }
        }
        weakSelf.commentArray = models;
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        [_recommentsView stopAnimation];
        _recommentsView.retryLabel.hidden = NO;
    } isShowHUD:NO];
}

/**
 *  上拉加载评论
 */
- (void)tableViewDidTriggerFooterRefresh
{
    _pullupCount++;
    if (_pullupCount > 1) {
        // 打点-页面进入-010301
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _channelName, @"channel",
                                       _model.news_id, @"article",
                                       [NetType getNetType], @"network",
                                       nil];
        [Flurry logEvent:@"Comments_Enter" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Comments_Enter:%@",articleParams],nil];
#endif
    } else {
        // 打点-上拉加载-010302
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _channelName, @"channel",
                                       _model.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Comments_List_UpLoad" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Comments_List_UpLoad:%@",articleParams],nil];
#endif
    }
    
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_model.news_id forKey:@"news_id"];
    [params setObject:@"later" forKey:@"prefer"];
    CommentModel *commentModel = _commentArray.lastObject;
    [params setObject:commentModel.commentID forKey:@"last_id"];
    [[SSHttpRequest sharedInstance] get:kHomeUrl_VideoRecommend params:params contentType:UrlencodedType serverType:NetServer_Video success:^(id responseObj) {
        [_tableView.footer endRefreshing];
        NSArray *array = responseObj;
        if (array.count > 0) {
            NSMutableArray *models = [NSMutableArray array];
            @autoreleasepool {
                for (NSDictionary *dic in array) {
                    CommentModel *model = [CommentModel mj_objectWithKeyValues:dic];
                    [models addObject:model];
                }
            }
            [self.commentArray addObjectsFromArray:models];
            [weakSelf.tableView reloadData];
        } else {
            _tableView.footer.state = MJRefreshFooterStateNoMoreData;
        }
        if (_pullupCount > 1) {
            // 打点-上拉加载成功-010303
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _channelName, @"channel",
                                           _model.news_id, @"article",
                                           nil];
            [Flurry logEvent:@"Comments_List_UpLoad_Y" withParameters:articleParams];
#if DEBUG
            [iConsole info:[NSString stringWithFormat:@"Comments_List_UpLoad_Y:%@",articleParams],nil];
#endif
        }
    } failure:^(NSError *error) {
        [_tableView.footer endRefreshing];
        if (_pullupCount > 1) {
            // 打点-上拉加载失败-010304
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _channelName, @"channel",
                                           _model.news_id, @"article",
                                           nil];
            [Flurry logEvent:@"Comments_List_UpLoad_N" withParameters:articleParams];
#if DEBUG
            [iConsole info:[NSString stringWithFormat:@"Comments_List_UpLoad_N:%@",articleParams],nil];
#endif
        }
    } isShowHUD:NO];
}

/**
 *  点赞按钮网络请求
 *
 *  @param appDelegate
 *  @param button      点赞按钮
 */
- (void)likedNewsWithAppDelegate:(AppDelegate *)appDelegate button:(UIButton *)button
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_model.news_id forKey:@"news_id"];
    [[SSHttpRequest sharedInstance] post:kHomeUrl_Like params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        [appDelegate.likedDic setValue:@1 forKey:_model.news_id];
        _model.likedCount = responseObj[@"liked"];
        [button setTitle:[NSString stringWithFormat:@"%@",responseObj[@"liked"]] forState:UIControlStateNormal];
        button.selected = YES;
    } failure:^(NSError *error) {
        //        [button setTitle:[NSString stringWithFormat:@"%d",button.titleLabel.text.intValue - 1] forState:UIControlStateNormal];
        //        weakSelf.likeButton.selected = NO;
    } isShowHUD:NO];
}

/**
 *  发布评论网络请求
 */
- (void)postComment
{
    _commentTextView.sendButton.enabled = NO;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_model.news_id forKey:@"news_id"];
    [params setObject:_commentTextView.textView.text forKey:@"comment_detail"];
    [[SSHttpRequest sharedInstance] post:kHomeUrl_Comment params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        _commentTextView.sendButton.enabled = YES;
        CommentModel *model = [CommentModel mj_objectWithKeyValues:responseObj[@"comment"]];
        if (model) {
            [weakSelf.commentArray insertObject:model atIndex:0];
            _commentsLabel.hidden = NO;
            _model.commentCount = [NSNumber numberWithInteger:_model.commentCount.integerValue + 1];
            int width;
            if (_model.commentCount.integerValue < 10) {
                width = 12;
            } else if (_model.commentCount.integerValue < 100) {
                width = 16;
            } else if (_model.commentCount.integerValue < 1000) {
                width = 22;
            } else {
                width = 28;
            }
            _commentsLabel.width = width;
            if (_model.commentCount.integerValue < 1000) {
                _commentsLabel.text = _model.commentCount.stringValue;
            } else {
                _commentsLabel.text = @"999+";
            }
        }
        [_tableView reloadData];
        [_commentTextView.textView resignFirstResponder];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        [UIView animateWithDuration:0.3 animations:^{
            _commentTextView.shadowView.alpha = 0;
            _commentTextView.bgView.alpha = 0;
        } completion:^(BOOL finished) {
            [_commentTextView removeFromSuperview];
            _commentTextView = nil;
        }];
        [SVProgressHUD showSuccessWithStatus:@"Successful"];
        // 打点-评论成功-010210
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _channelName, @"channel",
                                       _model.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Article_Comments_Send_Y" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Article_Comments_Send_Y:%@",articleParams],nil];
#endif
    } failure:^(NSError *error) {
        _commentTextView.sendButton.enabled = YES;
        // 打点-评论失败-010211
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _channelName, @"channel",
                                       _model.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Article_Comments_Send_N" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Article_Comments_Send_N:%@",articleParams],nil];
#endif
    } isShowHUD:YES];
}

#pragma mark - 按钮点击事件
/**
 *  点赞按钮点击事件
 *
 *  @param button 点赞按钮
 */
- (void)likeAction:(UIButton *)button
{
    // 打点-点赞-010207
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   _channelName, @"channel",
                                   _model.news_id, @"article",
                                   nil];
    [Flurry logEvent:@"Article_Like_Click" withParameters:articleParams];
#if DEBUG
    [iConsole info:[NSString stringWithFormat:@"Article_Like_Click:%@",articleParams],nil];
#endif
    if (button.selected) {
        if (button.titleLabel.text.intValue > 1) {
            _model.likedCount = [NSNumber numberWithInteger:_model.likedCount.integerValue - 1];
        } else {
            [button setTitle:@"" forState:UIControlStateNormal];
            _model.likedCount = @0;
        }
    } else {
        _model.likedCount = [NSNumber numberWithInteger:_model.likedCount.integerValue + 1];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (appDelegate.likedDic[_model.news_id] == nil) {
            [self likedNewsWithAppDelegate:appDelegate button:button];
        }
    }
    VideoDetailCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.likeButton.selected = !button.selected;
}

/**
 展开按钮点击事件

 @param button 展开按钮
 */
- (void)openAction:(UIButton *)button
{
    if (!button.selected) {
        _isContentOpen = YES;
    } else {
        _isContentOpen = NO;
    }
    button.selected = !button.selected;
    VideoDetailCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell setNeedsLayout];
    [self.tableView reloadData];
}

/**
 *  评论框点击事件
 */
- (void)commentAction
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.model) {
        // 评论
        _commentTextView = [[CommentTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)];
        [_commentTextView.shadowView addGestureRecognizer:tap];
        
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:_commentTextView];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        _commentTextView.textView.delegate = self;
        [_commentTextView.cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [_commentTextView.sendButton addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    } else {
        // 登录后评论
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.isComment = YES;
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
    }
}

/**
 *  取消按钮点击事件
 */
- (void)cancelAction
{
    [_commentTextView.textView resignFirstResponder];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        _commentTextView.shadowView.alpha = 0;
        _commentTextView.bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [_commentTextView removeFromSuperview];
        _commentTextView = nil;
    }];
}

/**
 *  发送评论按钮点击事件
 */
- (void)sendAction
{
    // 打点-发送评论-010209
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   _channelName, @"channel",
                                   _model.news_id, @"article",
                                   nil];
    [Flurry logEvent:@"Article_Comments_Send" withParameters:articleParams];
#if DEBUG
    [iConsole info:[NSString stringWithFormat:@"Article_Comments_Send:%@",articleParams],nil];
#endif
    [self postComment];
}

/**
 *  底部按钮点击事件
 *
 *  @param button 按钮
 */
- (void)buttonAction:(UIButton *)button
{
    switch (button.tag - 300) {
        case 0:
        {
            // 打点-点击评论详情页-010212
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _channelName, @"channel",
                                           _model.news_id, @"article",
                                           nil];
            [Flurry logEvent:@"Article_CommentsPage_Click" withParameters:articleParams];
#if DEBUG
            [iConsole info:[NSString stringWithFormat:@"Article_CommentsPage_Click:%@",articleParams],nil];
#endif
            // 点击评论按钮
            CGRect commentRect = [_tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
            if (_tableView.contentOffset.y < commentRect.origin.y - (kScreenHeight - _playerView.bottom - 64 - 50)) {
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            } else {
                [_tableView setContentOffset:CGPointMake(_tableView.contentOffset.x, 0) animated:YES];
            }
            break;
        }
        case 1:
        {
            // 打点-点击收藏-010214
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _channelName, @"channel",
                                           _model.news_id, @"article",
                                           nil];
            [Flurry logEvent:@"Article_Favorite_Click" withParameters:articleParams];
#if DEBUG
            [iConsole info:[NSString stringWithFormat:@"Article_Favorite_Click:%@",articleParams],nil];
#endif
            
            // 点击收藏按钮
            if (button.selected) {
//                [self deleteCollectNewsWithButton:button];
            } else {
//                [self collectNewsWithButton:button];
            }
            break;
        }
        case 2:
        {
            // 点击facebook按钮
            // 打点-分享至facebook-010219
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _channelName, @"channel",
                                           _model.news_id, @"article",
                                           nil];
            [Flurry logEvent:@"Article_Share_Facebook_Click" withParameters:articleParams];
#if DEBUG
            [iConsole info:[NSString stringWithFormat:@"Article_Share_Facebook_Click:%@",articleParams],nil];
#endif
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            if (appDelegate.model) {
                FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
                NSString *shareString = _model.share_url;
                shareString = [shareString stringByReplacingOccurrencesOfString:@"{from}" withString:@"facebook"];
                content.contentURL = [NSURL URLWithString:shareString];
                content.contentTitle = _model.title;
                ImageModel *imageModel = _model.imgs.firstObject;
                content.imageURL = [NSURL URLWithString:imageModel.src];
                [FBSDKShareDialog showFromViewController:self
                                             withContent:content
                                                delegate:self];
            } else {
                // 登录后分享
                LoginViewController *loginVC = [[LoginViewController alloc] init];
                loginVC.isShareFacebook = YES;
                UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:loginVC];
                [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
            }
            break;
        }
        default:
            break;
    }
}

/**
 *  分享按钮点击事件
 */
- (void)shareAction
{
    // 打点-点击右上方分享-010203
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   _channelName, @"channel",
                                   _model.news_id, @"article",
                                   nil];
    [Flurry logEvent:@"Article_UpShare_Click" withParameters:articleParams];
#if DEBUG
    [iConsole info:[NSString stringWithFormat:@"Article_UpShare_Click:%@",articleParams],nil];
#endif
    __weak typeof(self) weakSelf = self;
    [SSUIShareActionSheetStyle setCancelButtonLabelColor:kGrayColor];
    [SSUIShareActionSheetStyle setItemNameFont:[UIFont systemFontOfSize:13]];
    [SSUIShareActionSheetStyle setItemNameColor:kBlackColor];
    
    // 分享到facebook
    SSUIShareActionSheetCustomItem *facebook = [SSUIShareActionSheetCustomItem itemWithIcon:[UIImage imageNamed:@"icon_share_facebook"] label:@"Facebook" onClick:^{
        // 打点-分享至facebook-010219
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _channelName, @"channel",
                                       _model.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Article_Share_Facebook_Click" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Article_Share_Facebook_Click:%@",articleParams],nil];
#endif
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (appDelegate.model) {
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            NSString *shareString = _model.share_url;
            shareString = [shareString stringByReplacingOccurrencesOfString:@"{from}" withString:@"facebook"];
            content.contentURL = [NSURL URLWithString:shareString];
            content.contentTitle = _model.title;
            ImageModel *imageModel = _model.imgs.firstObject;
            content.imageURL = [NSURL URLWithString:imageModel.src];
            [FBSDKShareDialog showFromViewController:weakSelf
                                         withContent:content
                                            delegate:weakSelf];
        } else {
            // 登录后分享
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            loginVC.isShareFacebook = YES;
            UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [weakSelf.navigationController presentViewController:navCtrl animated:YES completion:nil];
        }
    }];
    
    // 分享到twitter
    SSUIShareActionSheetCustomItem *twitter = [SSUIShareActionSheetCustomItem itemWithIcon:[UIImage imageNamed:@"icon_share_twitter"] label:@"Twitter" onClick:^{
        // 打点-分享至Twitter-010220
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _channelName, @"channel",
                                       _model.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Article_Share_Twitter_Click" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Article_Share_Twitter_Click:%@",articleParams],nil];
#endif
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (appDelegate.model) {
            NSString *shareString = _model.share_url;
            shareString = [shareString stringByReplacingOccurrencesOfString:@"{from}" withString:@"twitter"];
            TWTRComposer *composer = [[TWTRComposer alloc] init];
            [composer setText:_model.title];
            [composer setURL:[NSURL URLWithString:shareString]];
            @try {
                [composer showFromViewController:weakSelf completion:^(TWTRComposerResult result) {
                    if (result == TWTRComposerResultCancelled) {
                        // 取消分享
                        SSLog(@"Tweet composition cancelled");
                    } else {
                        // 分享成功
                        SSLog(@"Sending Tweet!");
                    }
                }];
            }
            @catch (NSException *exception) {
                SSLog(@"%s\n%@", __FUNCTION__, exception);
            }
        } else {
            // 登录后分享
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            loginVC.isShareTwitter = YES;
            UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [weakSelf.navigationController presentViewController:navCtrl animated:YES completion:nil];
        }
    }];
    
    // 分享到google+
    SSUIShareActionSheetCustomItem *googleplus = [SSUIShareActionSheetCustomItem itemWithIcon:[UIImage imageNamed:@"icon_share_google"] label:@"Google+" onClick:^{
        // 打点-分享至google+-010221
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _channelName, @"channel",
                                       _model.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Article_Share_Google+_Click" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Article_Share_Google+_Click:%@",articleParams],nil];
#endif
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (appDelegate.model) {
            NSString *shareString = _model.share_url;
            shareString = [shareString stringByReplacingOccurrencesOfString:@"{from}" withString:@"googleplus"];
            NSURLComponents* urlComponents = [[NSURLComponents alloc]
                                              initWithString:@"https://plus.google.com/share"];
            urlComponents.queryItems = @[[[NSURLQueryItem alloc]
                                          initWithName:@"url"
                                          value:[[NSURL URLWithString:shareString] absoluteString]]];
            NSURL* url = [urlComponents URL];
            if ([SFSafariViewController class]) {
                // Open the URL in SFSafariViewController (iOS 9+)
                SFSafariViewController* controller = [[SFSafariViewController alloc]
                                                      initWithURL:url];
                //            controller.delegate = self;
                [weakSelf presentViewController:controller animated:YES completion:nil];
            } else {
                // Open the URL in the device's browser
                [[UIApplication sharedApplication] openURL:url];
            }
        } else {
            // 登录后分享
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            loginVC.isShareGoogle = YES;
            UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [weakSelf.navigationController presentViewController:navCtrl animated:YES completion:nil];
        }
    }];
    
    [ShareSDK showShareActionSheet:self.view
                             items:@[facebook, twitter, googleplus]
                       shareParams:nil
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end)
     {
         switch (state)
         {
             case SSDKResponseStateCancel:
             {
                 SSLog(@"取消分享");
                 break;
             }
             default:
                 break;
         }
     }];
}

#pragma mark - FBSDKSharingDelegate
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    SSLog(@"分享成功");
}
- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    SSLog(@"分享失败");
}
- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    SSLog(@"取消分享");
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            if (_recommend_news.count > 0) {
                return _recommend_news.count + 1;
            } else {
                return 1;
            }
        case 2:
            if (_commentArray.count > 0) {
                return _commentArray.count + 1;
            } else {
                return 2;
            }
        default:
            return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 8)];
        view.backgroundColor = SSColor(235, 235, 235);
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1 || section == 2) {
        return 8;
    } else {
        return 0.00001f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            CGSize titleLabelSize = [_model.title calculateSize:CGSizeMake(kScreenWidth - 22, 80) font:[UIFont boldSystemFontOfSize:21]];
            CGSize contentLabelSize = CGSizeZero;
            VideoModel *model = _model.videos.firstObject;
            if (_isContentOpen) {
                contentLabelSize = [model.content calculateSize:CGSizeMake(kScreenWidth - 22 - 20, 1500) font:[UIFont systemFontOfSize:12]];
            } else {
                contentLabelSize = [model.content calculateSize:CGSizeMake(kScreenWidth - 22 - 20, 30) font:[UIFont systemFontOfSize:12]];
            }
            return 11 + titleLabelSize.height + 6 + 12 + 12 + contentLabelSize.height + 30 + 34 + 28;
        }
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    return 30;
                default:
                {
                    NewsModel *model = _recommend_news[indexPath.row - 1];
                    UIFont *titleFont = nil;
                    switch ([DEF_PERSISTENT_GET_OBJECT(SS_FontSize) integerValue]) {
                        case 0:
                            titleFont = titleFont_Normal;
                            break;
                        case 1:
                            titleFont = titleFont_ExtraLarge;
                            break;
                        case 2:
                            titleFont = titleFont_Large;
                            break;
                        case 3:
                            titleFont = titleFont_Small;
                            break;
                        default:
                            titleFont = titleFont_Normal;
                            break;
                    }
                    switch ([model.tpl integerValue])
                    {
                        case NEWS_ManyPic:
                        {
                            return 12 + 68 + 12;
                        }
                        case NEWS_SinglePic:
                        {
                            return 12 + 68 + 12;
                        }
                        case NEWS_NoPic:
                        {
                            CGSize titleLabelSize = [model.title calculateSize:CGSizeMake(kScreenWidth - 22, 60) font:titleFont];
                            return 11 + titleLabelSize.height + 15 + 11 + 11;
                        }
                        case NEWS_BigPic:
                        {
                            return 12 + 68 + 12;
                        }
                        case NEWS_HaveVideo:
                        {
                            return 12 + 68 + 12;
                        }
                            case NEWS_OnlyVideo:
                        {
                            return 12 + 68 + 12;
                        }
                        default:
                            return 50;
                    }
                }
            }
        }
        case 2:
            switch (indexPath.row) {
                case 0:
                    return 30;
                    break;
                default:
                {
                    if (_commentArray.count > 0) {
                        CommentModel *model = _commentArray[indexPath.row - 1];
                        CGSize commentLabelSize = [model.comment calculateSize:CGSizeMake(kScreenWidth - 55 - 11, 1000) font:[UIFont systemFontOfSize:14]];
                        return 10 + 5 + 16 + 12 + commentLabelSize.height + 10;
                    } else {
                        return 90;
                    }
                    break;
                }
            }
            break;
        default:
            return 50;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case 0:
        {
            // 视频详情
            static NSString *cellID = @"VideoDetailCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[VideoDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:kWhiteBgColor];
                [((VideoDetailCell *)cell).likeButton addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
                [((VideoDetailCell *)cell).openButton addTarget:self action:@selector(openAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            ((VideoDetailCell *)cell).model = _model;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
        case 1:
        {
            // 推荐新闻
            switch (indexPath.row) {
                case 0:
                {
                    static NSString *cellID = @"recommendedCellID";
                    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                    }
                    if (cell.contentView.subviews.count <= 0) {
                        _recommendedView = [[RecommendedView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30) titleImage:[UIImage imageNamed:@"icon_article_recommend_small"] titleText:@"Recommended for you" HaveLoading:YES];
                        [cell.contentView addSubview:_recommendedView];
                    }
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    return cell;
                }
                default:
                {
                    NewsModel *model = _recommend_news[indexPath.row - 1];
                    switch ([model.tpl integerValue])
                    {
                        case NEWS_ManyPic:
                        {
                            // 单图cell
                            static NSString *cellID = @"SinglePicCellID";
                            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                            if (cell == nil) {
                                cell = [[SinglePicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:kWhiteBgColor];
                            }
                            ((SinglePicCell *)cell).model = model;
                            [cell setNeedsLayout];
                            return cell;
                        }
                        case NEWS_SinglePic:
                        {
                            // 单图cell
                            static NSString *cellID = @"SinglePicCellID";
                            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                            if (cell == nil) {
                                cell = [[SinglePicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:kWhiteBgColor];
                            }
                            ((SinglePicCell *)cell).model = model;
                            ((SinglePicCell *)cell).isHaveVideo = NO;
                            [cell setNeedsLayout];
                            return cell;
                        }
                        case NEWS_NoPic:
                        {
                            // 无图cell
                            static NSString *cellID = @"NoPicCellID";
                            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                            if (cell == nil) {
                                cell = [[NoPicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:kWhiteBgColor];
                            }
                            ((NoPicCell *)cell).model = model;
                            [cell setNeedsLayout];
                            return cell;
                        }
                        case NEWS_BigPic:
                        {
                            // 单图cell
                            static NSString *cellID = @"SinglePicCellID";
                            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                            if (cell == nil) {
                                cell = [[SinglePicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:kWhiteBgColor];
                            }
                            ((SinglePicCell *)cell).model = model;
                            [cell setNeedsLayout];
                            return cell;
                        }
                        case NEWS_HaveVideo:
                        {
                            // 单图cell
                            static NSString *cellID = @"SinglePicCellID";
                            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                            if (cell == nil) {
                                cell = [[SinglePicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:kWhiteBgColor];
                            }
                            ((SinglePicCell *)cell).model = model;
                            ((SinglePicCell *)cell).isHaveVideo = YES;
                            [cell setNeedsLayout];
                            return cell;
                        }
                        case NEWS_OnlyVideo:
                        {
                            // 视频cell
                            static NSString *cellID = @"SingleVideoCell";
                            SingleVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                            if (cell == nil) {
                                cell = [[SingleVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:kWhiteBgColor];
                            }
                            cell.model = model;
                            cell.selectionStyle = UITableViewCellSelectionStyleNone;
                            [cell setNeedsLayout];
                            return cell;
                        }
                    }
                }
            }
            break;
        }
        case 2:
        {
            // 新闻评论
            switch (indexPath.row) {
                case 0:
                {
                    static NSString *cellID = @"commentsCellID";
                    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                    }
                    if (cell.contentView.subviews.count <= 0) {
                        _recommentsView = [[RecommendedView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30) titleImage:[UIImage imageNamed:@"icon_article_comments_small"] titleText:@"Comments" HaveLoading:YES];
                        [cell.contentView addSubview:_recommentsView];
                    }
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    return cell;
                    break;
                }
                default:
                {
                    // 评论cell
                    static NSString *cellID = @"commentID";
                    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                    if (cell == nil) {
                        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                    }
                    if (_commentArray.count > 0) {
                        [self.noCommentView removeFromSuperview];
                        ((CommentCell *)cell).model = _commentArray[indexPath.row - 1];
                    } else {
                        [cell.contentView addSubview:self.noCommentView];
                    }
                    [cell setNeedsLayout];
                    return cell;
                    break;
                }
            }
            break;
        }
        default:
            break;
    }
    static NSString *cellID = @"newsListCellID";
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.backgroundColor = kWhiteBgColor;
    [cell setNeedsLayout];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 1:
        {
            if (indexPath.row > 0) {
                if (_recommend_news.count <= 0) {
                    return;
                }
                NewsModel *model = _recommend_news[indexPath.row - 1];
                VideoModel *videoModel = model.videos.firstObject;
                [self.playerView loadWithVideoId:videoModel.youtube_id playerVars:_playerVars];
                _isOther = YES;
                if (model.news_id.length <= 0) {
                    return;
                }
                // 打点-推荐区文章点击-010218
                NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                               _channelName, @"channel",
                                               _model.news_id, @"article",
                                               nil];
                [Flurry logEvent:@"Article_ReArticle_Click" withParameters:articleParams];
#if DEBUG
                [iConsole info:[NSString stringWithFormat:@"Article_ReArticle_Click:%@",articleParams],nil];
#endif
                // 服务器打点-详情页点击相关推荐-020202
                NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
                [eventDic setObject:@"020202" forKey:@"id"];
                [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
                [eventDic setObject:model.news_id forKey:@"news_id"];
                [eventDic setObject:_model.news_id forKey:@"refer"];
                [eventDic setObject:@"1" forKey:@"pos"];
                NSMutableArray *newslist = [NSMutableArray array];
                @autoreleasepool {
                    for (NewsModel *model in _recommend_news) {
                        [newslist addObject:model.news_id];
                    }
                }
                [eventDic setObject:newslist forKey:@"newslist"];
                [eventDic setObject:[NetType getNetType] forKey:@"net"];
                if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
                    [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
                    [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
                } else {
                    [eventDic setObject:@"" forKey:@"lng"];
                    [eventDic setObject:@"" forKey:@"lat"];
                }
                NSDictionary *sessionDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                            DEF_PERSISTENT_GET_OBJECT(@"UUID"), @"id",
                                            [NSArray arrayWithObject:eventDic], @"events",
                                            nil];
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[NSArray arrayWithObject:sessionDic] forKey:@"sessions"];
                [[SSHttpRequest sharedInstance] post:@"" params:params contentType:JsonType serverType:NetServer_Log success:^(id responseObj) {
                    // 打点成功
                } failure:^(NSError *error) {
                    // 打点失败
                    [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(@"UUID") forKey:@"session"];
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [appDelegate.eventArray addObject:eventDic];
                } isShowHUD:NO];
                
                _model = model;
                _recommend_news = [NSMutableArray array];
                _commentArray = [NSMutableArray array];
                [self.tableView reloadData];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                // 新闻推荐网络请求
                [self recommendWithNewsID:model.news_id AppDelegate:appDelegate];
                // 评论网络请求
                [self requsetCommentsListWithNewsID:model.news_id];
            }
            break;
        }
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    float page_pos = (scrollView.contentOffset.y + kScreenHeight - 170) / _webView.height;
//    if (page_pos >= 1.0 && !_webView.loading) {
//        // 推荐文章展示
//        self.isRecommendShow = YES;
//    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (_commentTextView.textView.text.length > 0) {
        _commentTextView.placeholderLabel.hidden = YES;
        _commentTextView.isInput = YES;
    } else {
        _commentTextView.placeholderLabel.hidden = NO;
        _commentTextView.isInput = NO;
    }
}

#pragma mark - setter/getter
- (UIView *)noCommentView
{
    if (_noCommentView == nil) {
        _noCommentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 90)];
        _noCommentView.backgroundColor = kWhiteBgColor;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 33) * .5, 20, 33, 31)];
        imageView.backgroundColor = kWhiteBgColor;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageNamed:@"icon_nocomment"];
        [_noCommentView addSubview:imageView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 150) * .5, imageView.bottom + 5, 150, 15)];
        textLabel.backgroundColor = kWhiteBgColor;
        textLabel.textColor = kGrayColor;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = [UIFont systemFontOfSize:13];
        textLabel.text = @"No comments yet";
        [_noCommentView addSubview:textLabel];
    }
    return _noCommentView;
}

- (void)setCommentArray:(NSMutableArray *)commentArray
{
    _commentArray = commentArray;
    
    __weak typeof(self) weakSelf = self;
    if (commentArray.count > 0) {
        [self.tableView addLegendFooterWithRefreshingBlock:^{
            [weakSelf tableViewDidTriggerFooterRefresh];
            [weakSelf.tableView.footer beginRefreshing];
        }];
        [weakSelf.tableView.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
        [weakSelf.tableView.footer setTitle:@"Loading..." forState:MJRefreshFooterStateRefreshing];
        [weakSelf.tableView.footer setTitle:@"No more comments" forState:MJRefreshFooterStateNoMoreData];
    } else {
        [weakSelf.tableView removeFooter];
    }
}

// 评论视图
- (UIView *)commentsView
{
    if (_commentsView == nil) {
        _commentsView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 50, kScreenWidth, 50)];
        _commentsView.backgroundColor = [UIColor whiteColor];
        _commentsView.layer.borderWidth = 1;
        _commentsView.layer.borderColor = SSColor(235, 235, 235).CGColor;
        _commentsView.userInteractionEnabled = YES;
        
        CommentTextField *textField = [[CommentTextField alloc] initWithFrame:CGRectMake(11, 8, kScreenWidth - 22 - 19 * 3 - 24 * 3, 34)];
        [_commentsView addSubview:textField];
        UIView *view = [[UIView alloc] initWithFrame:textField.frame];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentAction)];
        [view addGestureRecognizer:tap];
        [_commentsView addSubview:view];
        
        for (int i = 0; i < 3; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(textField.right + 10 + 43 * i, 0, 42, 50);
            button.tag = 300 + i;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            switch (i) {
                case 0:
                {
                    [button setImage:[UIImage imageNamed:@"icon_article_comments_default"] forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:@"icon_article_comments_select"] forState:UIControlStateHighlighted];
                    break;
                }
                case 1:
                    [button setImage:[UIImage imageNamed:@"icon_article_collect_default"] forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:@"icon_article_collect_select"] forState:UIControlStateSelected];
                    [button setImage:[UIImage imageNamed:@"icon_article_collect_select"] forState:UIControlStateHighlighted];
//                    if (![_detailModel.collect_id isEqualToString:@"0"]) {
//                        button.selected = YES;
//                        _collectID = _detailModel.collect_id;
//                    } else {
//                        if ([[CoreDataManager sharedInstance] searchLocalFavoriteModelWithNewsID:_model.news_id]) {
//                            button.selected = YES;
//                        }
//                    }
                    break;
                case 2:
                    [button setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
                    break;
                default:
                    break;
            }
            [_commentsView addSubview:button];
            
            if (i == 0) {
                _commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
                _commentsLabel.center = CGPointMake(button.right - 10, button.top + 16);
                _commentsLabel.backgroundColor = SSColor(255, 0, 0);
                _commentsLabel.layer.cornerRadius = 5.0f;
                _commentsLabel.layer.masksToBounds = YES;
                _commentsLabel.textAlignment = NSTextAlignmentCenter;
                _commentsLabel.font = [UIFont systemFontOfSize:10];
                _commentsLabel.textColor = [UIColor whiteColor];
                _commentsLabel.hidden = YES;
                [_commentsView addSubview:_commentsLabel];
//                if (_detailModel.commentCount.integerValue > 0) {
//                    _commentsLabel.hidden = NO;
//                    int width;
//                    if (_detailModel.commentCount.integerValue < 10) {
//                        width = 12;
//                    } else if (_detailModel.commentCount.integerValue < 100) {
//                        width = 16;
//                    } else if (_detailModel.commentCount.integerValue < 1000) {
//                        width = 22;
//                    } else {
//                        width = 28;
//                    }
//                    _commentsLabel.width = width;
//                    if (_detailModel.commentCount.integerValue < 1000) {
//                        _commentsLabel.text = _detailModel.commentCount.stringValue;
//                    } else {
//                        _commentsLabel.text = @"999+";
//                    }
//                }
            }
        }
    }
    return _commentsView;
}

#pragma mark - YTPlayerViewDelegate
- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.playerView playVideo];
    });
}


#pragma mark - UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPop) {
        _fromCell.isMove = YES;
        PopTransitionAnimate *popTransition = [[PopTransitionAnimate alloc] initWithToView:_toView];
        return popTransition;
    }else{
        return nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
