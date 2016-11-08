//
//  HomeTableViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/7/14.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "HomeTableViewController.h"
#import "BaseNavigationController.h"
#import "NewsDetailViewController.h"
#import "NewsModel.h"
#import "ManyPicCell.h"
#import "SinglePicCell.h"
#import "NoPicCell.h"
#import "BigPicCell.h"
#import "OnlyPicCell.h"
#import "GifPicCell.h"
#import "OnlyVideoCell.h"
#import "RefreshCell.h"
#import "AppDelegate.h"
#import "BannerView.h"
#import "AppDelegate.h"
#import "HomeViewController.h"
#import "ImageModel.h"
#import "LoginViewController.h"
#import "VideoDetailViewController.h"
#import "PushTransitionAnimate.h"

#define titleFont_Normal        [UIFont systemFontOfSize:16]
#define titleFont_ExtraLarge    [UIFont systemFontOfSize:20]
#define titleFont_Large         [UIFont systemFontOfSize:18]
#define titleFont_Small         [UIFont systemFontOfSize:14]

#define imageHeight 162 * kScreenWidth / 320.0
#define videoHeight 180 * kScreenWidth / 320.0

@import SafariServices;
@interface HomeTableViewController ()

@end

@implementation HomeTableViewController

- (instancetype)initWithModel:(CategoriesModel *)model
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _model = model;
    }
    return self;
}

