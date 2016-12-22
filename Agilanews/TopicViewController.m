//
//  TopicViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/12/22.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "TopicViewController.h"
#import "ImageModel.h"
#import "ManyPicCell.h"
#import "SinglePicCell.h"
#import "NoPicCell.h"
#import "BigPicCell.h"
#import "OnlyVideoCell.h"
#import "NewsDetailViewController.h"
#import "VideoDetailViewController.h"
#import "AppDelegate.h"

#define titleFont_Normal        [UIFont systemFontOfSize:16]
#define titleFont_ExtraLarge    [UIFont systemFontOfSize:20]
#define titleFont_Large         [UIFont systemFontOfSize:18]
#define titleFont_Small         [UIFont systemFontOfSize:14]

#define imageHeight 162 * kScreenWidth / 320.0
#define videoHeight 180 * kScreenWidth / 320.0

@interface TopicViewController ()

@end

@implementation TopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.isBackButton = YES;
    self.title = @"Topics";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64) style:UITableViewStylePlain];
    _tableView.backgroundColor = kWhiteBgColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.sectionHeaderHeight = 0;
    _tableView.sectionFooterHeight = 0;
    _tableView.separatorColor = SSColor(235, 235, 235);
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    
    [self requestDataWithIsFooter:NO];
}

#pragma mark - Network
// 请求数据
- (void)requestDataWithIsFooter:(BOOL)isFooter
{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_model.news_id forKey:@"news_id"];
    [params setObject:@10 forKey:@"pn"];
    if (isFooter) {
        [params setObject:[NSNumber numberWithInteger:_dataList.count] forKey:@"from"];
    }
    [[SSHttpRequest sharedInstance] get:kHomeUrl_TopicDetail params:params contentType:JsonType serverType:NetServer_API2 success:^(id responseObj) {
        [SVProgressHUD dismiss];
        NSMutableArray *models = [NSMutableArray array];
        @autoreleasepool {
            for (NSDictionary *dic in responseObj[@"news"]) {
                NewsModel *model = [NewsModel mj_objectWithKeyValues:dic];
                [models addObject:model];
            }
        }
        if (isFooter) {
            NSArray *news = responseObj[@"news"];
            if (!news.count) {
                weakSelf.tableView.footer.state = MJRefreshFooterStateNoMoreData;
                return;
            }
            [weakSelf.dataList addObjectsFromArray:models];
            weakSelf.dataList = _dataList;
        } else {
            weakSelf.dataList = [NSMutableArray arrayWithArray:models];
        }
        if (_dataList.count == 0) {
            weakSelf.showBlankView = YES;
        } else {
            weakSelf.showBlankView = NO;
        }
        [_tableView reloadData];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        weakSelf.showBlankView = YES;
        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
            weakSelf.blankLabel.text = @"Network unavailable";
            weakSelf.failureView.image = [UIImage imageNamed:@"icon_common_netoff"];
        } else {
            weakSelf.blankLabel.text = @"Sorry,please try again";
            weakSelf.failureView.image = [UIImage imageNamed:@"icon_common_failed"];
        }
    } isShowHUD:NO];
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self requestDataWithIsFooter:YES];
}

/**
 *  失败页面请求网络
 */
