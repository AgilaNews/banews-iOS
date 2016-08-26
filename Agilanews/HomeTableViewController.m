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
#import "OnlyPicCell.h"
#import "GifPicCell.h"
#import "AppDelegate.h"
#import "BannerView.h"
#import "AppDelegate.h"
#import "HomeViewController.h"

#define titleFont_Normal        [UIFont systemFontOfSize:16]
#define titleFont_ExtraLarge    [UIFont systemFontOfSize:20]
#define titleFont_Large         [UIFont systemFontOfSize:18]
#define titleFont_Small         [UIFont systemFontOfSize:14]

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
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
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
    self.tableView.separatorColor = SSColor(232, 232, 232);
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 11, 0, 11);
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
        if ([[NSDate date] timeIntervalSince1970] - checkNum.longLongValue < 3600) {
            _dataList = [NSMutableArray arrayWithArray:newsData[newsData.allKeys.firstObject][_model.channelID]];
        } else if ([_model.channelID isEqualToNumber:@10001])
        {
            // 请求数据
            [self requestDataWithChannelID:_model.channelID isLater:YES isShowHUD:NO];
        }
        if (![DEF_PERSISTENT_GET_OBJECT(SS_GuideHomeKey) isEqualToNumber:@1] && [_model.channelID isEqualToNumber:@10001]) {
            [[UIApplication sharedApplication].keyWindow addSubview:[GuideRefreshView sharedInstance]];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
            break;
        case NEWS_SinglePic:
        {
            return 12 + 68 + 12;
        }
            break;
        case NEWS_NoPic:
        {
            CGSize titleLabelSize = [model.title calculateSize:CGSizeMake(kScreenWidth - 22, 60) font:titleFont];
            return 11 + titleLabelSize.height + 15 + 11 + 11;
        }
            break;
//        case NEWS_OnlyPic:
//        {
//            
//        }
//            break;
//        case NEWS_GifPic:
//        {
//            
//        }
//            break;
        default:
            return 50;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
            break;
        case NEWS_SinglePic:
        {
            // 单图cell
            static NSString *cellID = @"SinglePicCellID";
            SinglePicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[SinglePicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
            }
            cell.model = model;
            [cell setNeedsLayout];
            return cell;
        }
            break;
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
            break;
//        case NEWS_OnlyPic:
//        {
//            // 纯图cell
//            NSLog(@"纯图cell");
//            static NSString *cellID = @"OnlyPicCellID";
//            OnlyPicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
//            if (cell == nil) {
//                cell = [[OnlyPicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
//            }
//            cell.model = model;
//            [cell setNeedsLayout];
//            return cell;
//        }
//            break;
//        case NEWS_GifPic:
//        {
//            // gif图cell
//            NSLog(@"gif图cell");
//            static NSString *cellID = @"GifPicCellID";
//            GifPicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
//            if (cell == nil) {
//                cell = [[GifPicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
//            }
//            cell.model = model;
//            [cell setNeedsLayout];
//            return cell;
//        }
//            break;
        default:
            break;
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
    NewsModel *model = _dataList[indexPath.row];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

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
    
    [appDelegate.checkDic setObject:@1 forKey:model.news_id];
    NewsDetailViewController *newsDetailVC = [[NewsDetailViewController alloc] init];
    newsDetailVC.model = model;
    newsDetailVC.channelName = _model.name;
    [self.navigationController pushViewController:newsDetailVC animated:YES];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!_isDecelerating) {
            UITableViewCell *cell = self.tableView.visibleCells.lastObject;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            if (_dataList.count <= indexPath.row) {
                return;
            }
            NewsModel *model = _dataList[indexPath.row];
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
    NewsModel *model = _dataList[indexPath.row];
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
- (void)requestDataWithChannelID:(NSNumber *)channelID isLater:(BOOL)later isShowHUD:(BOOL)showHUD
{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // 频道ID
    [params setObject:channelID forKey:@"channel_id"];
    if (later == NO) {
        [params setObject:@"older" forKey:@"dir"];
    }
    [[SSHttpRequest sharedInstance] get:kHomeUrl_NewsList params:params contentType:UrlencodedType serverType:NetServer_Home success:^(id responseObj) {
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
                        model.public_time = [NSNumber numberWithLongLong:[lastModel.public_time longLongValue] - (arc4random() % 240 + 60)];
                    }
                }
                [models addObject:model];
            }
        }
        if (later == YES) {
            // 打点-下拉刷新成功-010113
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _model.name, @"channel",
                                           nil];
            [Flurry logEvent:@"Home_List_DownRefresh_Y" withParameters:articleParams];
#if DEBUG
            [iConsole info:[NSString stringWithFormat:@"Home_List_DownRefresh_Y:%@",articleParams],nil];
#endif
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
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewDidTriggerHeaderRefresh)];
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
    [self requestDataWithChannelID:_model.channelID isLater:YES isShowHUD:YES];
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
    [self requestDataWithChannelID:_model.channelID isLater:NO isShowHUD:NO];
}


#pragma mark - Notification
/**
 *  点击logo通知刷新事件
 *
 *  @param notif KNOTIFICATION_Refresh
 */
- (void)requestDataWithRefreshNotif:(NSNotification *)notif
{
    if ([self.tableView isDisplayedInScreen]) {
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
        [self.tableView.header beginRefreshing];
    } else if ([cateModel.channelID isEqualToNumber:_model.channelID] && ([[NSDate date] timeIntervalSince1970] - _refreshTime) > 3600) {
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
        [self.tableView.header beginRefreshing];
//        [self requestDataWithChannelID:_model.channelID isLater:YES isShowHUD:NO];
    } else if ([cateModel.channelID isEqualToNumber:_model.channelID] && ([[NSDate date] timeIntervalSince1970] - _refreshTime) > 3600) {
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSNumber *backgroundTime = DEF_PERSISTENT_GET_OBJECT(@"BackgroundTime");
        if ([[NSDate date] timeIntervalSince1970] - backgroundTime.longLongValue > 3600)
        {
            _dataList = [NSMutableArray array];
            if ([self.tableView isDisplayedInScreen]) {
                [self.tableView.header beginRefreshing];
            }
        } else {
            @autoreleasepool {
                NSString *newsFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/news.data"];
                NSDictionary *newsData = [NSKeyedUnarchiver unarchiveObjectWithFile:newsFilePath];
                _dataList = [NSMutableArray arrayWithArray:newsData[newsData.allKeys.firstObject][_model.channelID]];
                [self.tableView reloadData];
            }
        }
    });
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