#pragma mark - 视图生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _isShowBanner = YES;
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestDataWithRefreshNotif:)
                                                 name:KNOTIFICATION_Refresh
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestDataWithSecectNotif:)
                                                 name:KNOTIFICATION_Secect_Channel
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestDataWithScrollNotif:)
                                                 name:KNOTIFICATION_Scroll_Channel
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadDataAction)
                                                 name:KNOTIFICATION_TextOnly_ON
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadDataAction)
                                                 name:KNOTIFICATION_TextOnly_OFF
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadDataAction)
                                                 name:KNOTIFICATION_FontSize_Change
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushExit)
                                                 name:KNOTIFICATION_PushExit
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recoverVideo:)
                                                 name:KNOTIFICATION_RecoverVideo
                                               object:nil];
    
    // 创建表视图
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = kWhiteBgColor;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    if ([_model.channelID isEqualToNumber:@30001]) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, -11, 0, 0);
    } else {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 11, 0, 11);
    }
    self.tableView.separatorColor = SSColor(232, 232, 232);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.showRefreshHeader = YES;
    self.showRefreshFooter = YES;
    if ([_model.channelID isEqualToNumber:@10001]) {
        self.tableView.scrollsToTop = YES;
    } else {
        self.tableView.scrollsToTop = NO;
    }
    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, .5)];
    _dataList = [NSMutableArray array];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSNumber *refreshNum = appDelegate.refreshTimeDic[_model.channelID];
    _refreshTime = refreshNum.longLongValue;
    @autoreleasepool {
        NSString *newsFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/news.data"];
        NSDictionary *newsData = [NSKeyedUnarchiver unarchiveObjectWithFile:newsFilePath];
        NSNumber *checkNum = newsData.allKeys.firstObject;
        NSArray *dataList = newsData[checkNum][_model.channelID];
        if ([[NSDate date] timeIntervalSince1970] - _refreshTime < 3600) {
            if (dataList.count == 0 && [_model.channelID isEqualToNumber:@10001]) {
                [self requestDataWithChannelID:_model.channelID isLater:YES isShowHUD:NO isShowBanner:NO];
            } else {                
                // 加载缓存
                _dataList = [NSMutableArray arrayWithArray:dataList];
                [self.tableView reloadData];
            }
        } else if ([[NetType getNetType] isEqualToString:@"unknow"] && dataList.count > 0) {
            // 无网状态下加载缓存
            _dataList = [NSMutableArray arrayWithArray:dataList];
            [self.tableView reloadData];
        } else if ([_model.channelID isEqualToNumber:@10001]) {
            // 请求数据
            [self requestDataWithChannelID:_model.channelID isLater:YES isShowHUD:NO isShowBanner:NO];
        }
    }
    if (![DEF_PERSISTENT_GET_OBJECT(SS_GuideHomeKey) isEqualToNumber:@1] && [_model.channelID isEqualToNumber:@10001]) {
        [[UIApplication sharedApplication].keyWindow addSubview:[GuideRefreshView sharedInstance]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        [self.navigationController.navigationBar setBarTintColor:kOrangeColor];
        UIView *barBgView = self.navigationController.navigationBar.subviews.firstObject;
        for (UIView *subview in barBgView.subviews) {
            if([subview isKindOfClass:[UIVisualEffectView class]]) {
                subview.backgroundColor = kOrangeColor;
                [subview removeAllSubviews];
            }
        }
    } else {
        [self.navigationController.navigationBar lt_setBackgroundColor:kOrangeColor];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= _dataList.count) {
        return 50;
    }
    if ([_dataList[indexPath.row] isKindOfClass:[NSString class]]) {
        return 35;
    }
    NewsModel *model = _dataList[indexPath.row];
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
            CGSize titleLabelSize = [model.title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:titleFont];
            return 11 + titleLabelSize.height + 10 + 70 + 10 + 11 + 11;
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
            CGSize titleLabelSize = [model.title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:titleFont];
            return 12 + titleLabelSize.height + imageHeight + 20 + 11 + 11;
        }
        case NEWS_OnlyPic:
        {
            CGSize titleLabelSize = [model.title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:titleFont];
            ImageModel *imageModel = model.imgs.firstObject;
            return 12 + titleLabelSize.height + 10 + imageModel.height.integerValue / 2.0 + 12 + 18 + 12;
        }
        case NEWS_GifPic:
        {
            CGSize titleLabelSize = [model.title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:titleFont];
            ImageModel *imageModel = model.imgs.firstObject;
            return 12 + titleLabelSize.height + 10 + imageModel.height.integerValue / 2.0 + 12 + 18 + 12;
        }
        case NEWS_HaveVideo:
        {
            return 12 + 68 + 12;
        }
        case NEWS_OnlyVideo:
        {
            return videoHeight + 42;
        }
        default:
            return 50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_dataList.count > 0) {
        if ([_dataList[indexPath.row] isKindOfClass:[NSString class]]) {
            // 刷新cell
            static NSString *cellID = @"RefreshCellID";
            RefreshCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[RefreshCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell setNeedsLayout];
            return cell;
        }
        NewsModel *model = _dataList[indexPath.row];
        switch ([model.tpl integerValue])
        {
            case NEWS_ManyPic:
            {
                // 多图cell
                static NSString *cellID = @"ManyPicCellID";
                ManyPicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[ManyPicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
                }
                cell.model = model;
                [cell setNeedsLayout];
                return cell;
            }
            case NEWS_SinglePic:
            {
                // 单图cell
                static NSString *cellID = @"SinglePicCellID";
                SinglePicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[SinglePicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
                }
                cell.model = model;
                cell.isHaveVideo = NO;
                [cell setNeedsLayout];
                return cell;
            }
            case NEWS_NoPic:
            {
                // 无图cell
                static NSString *cellID = @"NoPicCellID";
                NoPicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[NoPicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
                }
                cell.model = model;
                [cell setNeedsLayout];
                return cell;
            }
            case NEWS_BigPic:
            {
                // 大图cell
                static NSString *cellID = @"BigPicCellID";
                BigPicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[BigPicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
                }
                cell.model = model;
                [cell setNeedsLayout];
                return cell;
            }
            case NEWS_OnlyPic:
            {
                // 纯图cell
                static NSString *cellID = @"OnlyPicCellID";
                OnlyPicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[OnlyPicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
                    [cell.likeButton addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.shareButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
                }
                cell.model = model;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell setNeedsLayout];
                return cell;
            }
            case NEWS_GifPic:
            {
                // gif图cell
                static NSString *cellID = @"GifPicCellID";
                GifPicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[GifPicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
                    [cell.likeButton addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.shareButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
                }
                cell.model = model;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell setNeedsLayout];
                return cell;
            }
            case NEWS_HaveVideo:
            {
                // 单图cell
                static NSString *cellID = @"SinglePicCellID";
                SinglePicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[SinglePicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
                }
                cell.model = model;
                cell.isHaveVideo = YES;
                [cell setNeedsLayout];
                return cell;
            }
            case NEWS_OnlyVideo:
            {
                // 视频cell
                static NSString *cellID = @"OnlyVideoCell";
                OnlyVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[OnlyVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
                    [cell.shareButton addTarget:self action:@selector(shareToFacebook:) forControlEvents:UIControlEventTouchUpInside];
                }
                cell.model = model;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell setNeedsLayout];
                return cell;
            }
            default:
                break;
        }
    }
    static NSString *cellID = @"newsListCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    [cell setNeedsLayout];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= _dataList.count) {
        return;
    }
    if ([_dataList[indexPath.row] isKindOfClass:[NSString class]]) {
        // 打点-刷新位置提醒bar被点击-010125
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _model.name, @"channel",
                                       [NetType getNetType], @"network",
                                       nil];
        [Flurry logEvent:@"Home_LocationRemindBar_Click" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Home_LocationRemindBar_Click:%@",articleParams],nil];
#endif
        [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
        _isShowBanner = YES;
        [self.tableView.header beginRefreshing];
        return;
    }
    if ([_model.channelID isEqualToNumber:@10011] || [_model.channelID isEqualToNumber:@10012]) {
        // 点击图片频道和GIF频道
        return;
    }
    NewsModel *model = _dataList[indexPath.row];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (!model.news_id.length) {
        return;
    }
    // 打点-点击列表-010108
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   _model.name, @"channel",
                                   nil];
    [Flurry logEvent:@"Home_List_Click" withParameters:articleParams];