- (void)requestData
{
    if (self.blankView) {
        self.showBlankView = NO;
        SVProgressHUD.defaultStyle = SVProgressHUDStyleCustom;
        [SVProgressHUD show];
    }
    [self requestDataWithIsFooter:NO];
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
        case NEWS_HaveVideo:
        {
            return 12 + 68 + 12;
        }
        case NEWS_OnlyVideo:
        {
            return videoHeight + 42;
        }
        case NEWS_HotVideo:
        {
            CGSize titleLabelSize = [model.title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:titleFont];
            return 12 + titleLabelSize.height + imageHeight + 20 + 11 + 11;
        }
        default:
            return 50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_dataList.count > 0) {
        NewsModel *model = nil;
        if (indexPath.row >= _dataList.count) {
            model = [[NewsModel alloc] init];
            model.tpl = @100;
        } else {
            model = _dataList[indexPath.row];
            if (model == nil) {
                model = [[NewsModel alloc] init];
                model.tpl = @100;
            }
        }
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
                cell.isHaveVideo = NO;
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
                static NSString *cellID = @"OnlyVideoCellID";
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
            case NEWS_HotVideo:
            {
                // 大图cell
                static NSString *cellID = @"BigPicCellID";
                BigPicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[BigPicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
                }
                cell.model = model;
                cell.isHaveVideo = YES;
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
    NewsModel *model = _dataList[indexPath.row];
    if (!model.news_id.length) {
        return;
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    // 服务器打点-列表页点击详情-020102
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    NSString *pagePos = [NSString stringWithFormat:@"%.1f",(cell.top - tableView.contentOffset.y + 1.5) / tableView.height];
//    NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
//    [eventDic setObject:@"020102" forKey:@"id"];
//    [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
//    [eventDic setObject:model.news_id forKey:@"news_id"];
//    [eventDic setObject:[NSNumber numberWithInteger:indexPath.row] forKey:@"list_pos"];
//    [eventDic setObject:_model.channelID forKey:@"refer"];
//    [eventDic setObject:pagePos forKey:@"page_pos"];
//    [eventDic setObject:model.issuedID forKey:@"dispatch_id"];
//    [eventDic setObject:[NetType getNetType] forKey:@"net"];
//    if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
//        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
//        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
//    } else {
//        [eventDic setObject:@"" forKey:@"lng"];
//        [eventDic setObject:@"" forKey:@"lat"];
//    }
//    NSString *abflag = DEF_PERSISTENT_GET_OBJECT(@"abflag");
//    if (abflag && abflag.length > 0) {
//        [eventDic setObject:abflag forKey:@"abflag"];
//    }
//    NSDictionary *sessionDic = [NSDictionary dictionaryWithObjectsAndKeys:
//                                DEF_PERSISTENT_GET_OBJECT(@"UUID"), @"id",
//                                [NSArray arrayWithObject:eventDic], @"events",
//                                nil];
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[NSArray arrayWithObject:sessionDic] forKey:@"sessions"];
//    [[SSHttpRequest sharedInstance] post:@"" params:params contentType:JsonType serverType:NetServer_Log success:^(id responseObj) {
//        // 打点成功
//    } failure:^(NSError *error) {
//        // 打点失败
//        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(@"UUID") forKey:@"session"];
//        [appDelegate.eventArray addObject:eventDic];
//    } isShowHUD:NO];
    
    if (model.tpl.integerValue == NEWS_OnlyVideo) {
        // 打点-点击视频列表-010131
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       @"Video", @"channel",
                                       [NetType getNetType], @"network",
                                       nil];
        [Flurry logEvent:@"Home_Videolist_Click" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Home_Videolist_Click:%@",articleParams],nil];
#endif
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_PausedVideo object:model.news_id];
        VideoDetailViewController *videoDetailVC = [[VideoDetailViewController alloc] init];
        videoDetailVC.model = model;
        videoDetailVC.channelName = @"Topics";
        OnlyVideoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        videoDetailVC.playerView = cell.playerView;
        videoDetailVC.indexPath = indexPath;
        videoDetailVC.fromCell = cell;
        cell.isMove = YES;
        [self.navigationController pushViewController:videoDetailVC animated:YES];
        return;
    }
//    // 打点-点击列表-010108
//    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
//                                   _model.name, @"channel",
//                                   nil];
//    [Flurry logEvent:@"Home_List_Click" withParameters:articleParams];
//#if DEBUG
//    [iConsole info:[NSString stringWithFormat:@"Home_List_Click:%@",articleParams],nil];
//#endif
    
    if (model.tpl.integerValue == NEWS_HotVideo) {
        VideoDetailViewController *videoDetailVC = [[VideoDetailViewController alloc] init];
        videoDetailVC.model = model;
        videoDetailVC.channelName = @"Topics";
        [self.navigationController pushViewController:videoDetailVC animated:YES];
        return;
    }
    [appDelegate.checkDic setObject:@1 forKey:model.news_id];
    NewsDetailViewController *newsDetailVC = [[NewsDetailViewController alloc] init];
    newsDetailVC.model = model;
    newsDetailVC.channelName = @"Topics";
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


#pragma mark - setter/getter
- (void)setShowBlankView:(BOOL)showBlankView
{
    if (_showBlankView != showBlankView) {
        _showBlankView = showBlankView;
        
        if (showBlankView) {
            _blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
            _blankView.backgroundColor = [UIColor whiteColor];
            _blankView.userInteractionEnabled = YES;
            [self.view addSubview:_blankView];
            _failureView = [[UIImageView alloc] initWithFrame:CGRectMake((_blankView.width - 28) * .5, 200 / kScreenHeight * 568 + 64, 28, 26)];
            _failureView.image = [UIImage imageNamed:@"icon_common_netoff"];
            [_blankView addSubview:_failureView];
            _blankLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 300) * .5, _failureView.bottom + 13, 300, 20)];
            _blankLabel.backgroundColor = [UIColor whiteColor];
            _blankLabel.textAlignment = NSTextAlignmentCenter;
            _blankLabel.textColor = SSColor(177, 177, 177);
            _blankLabel.font = [UIFont systemFontOfSize:16];
            [_blankView addSubview:_blankLabel];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(requestData)];
            [_blankView addGestureRecognizer:tap];
        } else {
            [_blankView removeAllSubviews];
            [_blankView removeFromSuperview];
            _blankView = nil;
        }
    }
}

- (void)setDataList:(NSMutableArray *)dataList
{
    _dataList = dataList;
    if (_dataList.count > 5) {
        __weak typeof(self) weakSelf = self;
        [self.tableView addLegendFooterWithRefreshingBlock:^{
            [weakSelf tableViewDidTriggerFooterRefresh];
            [weakSelf.tableView.footer beginRefreshing];
        }];
        [self.tableView.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
        [self.tableView.footer setTitle:@"Loading..." forState:MJRefreshFooterStateRefreshing];
        [self.tableView.footer setTitle:@"No more news" forState:MJRefreshFooterStateNoMoreData];
    } else {
        [self.tableView removeFooter];
    }
}

- (void)shareToFacebook:(UIButton *)button
{
    id cell = button.superview;
    do {
        if ([cell isKindOfClass:[UITableViewCell class]]) {
            break;
        }
        cell = ((UIView *)cell).superview;
    } while (cell != nil);
    NewsModel *newsModel = ((OnlyVideoCell *)cell).model;
    
    // 打点-分享至facebook-010219
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   newsModel.news_id, @"article",
                                   nil];
    [Flurry logEvent:@"Home_List_Share_FacebookClick" withParameters:articleParams];
#if DEBUG
    [iConsole info:[NSString stringWithFormat:@"Home_List_Share_FacebookClick:%@",articleParams],nil];
#endif
    
    __weak typeof(self) weakSelf = self;
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
