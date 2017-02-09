//
//  SearchViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/12/16.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "SearchViewController.h"
#import "ImageModel.h"
#import "ManyPicCell.h"
#import "SinglePicCell.h"
#import "NoPicCell.h"
#import "BigPicCell.h"
#import "OnlyVideoCell.h"
#import "AppDelegate.h"
#import "NewsDetailViewController.h"
#import "VideoDetailViewController.h"

#define titleFont_Normal        [UIFont systemFontOfSize:16]
#define titleFont_ExtraLarge    [UIFont systemFontOfSize:20]
#define titleFont_Large         [UIFont systemFontOfSize:18]
#define titleFont_Small         [UIFont systemFontOfSize:14]

#define imageHeight 162 * kScreenWidth / 320.0
#define videoHeight 180 * kScreenWidth / 320.0
#define topHeight   130 * kScreenWidth / 375.0

@interface SearchViewController ()

@end

@implementation SearchViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _dataList = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHidden)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    // 取消按钮
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    cancel.frame = CGRectMake(0, 0, 70, 40);
    cancel.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancelDidClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc]initWithCustomView:cancel];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, sendItem];
    // 搜索框
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 11 - 70, 44)];
    self.searchBar.placeholder = @"Search";
    self.searchBar.tintColor = kOrangeColor;
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    searchField.textColor = kBlackColor;
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
    [self.searchBar becomeFirstResponder];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64) style:UITableViewStylePlain];
    _tableView.backgroundColor = kWhiteBgColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.sectionHeaderHeight = 0;
    _tableView.sectionFooterHeight = 0;
    _tableView.separatorColor = SSColor(235, 235, 235);
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.hotwordsDic.count) {
        _hotArray = appDelegate.hotwordsDic[@"hotwords"];
        self.tableView.tableHeaderView = [self getHeaderViewWithHotWords:_hotArray];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Network
//- (void)requestHotwords
//{
//    __weak typeof(self) weakSelf = self;
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    [params setObject:@10 forKey:@"size"];
//    [[SSHttpRequest sharedInstance] get:kHomeUrl_NewsHotwords params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
//        _hotArray = responseObj[@"hotwords"];
//        weakSelf.tableView.tableHeaderView = [weakSelf getHeaderViewWithHotWords:_hotArray];
//    } failure:nil isShowHUD:NO];
//}
// 请求搜索数据
- (void)requestSearchDataWithIsFooter:(BOOL)isFooter
{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"" forKey:@"channel_id"];
    if (_keyword) {
        [params setObject:@"hotwords" forKey:@"source"];
        [params setObject:_keyword forKey:@"words"];
    } else {
        [params setObject:@"searchbox" forKey:@"source"];
        if (self.searchBar.text.length > 100) {
            NSString *searchStr = [self.searchBar.text substringToIndex:100];
            [params setObject:searchStr forKey:@"words"];
        } else {
            [params setObject:self.searchBar.text forKey:@"words"];
        }
    }
    [params setObject:@20 forKey:@"size"];
    if (isFooter) {
        _pageCount++;
    } else {
        _pageCount = 0;
    }
    [params setObject:[NSNumber numberWithInteger:20 * _pageCount] forKey:@"from"];
    [[SSHttpRequest sharedInstance] get:kHomeUrl_NewsSearch params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        [SVProgressHUD dismiss];
        if (weakSelf.tableView.tableHeaderView) {
            return;
        }
        NSMutableArray *models = [NSMutableArray array];
        @autoreleasepool {
            for (NSDictionary *dic in responseObj[@"news"]) {
                NewsModel *model = [NewsModel mj_objectWithKeyValues:dic];
                model.issuedID = responseObj[@"dispatch_id"];
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
        if (isFooter) {
            [weakSelf.tableView.footer endRefreshing];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    } isShowHUD:NO];
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self requestSearchDataWithIsFooter:YES];
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
    NSString *title = [model.title copy];
    title = [model.title stringByReplacingOccurrencesOfString:@"<font>" withString:@""];
    title = [model.title stringByReplacingOccurrencesOfString:@"</font>" withString:@""];
    switch ([model.tpl integerValue])
    {
        case NEWS_ManyPic:
        {
            CGSize titleLabelSize = [title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:titleFont];
            return 11 + titleLabelSize.height + 10 + 70 + 10 + 11 + 11;
        }
        case NEWS_SinglePic:
        {
            return 12 + 68 + 12;
        }
        case NEWS_NoPic:
        {
            CGSize titleLabelSize = [title calculateSize:CGSizeMake(kScreenWidth - 22, 60) font:titleFont];
            return 11 + titleLabelSize.height + 15 + 11 + 11;
        }
        case NEWS_BigPic:
        {
            CGSize titleLabelSize = [title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:titleFont];
            return 12 + titleLabelSize.height + imageHeight + 20 + 11 + 11;
        }
        case NEWS_OnlyPic:
        {
            CGSize titleLabelSize = [title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:titleFont];
            ImageModel *imageModel = model.imgs.firstObject;
            return 12 + titleLabelSize.height + 10 + imageModel.height.integerValue / 2.0 + 12 + 18 + 12;
        }
        case NEWS_GifPic:
        {
            CGSize titleLabelSize = [title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:titleFont];
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
        case NEWS_HotVideo:
        {
            CGSize titleLabelSize = [title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:titleFont];
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
                    cell.isSearch = YES;
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
                    cell.isSearch = YES;
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
                    cell.isSearch = YES;
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
                    cell.isSearch = YES;
                }
                cell.model = model;
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
                    cell.isSearch = YES;
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
                    cell.isSearch = YES;
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
                    cell.isSearch = YES;
                }
                cell.model = model;
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
    // 服务器打点-列表页点击详情-020102
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *pagePos = [NSString stringWithFormat:@"%.1f",(cell.top - tableView.contentOffset.y + 1.5) / tableView.height];
    NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
    [eventDic setObject:@"020102" forKey:@"id"];
    [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
    [eventDic setObject:model.news_id forKey:@"news_id"];
    [eventDic setObject:[NSNumber numberWithInteger:indexPath.row] forKey:@"list_pos"];
    [eventDic setObject:@"search" forKey:@"refer"];
    [eventDic setObject:pagePos forKey:@"page_pos"];
    if (model.issuedID) {
        [eventDic setObject:model.issuedID forKey:@"dispatch_id"];
    }
    [eventDic setObject:[NetType getNetType] forKey:@"net"];
    if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
    } else {
        [eventDic setObject:@"" forKey:@"lng"];
        [eventDic setObject:@"" forKey:@"lat"];
    }
    NSString *abflag = DEF_PERSISTENT_GET_OBJECT(@"abflag");
    if (abflag && abflag.length > 0) {
        [eventDic setObject:abflag forKey:@"abflag"];
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
    
    if (model.tpl.integerValue == NEWS_OnlyVideo) {
        // 打点-点击视频列表-010131
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       @"Video", @"channel",
                                       [NetType getNetType], @"network",
                                       nil];
        [Flurry logEvent:@"Home_Videolist_Click" withParameters:articleParams];
//#if DEBUG
//        [iConsole info:[NSString stringWithFormat:@"Home_Videolist_Click:%@",articleParams],nil];
//#endif
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_PausedVideo object:model.news_id];
        VideoDetailViewController *videoDetailVC = [[VideoDetailViewController alloc] init];
        videoDetailVC.model = model;
        videoDetailVC.channelName = @"Search";
        OnlyVideoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        videoDetailVC.playerView = cell.playerView;
        videoDetailVC.indexPath = indexPath;
        videoDetailVC.fromCell = cell;
        cell.isMove = YES;
        [self.navigationController pushViewController:videoDetailVC animated:YES];
        return;
    }
    if (model.tpl.integerValue == NEWS_HotVideo) {
        VideoDetailViewController *videoDetailVC = [[VideoDetailViewController alloc] init];
        videoDetailVC.model = model;
        videoDetailVC.channelName = @"Search";
        [self.navigationController pushViewController:videoDetailVC animated:YES];
        return;
    }
    NewsDetailViewController *newsDetailVC = [[NewsDetailViewController alloc] init];
    newsDetailVC.model = model;
    newsDetailVC.channelName = @"Search";
    [self.navigationController pushViewController:newsDetailVC animated:YES];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // 显示热词
    if (_hotArray) {
        self.tableView.tableHeaderView = [self getHeaderViewWithHotWords:_hotArray];
    }
    self.showBlankView = NO;
    [self.dataList removeAllObjects];
    [self.tableView removeFooter];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    [SVProgressHUD show];
    _keyword = nil;
    self.tableView.tableHeaderView = nil;
    [self requestSearchDataWithIsFooter:NO];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 100) {
        searchBar.text = [searchBar.text substringToIndex:100];
    }
}