#if DEBUG
    [iConsole info:[NSString stringWithFormat:@"Home_List_Click:%@",articleParams],nil];
#endif
    // 服务器打点-列表页点击详情-020102
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *pagePos = [NSString stringWithFormat:@"%.1f",(cell.top - tableView.contentOffset.y + 1.5) / tableView.height];
    NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
    [eventDic setObject:@"020102" forKey:@"id"];
    [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
    [eventDic setObject:model.news_id forKey:@"news_id"];
    [eventDic setObject:[NSNumber numberWithInteger:indexPath.row] forKey:@"list_pos"];
    [eventDic setObject:_model.channelID forKey:@"refer"];
    [eventDic setObject:pagePos forKey:@"page_pos"];
    [eventDic setObject:model.issuedID forKey:@"dispatch_id"];
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
        [appDelegate.eventArray addObject:eventDic];
    } isShowHUD:NO];
    
    if ([_model.channelID isEqualToNumber:@30001] || model.tpl.integerValue == NEWS_OnlyVideo) {
        VideoDetailViewController *videoDetailVC = [[VideoDetailViewController alloc] init];
        videoDetailVC.model = model;
        videoDetailVC.channelName = _model.name;
        OnlyVideoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        videoDetailVC.playerView = cell.playerView;
        videoDetailVC.holderImage = cell.titleImageView.image;
        videoDetailVC.indexPath = indexPath;
        videoDetailVC.fromCell = cell;
        cell.isPlay = YES;
        cell.titleImageView.hidden = YES;
        [self.navigationController pushViewController:videoDetailVC animated:YES];
        return;
    }
    [appDelegate.checkDic setObject:@1 forKey:model.news_id];
    NewsDetailViewController *newsDetailVC = [[NewsDetailViewController alloc] init];
    newsDetailVC.model = model;
    newsDetailVC.channelName = _model.name;
    [self.navigationController pushViewController:newsDetailVC animated:YES];
}


/**
 cell不显示在tableView中

 @param tableView
 @param cell
 @param indexPath
 */
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= _dataList.count) {
        return;
    }
    NewsModel *model = _dataList[indexPath.row];
    if ([model isKindOfClass:[NSString class]]) {
        return;
    }
    if (model.tpl.integerValue == NEWS_OnlyVideo && [cell isKindOfClass:[OnlyVideoCell class]]) {
        ((OnlyVideoCell *)cell).isPlay = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y == 0) {
        [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, 0.5)];
        _scrollY = 0.5;
    }
}

