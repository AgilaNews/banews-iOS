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
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _playerView.bottom, kScreenWidth, kScreenHeight - _playerView.bottom) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = kWhiteBgColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.sectionHeaderHeight = 0;
    _tableView.sectionFooterHeight = 0;
    _tableView.separatorColor = SSColor(235, 235, 235);
    [self.view addSubview:_tableView];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self recommendWithNewsID:_model.news_id AppDelegate:appDelegate];
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
        NSDictionary *playerVars = @{@"autohide" : @2,          // 参数设为1，则视频进度条和播放器控件将会在视频开始播放几秒钟后退出播放界面。
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
        [self.playerView loadWithVideoId:model.youtube_id playerVars:playerVars];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_RecoverVideo
                                                        object:@{@"index":_indexPath,
                                                                 @"playerView":_playerView}];
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
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:newsID forKey:@"news_id"];
    [[SSHttpRequest sharedInstance] get:kHomeUrl_Recommend params:params contentType:JsonType serverType:NetServer_Video success:^(id responseObj) {
        [appDelegate.likedDic setValue:@1 forKey:newsID];
        NSArray *recommends = responseObj[@"recommend_news"];
        _recommend_news = [NSMutableArray array];
        for (NSDictionary *dic in recommends) {
            NewsModel *model = [NewsModel mj_objectWithKeyValues:dic];
            [_recommend_news addObject:model];
        }
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        
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
//            if (_commentArray.count > 0) {
//                return _commentArray.count + 1;
//            } else {
                return 2;
//            }
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
            CGSize titleLabelSize = [_model.title calculateSize:CGSizeMake(kScreenWidth - 22, 60) font:[UIFont boldSystemFontOfSize:21]];
            CGSize contentLabelSize = CGSizeZero;
            VideoModel *model = _model.videos.firstObject;
            if (_isContentOpen) {
                contentLabelSize = [model.content calculateSize:CGSizeMake(kScreenWidth - 22 - 20, 1500) font:[UIFont systemFontOfSize:12]];
            } else {
                contentLabelSize = [model.content calculateSize:CGSizeMake(kScreenWidth - 22 - 20, 30) font:[UIFont systemFontOfSize:12]];
            }
            return 16 + titleLabelSize.height + 13 + 12 + 14 + contentLabelSize.height + 30 + 34 + 25;
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
//                    if (_commentArray.count > 0) {
//                        CommentModel *model = _commentArray[indexPath.row - 1];
//                        CGSize commentLabelSize = [model.comment calculateSize:CGSizeMake(kScreenWidth - 55 - 11, 1000) font:[UIFont systemFontOfSize:14]];
//                        return 10 + 5 + 16 + 12 + commentLabelSize.height + 10;
//                    } else {
                        return 90;
//                    }
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
                        _recommendedView = [[RecommendedView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30) titleImage:[UIImage imageNamed:@"icon_article_recommend_small"] titleText:@"Recommended for you"];
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
                        _commentsView = [[RecommendedView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30) titleImage:[UIImage imageNamed:@"icon_article_comments_small"] titleText:@"Comments"];
                        [cell.contentView addSubview:_commentsView];
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
//                    if (_commentArray.count > 0) {
//                        [self.noCommentView removeFromSuperview];
//                        ((CommentCell *)cell).model = _commentArray[indexPath.row - 1];
//                    } else {
//                        [cell.contentView addSubview:self.noCommentView];
//                    }
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

#pragma mark - YTPlayerViewDelegate
- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.playerView playVideo];
    });
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