#pragma mark - setter/getter
- (void)setDataList:(NSMutableArray *)dataList
{
    if (_dataList != dataList) {
        _dataList = dataList;
        if (_dataList.count > 0) {
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
}

- (void)setShowBlankView:(BOOL)showBlankView
{
    if (_showBlankView != showBlankView) {
        _showBlankView = showBlankView;
        
        if (showBlankView) {
            _blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 64)];
            _blankView.backgroundColor = kWhiteBgColor;
            [self.tableView addSubview:_blankView];
            UIImageView *failureView = [[UIImageView alloc] initWithFrame:CGRectMake((_blankView.width - 36) * .5, (_blankView.height - 40 - 13 - 18) * .5 - 80, 36, 40)];
            failureView.backgroundColor = kWhiteBgColor;
            failureView.contentMode = UIViewContentModeScaleAspectFit;
            failureView.image = [UIImage imageNamed:@"icon_noResult"];
            [_blankView addSubview:failureView];
            UILabel *blankLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 300) * .5, failureView.bottom + 13, 300, 18)];
            blankLabel.backgroundColor = kWhiteBgColor;
            blankLabel.textAlignment = NSTextAlignmentCenter;
            blankLabel.textColor = SSColor_RGB(177);
            blankLabel.font = [UIFont systemFontOfSize:16];
            blankLabel.text = @"Oops, no result has been found";
            [_blankView addSubview:blankLabel];
        } else {
            [_blankView removeAllSubviews];
            [_blankView removeFromSuperview];
            _blankView = nil;
        }
    }
}