// 滑动视图开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _beginScrollTime = [[NSDate date] timeIntervalSince1970] * 1000;
}

// 滑动视图停止拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y > _scrollY) {
        // 打点-上拉滑动-010116
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _model.name, @"channel",
                                       nil];
        [Flurry logEvent:@"Home_List_UpScroll" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Home_List_UpScroll:%@",articleParams],nil];
#endif
    }
    _scrollY = scrollView.contentOffset.y;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!_isDecelerating) {
            UITableViewCell *cell = weakSelf.tableView.visibleCells.lastObject;
            NSIndexPath *indexPath = [weakSelf.tableView indexPathForCell:cell];
            if (_dataList.count <= indexPath.row) {
                return;
            }
            if ([_dataList[indexPath.row] isKindOfClass:[NSString class]]) {
                return;
            }
            NewsModel *model = _dataList[indexPath.row];
            if (!model.news_id) {
                return;
            }
            // 服务器打点-列表页滑动-020101
            NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
            [eventDic setObject:@"020101" forKey:@"id"];
            [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
            [eventDic setObject:_model.channelID forKey:@"channel"];
            [eventDic setObject:model.news_id forKey:@"last_id"];
            long long duration = [[NSDate date] timeIntervalSince1970] * 1000 - _beginScrollTime;
            [eventDic setObject:[NSString stringWithFormat:@"%.1f",duration / 1000.0] forKey:@"duration"];
            [eventDic setObject:[NetType getNetType] forKey:@"net"];
            if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
                [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
                [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
            } else {
                [eventDic setObject:@"" forKey:@"lng"];
                [eventDic setObject:@"" forKey:@"lat"];
            }
            [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(@"UUID") forKey:@"session"];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.eventArray addObject:eventDic];
        }
    });
}

// 滑动视图开始惯性滚动
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    _isDecelerating = YES;
}
// 滑动视图停止惯性滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _isDecelerating = NO;
    _scrollY = scrollView.contentOffset.y;
    UITableViewCell *cell = self.tableView.visibleCells.lastObject;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (_dataList.count <= indexPath.row) {
        return;
    }
    if ([_dataList[indexPath.row] isKindOfClass:[NSString class]]) {
        return;
    }
    NewsModel *model = _dataList[indexPath.row];
    if (!model.news_id) {
        return;
    }
    // 服务器打点-列表页滑动-020101
    NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
    [eventDic setObject:@"020101" forKey:@"id"];
    [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
    [eventDic setObject:_model.channelID forKey:@"channel"];
    [eventDic setObject:model.news_id forKey:@"last_id"];
    long long duration = [[NSDate date] timeIntervalSince1970] * 1000 - _beginScrollTime;
    [eventDic setObject:[NSString stringWithFormat:@"%.1f",duration / 1000.0] forKey:@"duration"];
    [eventDic setObject:[NetType getNetType] forKey:@"net"];
    if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
    } else {
        [eventDic setObject:@"" forKey:@"lng"];
        [eventDic setObject:@"" forKey:@"lat"];
    }
    [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(@"UUID") forKey:@"session"];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.eventArray addObject:eventDic];
}

#pragma mark - Network
/**
 *  网络请求
 *
 *  @param channelID 频道ID
 */
- (void)requestDataWithChannelID:(NSNumber *)channelID isLater:(BOOL)later isShowHUD:(BOOL)showHUD isShowBanner:(BOOL)showBanner
{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // 频道ID
    [params setObject:channelID forKey:@"channel_id"];
    if (later == NO) {
        [params setObject:@"older" forKey:@"dir"];
    }
    NetServerType type;
    if ([_model.channelID isEqualToNumber:@30001]) {
        type = NetServer_Video;
    } else {
        type = NetServer_Home;
    }
    [[SSHttpRequest sharedInstance] get:kHomeUrl_NewsList params:params contentType:UrlencodedType serverType:type success:^(id responseObj) {
        [SVProgressHUD dismiss];
        NSMutableArray *models = [NSMutableArray array];
        for (NSDictionary *dic in [responseObj valueForKey:[responseObj allKeys].firstObject])
        {
            @autoreleasepool {
                NewsModel *model = [NewsModel mj_objectWithKeyValues:dic];
                model.issuedID = [responseObj allKeys].firstObject;
                if (later == YES) {
                    model.public_time = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
                } else {
                    if (models.count > 0) {
                        NewsModel *lastModel = models.lastObject;
                        model.public_time = [NSNumber numberWithLongLong:[lastModel.public_time longLongValue] - (arc4random() % 240 + 60)];
                    } else {
                        NewsModel *lastModel = _dataList.lastObject;
                        if ([lastModel isKindOfClass:[NSString class]]) {
                            model.public_time = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
                        } else {
                            model.public_time = [NSNumber numberWithLongLong:[lastModel.public_time longLongValue] - (arc4random() % 240 + 60)];
                        }
                    }
                }
                [models addObject:model];
            }
        }
        if (showBanner) {
            [models addObject:[NSString stringWithFormat:@"refresh"]];
        }
        if (_dataList == nil) {
            _dataList = [NSMutableArray array];
        }
        if (later == YES) {
            _isShowBanner = YES;
            // 打点-下拉刷新成功-010113
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _model.name, @"channel",
                                           nil];
            [Flurry logEvent:@"Home_List_DownRefresh_Y" withParameters:articleParams];
#if DEBUG
            [iConsole info:[NSString stringWithFormat:@"Home_List_DownRefresh_Y:%@",articleParams],nil];
#endif
            NSArray *dataList = [_dataList copy];
            for (id object in dataList) {
                if ([object isKindOfClass:[NSString class]]) {
                    [_dataList removeObject:object];
                }
            }
            [_dataList insertObjects:models atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, models.count)]];
            [weakSelf tableViewDidFinishTriggerHeader:YES reload:YES];
            weakSelf.refreshTime = [[NSDate date] timeIntervalSince1970];
        } else {
            // 打点-上拉加载成功-010110
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _model.name, @"channel",
                                           nil];
            [Flurry logEvent:@"Home_List_UpLoad_Y" withParameters:articleParams];
#if DEBUG
            [iConsole info:[NSString stringWithFormat:@"Home_List_UpLoad_Y:%@",articleParams],nil];
#endif
            [_dataList addObjectsFromArray:models];
            [weakSelf tableViewDidFinishTriggerHeader:NO reload:YES];
        }
        if (showHUD) {
            [[BannerView sharedInstance] showBannerWithText:DEF_banner((unsigned long)models.count) superView:weakSelf.tableView];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Refresh_Success object:nil];
    } failure:^(NSError *error) {
        if (later == YES) {
            _isShowBanner = YES;
            // 打点-下拉刷新失败-010114
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _model.name, @"channel",
                                           nil];
            [Flurry logEvent:@"Home_List_DownRefresh_N" withParameters:articleParams];
#if DEBUG
            [iConsole info:[NSString stringWithFormat:@"Home_List_DownRefresh_N:%@",articleParams],nil];
#endif
            [weakSelf tableViewDidFinishTriggerHeader:YES reload:NO];
        } else {
            // 打点-上拉加载失败-010111
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _model.name, @"channel",
                                           nil];
            [Flurry logEvent:@"Home_List_UpLoad_N" withParameters:articleParams];
#if DEBUG
            [iConsole info:[NSString stringWithFormat:@"Home_List_UpLoad_N:%@",articleParams],nil];