- (UIView *)getHeaderViewWithHotWords:(NSArray *)hotWords
{
    if (_headerView) {
        return _headerView;
    }
    
    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = kWhiteBgColor;
    UIImageView *keywordView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 15, 15, 12)];
    keywordView.contentMode = UIViewContentModeScaleAspectFit;
    keywordView.image = [UIImage imageNamed:@"icon_keyword"];
    [_headerView addSubview:keywordView];
    UILabel *keywordLabel = [[UILabel alloc] initWithFrame:CGRectMake(keywordView.right + 10, 12, 200, 19)];
    keywordLabel.backgroundColor = kWhiteBgColor;
    keywordLabel.textColor = kBlackColor;
    keywordLabel.font = [UIFont systemFontOfSize:17];
    keywordLabel.text = @"Hot keywords";
    [_headerView addSubview:keywordLabel];
    
    CGFloat keyword_Y = keywordLabel.bottom + 14;
    CGFloat keyword_X = 11;
    for (int i = 0; i < hotWords.count; i++) {
        NSString *keyword = hotWords[i];
        CGSize keywordSize = [keyword calculateSize:CGSizeMake(kScreenWidth - 22 - 20, 16) font:[UIFont systemFontOfSize:15]];
        UIButton *keywordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (kScreenWidth - 11 - keyword_X - 13 < keywordSize.width + 18) {
            // 放在下一行
            keyword_X = 11;
            keyword_Y += (15 + 16 + 12);
        }
        keywordButton.frame = CGRectMake(keyword_X, keyword_Y, keywordSize.width + 18, 15 + 16);
        keywordButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [keywordButton setTitle:keyword forState:UIControlStateNormal];
        [keywordButton setTitleColor:kBlackColor forState:UIControlStateNormal];
        [keywordButton setTitleColor:kOrangeColor forState:UIControlStateHighlighted];
        keywordButton.layer.borderWidth = 1;
        keywordButton.layer.borderColor = kGrayColor.CGColor;
        keywordButton.layer.cornerRadius = 4;
        [keywordButton addTarget:self action:@selector(clickKeyword:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:keywordButton];
        if (kScreenWidth - 11 - keyword_X - 13 >= keywordSize.width + 18) {
            // 放在本行
            keyword_X += (keywordSize.width + 18 + 13);
        }
        if (i == hotWords.count - 1) {
            _headerView.frame = CGRectMake(0, 0, kScreenWidth, keywordButton.bottom + 12);
        }
    }
    return _headerView;
}

#pragma mark - 按钮点击事件
// 取消按钮点击
- (void)cancelDidClick {
    [SVProgressHUD dismiss];
    [self.searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

// 热词点击事件
- (void)clickKeyword:(UIButton *)button
{
    [self.searchBar resignFirstResponder];
    _keyword = button.titleLabel.text;
    self.searchBar.text = _keyword;
    [SVProgressHUD show];
    [self requestSearchDataWithIsFooter:NO];
    self.tableView.tableHeaderView = nil;
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
    NewsModel *newsModel = ((OnlyVideoCell *)cell).model;
    
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

#pragma mark - Notification
/**
 *  键盘弹出后执行的操作
 *
 *  @param notif 键盘通知
 */
- (void)keyboardWillShow:(NSNotification *)notif
{
    float keyboardHeight = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.height = kScreenHeight - 64 - keyboardHeight;
    }];
}
- (void)keyboardWillHidden
{
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.height = kScreenHeight - 64;
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