#endif
            [weakSelf tableViewDidFinishTriggerHeader:NO reload:NO];
        }
        if (_dataList.count <= 0) {
            // 打点-页面进入-011001
            [Flurry logEvent:@"NetFailure_Enter"];
#if DEBUG
            [iConsole info:@"NetFailure_Enter",nil];
#endif
            weakSelf.showTableBlankView = YES;
            weakSelf.blankView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchFailureView)];
            [weakSelf.blankView addGestureRecognizer:tap];
            if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
                weakSelf.blankLabel.text = @"Network unavailable";
                weakSelf.failureView.image = [UIImage imageNamed:@"icon_common_netoff"];
            } else {
                weakSelf.blankLabel.text = @"Sorry,please try again";
                weakSelf.failureView.image = [UIImage imageNamed:@"icon_common_failed"];
            }
        } else {
            weakSelf.showTableBlankView = NO;
        }
    } isShowHUD:showHUD];
}

/**
 *  下拉刷新事件
 */
- (void)tableViewDidTriggerHeaderRefresh
{
    // 打点-下拉刷新-010112
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   _model.name, @"channel",
                                   nil];
    [Flurry logEvent:@"Home_List_DownRefresh" withParameters:articleParams];
#if DEBUG
    [iConsole info:[NSString stringWithFormat:@"Home_List_DownRefresh:%@",articleParams],nil];
#endif
    [self requestDataWithChannelID:_model.channelID isLater:YES isShowHUD:YES isShowBanner:_isShowBanner];
}

/**
 *  点击失败页面
 */
- (void)touchFailureView
{
    if (self.showTableBlankView) {
        self.showTableBlankView = NO;
        self.blankView.userInteractionEnabled = NO;
        SVProgressHUD.defaultStyle = SVProgressHUDStyleCustom;
        [SVProgressHUD show];
    }
    [self requestDataWithChannelID:_model.channelID isLater:YES isShowHUD:YES isShowBanner:NO];
}

/**
 *  上拉加载事件
 */
- (void)tableViewDidTriggerFooterRefresh
{
    // 打点-上拉加载-010109
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   _model.name, @"channel",
                                   nil];
    [Flurry logEvent:@"Home_List_UpLoad" withParameters:articleParams];
#if DEBUG
    [iConsole info:[NSString stringWithFormat:@"Home_List_UpLoad:%@",articleParams],nil];
#endif
    [self requestDataWithChannelID:_model.channelID isLater:NO isShowHUD:YES isShowBanner:NO];
}

/**
 *  点赞按钮网络请求
 *
 *  @param appDelegate
 *  @param button      点赞按钮
 */
- (void)likedNewsWithAppDelegate:(AppDelegate *)appDelegate button:(UIButton *)button model:(NewsModel *)model
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:model.news_id forKey:@"news_id"];
    [[SSHttpRequest sharedInstance] post:kHomeUrl_Like params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        [appDelegate.likedDic setValue:@1 forKey:model.news_id];
        model.likedCount = responseObj[@"liked"];
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
    id cell = button.superview;
    do {
        if ([cell isKindOfClass:[UITableViewCell class]]) {
            break;
        }
        cell = ((UIView *)cell).superview;
    } while (cell != nil);
    NewsModel *newsModel = ((OnlyPicCell *)cell).model;
    // 打点-点赞-010117
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   _model.name, @"channel",
                                   newsModel.news_id, @"article",
                                   nil];
    [Flurry logEvent:@"Home_List_Like_Click" withParameters:articleParams];
#if DEBUG
    [iConsole info:[NSString stringWithFormat:@"Home_List_Like_Click:%@",articleParams],nil];
#endif
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (button.selected) {
        if (button.titleLabel.text.intValue > 1) {
            newsModel.likedCount = [NSNumber numberWithInteger:newsModel.likedCount.integerValue - 1];
        } else {
            [button setTitle:@"" forState:UIControlStateNormal];
            newsModel.likedCount = @0;
        }
        [appDelegate.likedDic setValue:@0 forKey:newsModel.news_id];
    } else {
        newsModel.likedCount = [NSNumber numberWithInteger:newsModel.likedCount.integerValue + 1];
        if (appDelegate.likedDic[newsModel.news_id] == nil) {
            [self likedNewsWithAppDelegate:appDelegate button:button model:newsModel];
        }
        [appDelegate.likedDic setValue:@1 forKey:newsModel.news_id];
    }
    [((OnlyPicCell *)cell) setNeedsLayout];
}


/**
 分享到Facebook

 @param button 
 */
- (void)shareToFacebook:(UIButton *)button
{
    id cell = button.superview;
    do {
        if ([cell isKindOfClass:[UITableViewCell class]]) {
            break;
        }
        cell = ((UIView *)cell).superview;
    } while (cell != nil);
    NewsModel *newsModel = ((OnlyPicCell *)cell).model;

    __weak typeof(self) weakSelf = self;
    // 打点-分享至facebook-010219
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   _model.name, @"channel",
                                   newsModel.news_id, @"article",
                                   nil];
    [Flurry logEvent:@"Home_List_Share_FacebookClick" withParameters:articleParams];
#if DEBUG
    [iConsole info:[NSString stringWithFormat:@"Home_List_Share_FacebookClick:%@",articleParams],nil];
#endif
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.model) {
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        NSString *shareString = newsModel.share_url;
        shareString = [shareString stringByReplacingOccurrencesOfString:@"{from}" withString:@"facebook"];
        content.contentURL = [NSURL URLWithString:shareString];
        content.contentTitle = newsModel.title;
        ImageModel *imageModel = newsModel.imgs.firstObject;
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
}

 /**
 *  分享按钮点击事件
 *
 *  @param button 分享按钮
 */
- (void)shareAction:(UIButton *)button
{
    id cell = button.superview;
    do {
        if ([cell isKindOfClass:[UITableViewCell class]]) {
            break;
        }
        cell = ((UIView *)cell).superview;
    } while (cell != nil);
    NewsModel *newsModel = ((OnlyPicCell *)cell).model;
    
    __weak typeof(self) weakSelf = self;
    [SSUIShareActionSheetStyle setCancelButtonLabelColor:kGrayColor];
    [SSUIShareActionSheetStyle setItemNameFont:[UIFont systemFontOfSize:13]];
    [SSUIShareActionSheetStyle setItemNameColor:kBlackColor];
    
    // 分享到facebook
    SSUIShareActionSheetCustomItem *facebook = [SSUIShareActionSheetCustomItem itemWithIcon:[UIImage imageNamed:@"icon_share_facebook"] label:@"Facebook" onClick:^{
        // 打点-分享至facebook-010219
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _model.name, @"channel",
                                       newsModel.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Home_List_Share_FacebookClick" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Home_List_Share_FacebookClick:%@",articleParams],nil];
#endif
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (appDelegate.model) {
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            NSString *shareString = newsModel.share_url;
            shareString = [shareString stringByReplacingOccurrencesOfString:@"{from}" withString:@"facebook"];
            content.contentURL = [NSURL URLWithString:shareString];
            content.contentTitle = newsModel.title;
            ImageModel *imageModel = newsModel.imgs.firstObject;
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
                                       _model.name, @"channel",
                                       newsModel.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Home_List_Share_TwitterClick" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Home_List_Share_TwitterClick:%@",articleParams],nil];
#endif
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (appDelegate.model) {
            NSString *shareString = newsModel.share_url;
            shareString = [shareString stringByReplacingOccurrencesOfString:@"{from}" withString:@"twitter"];
            TWTRComposer *composer = [[TWTRComposer alloc] init];
            [composer setText:newsModel.title];
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
                                       _model.name, @"channel",
                                       newsModel.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Home_List_Share_Google+Click" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Home_List_Share_Google+Click:%@",articleParams],nil];
#endif
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (appDelegate.model) {
            NSString *shareString = newsModel.share_url;
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

#pragma mark - Notification
/**
 *  点击logo通知刷新事件
 *
 *  @param notif KNOTIFICATION_Refresh
 */
- (void)requestDataWithRefreshNotif:(NSNotification *)notif
{
    if ([_model.channelID isEqualToNumber:notif.object]) {
        [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
        _isShowBanner = YES;
        [self.tableView.header beginRefreshing];
    }
}

/**
 *  点击频道通知刷新事件
 *
 *  @param notif KNOTIFICATION_Secect_Channel
 */
- (void)requestDataWithSecectNotif:(NSNotification *)notif
{
    CategoriesModel *cateModel = notif.object;
    if ([cateModel.channelID isEqualToNumber:_model.channelID] && _dataList.count <= 0) {
        _isShowBanner = NO;
        [self.tableView.header beginRefreshing];
    } else if ([cateModel.channelID isEqualToNumber:_model.channelID] && ([[NSDate date] timeIntervalSince1970] - _refreshTime) > 3600) {
        _isShowBanner = NO;
        [self.tableView.header beginRefreshing];
    } else {
        [self.tableView reloadData];
    }
}

/**
 *  滑动频道通知刷新事件
 *
 *  @param notif KNOTIFICATION_Scroll_Channel
 */
- (void)requestDataWithScrollNotif:(NSNotification *)notif
{
    CategoriesModel *cateModel = notif.object;
    if ([cateModel.channelID isEqualToNumber:_model.channelID] && _dataList.count <= 0) {
        _isShowBanner = NO;
        [self.tableView.header beginRefreshing];
    } else if ([cateModel.channelID isEqualToNumber:_model.channelID] && ([[NSDate date] timeIntervalSince1970] - _refreshTime) > 3600) {
        _isShowBanner = NO;
        [self.tableView.header beginRefreshing];
    } else {
        [self.tableView reloadData];
    }
}

/**
 *  程序即将进入前台通知
 */
- (void)applicationWillEnterForeground
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSNumber *refreshNum = appDelegate.refreshTimeDic[_model.channelID];
    _refreshTime = refreshNum.longLongValue;

    if ([[NSDate date] timeIntervalSince1970] - _refreshTime > 3600)
    {
        _dataList = [NSMutableArray array];
        if ([self.tableView isDisplayedInScreen]) {
            _isShowBanner = NO;
            // 修复下拉刷新位置卡住问题
            [self requestDataWithChannelID:_model.channelID isLater:YES isShowHUD:NO isShowBanner:NO];
        }
    } else {
        [self.tableView reloadData];
    }
}

// 从推送退出到列表页通知
- (void)pushExit
{
    if ([self.tableView isDisplayedInScreen]) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSNumber *refreshNum = appDelegate.refreshTimeDic[_model.channelID];
        _refreshTime = refreshNum.longLongValue;
        if ([[NSDate date] timeIntervalSince1970] - _refreshTime > 3600) {
            _dataList = [NSMutableArray array];
            _isShowBanner = NO;
            [self requestDataWithChannelID:_model.channelID isLater:YES isShowHUD:NO isShowBanner:NO];
        }
    }
}

/**
 *  无图模式开启通知
 */
- (void)reloadDataAction
{
    [self.tableView reloadData];
}

- (void)setRefreshTime:(long long)refreshTime
{
    if (_refreshTime != refreshTime) {
        _refreshTime = refreshTime;
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.refreshTimeDic setObject:[NSNumber numberWithLongLong:refreshTime] forKey:_model.channelID];
    }
}


/**
    视频从详情回位
 */
- (void)recoverVideo:(NSNotification *)notif
{
    if ([_model.channelID isEqualToNumber:@30001] || [_model.channelID isEqualToNumber:@10001]) {
        NSDictionary *dic = notif.object;
        YTPlayerView *playerView = dic[@"playerView"];
        NSIndexPath *indexPath = dic[@"index"];
        NSNumber *isPlay = dic[@"stop"];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[OnlyVideoCell class]]) {
            OnlyVideoCell *videoCell = (OnlyVideoCell *)cell;
            if (videoCell.isMove) {
                [videoCell.contentView addSubview:playerView];
                [videoCell.contentView bringSubviewToFront:videoCell.titleImageView];
                videoCell.isMove = NO;
                if ([isPlay isEqualToNumber:@1]) {
                    videoCell.isPlay = NO;
                }
            }
        }
    }
}

#pragma mark - UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    // && [_model.channelID isEqualToNumber:@30001]
    if(operation == UINavigationControllerOperationPush) {
        PushTransitionAnimate *pushTransition = [[PushTransitionAnimate alloc] init];
        return pushTransition;
    } else {
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
