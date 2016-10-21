//
//  FavoritesViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/7/25.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "FavoritesViewController.h"
#import "NewsModel.h"
#import "ManyPicCell.h"
#import "SinglePicCell.h"
#import "NoPicCell.h"
#import "BigPicCell.h"
#import "FavoriteDetailViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "BaseNavigationController.h"
#import "LocalFavorite+CoreDataClass.h"

#define titleFont_Normal        [UIFont systemFontOfSize:16]
#define titleFont_ExtraLarge    [UIFont systemFontOfSize:20]
#define titleFont_Large         [UIFont systemFontOfSize:18]
#define titleFont_Small         [UIFont systemFontOfSize:14]

@interface FavoritesViewController ()

@end

@implementation FavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Favorites";
    self.isBackButton = YES;
    self.view.backgroundColor = kWhiteBgColor;

    // 添加导航栏右侧按钮
    _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _editBtn.frame = CGRectMake(0, 0, 80, 40);
    _editBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [_editBtn setTitle:@"Edit" forState:UIControlStateNormal];
    [_editBtn setTitle:@"Cancel" forState:UIControlStateSelected];
    [_editBtn addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc]initWithCustomView:_editBtn];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -20;
        self.navigationItem.rightBarButtonItems = @[negativeSpacer, editItem];
    } else {
        self.navigationItem.rightBarButtonItem = editItem;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = kWhiteBgColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.sectionHeaderHeight = 0;
    _tableView.sectionFooterHeight = 0;
    _tableView.separatorColor = SSColor(235, 235, 235);
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *data = [[CoreDataManager sharedInstance] getLocalFavoriteModelList];

    if (appDelegate.model) {
        if (data.count <= 0) {
            // 请求数据
            [self requestDataWithIsFooter:NO];
        }
    } else {
        if ([data isKindOfClass:[NSArray class]] && data.count > 0) {
            // 读取本地未登录收藏
            NSMutableArray *modelList = [NSMutableArray array];
            NSMutableArray *detailModelList = [NSMutableArray array];
            for (LocalFavorite *localFavorite in data) {
                NewsModel *model = (NewsModel *)localFavorite.news_model;
                NewsDetailModel *detailModel = (NewsDetailModel *)localFavorite.detail_model;
                [modelList addObject:model];
                [detailModelList addObject:detailModel];
            }
            self.dataList = modelList;
            self.detailList = detailModelList;
        } else {
            self.showBlankView = YES;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 打点-页面进入-010501
    [Flurry logEvent:@"Favor_Enter"];
#if DEBUG
    [iConsole info:@"Favor_Enter",nil];
#endif
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.model) {
        _tableView.tableHeaderView = nil;
        NSArray *dataList = [[CoreDataManager sharedInstance] getLocalFavoriteModelList];
        
        if ([dataList isKindOfClass:[NSArray class]] && dataList.count > 0) {
            // 同步本地收藏
            [SVProgressHUD show];
            [self uploadFavoritesWithDataList:[dataList mutableCopy]];
        }
    } else if (_tableView.tableHeaderView == nil) {
        UILabel *loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 43)];
        loginLabel.backgroundColor = SSColor(239, 239, 239);
        loginLabel.numberOfLines = 0;
        loginLabel.textAlignment = NSTextAlignmentCenter;
        loginLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(login)];
        [loginLabel addGestureRecognizer:tap];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:@"Log in, your favorited news will always be saved in your account."];
        [attributedStr addAttributes:@{NSFontAttributeName : [UIFont italicSystemFontOfSize:15],
                                       NSForegroundColorAttributeName : kGrayColor,
                                       NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle]
                                       } range:NSMakeRange(0, 6)];
        [attributedStr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13],
                                       NSForegroundColorAttributeName : kGrayColor,
                                       NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleNone],
                                       } range:NSMakeRange(6, attributedStr.length - 6)];
        loginLabel.attributedText = attributedStr;
        _tableView.tableHeaderView = loginLabel;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Network
// 请求数据
- (void)requestDataWithIsFooter:(BOOL)isFooter
{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@10 forKey:@"pn"];
    if (isFooter) {
        NewsModel *model = _dataList.lastObject;
        [params setObject:model.collect_id forKey:@"last_id"];
    }
    [[SSHttpRequest sharedInstance] get:kHomeUrl_Collect params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        [SVProgressHUD dismiss];
        NSMutableArray *models = [NSMutableArray array];
        @autoreleasepool {
            for (NSDictionary *dic in responseObj) {
                NewsModel *model = [NewsModel mj_objectWithKeyValues:dic];
                [models addObject:model];
            }
        }
        if (isFooter) {
            if (((NSArray *)responseObj).count <= 0) {
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
        
    } isShowHUD:NO];
}

/**
 *  多选删除收藏网络请求
 *
 *  @param button 收藏按钮
 */
- (void)deleteCollectNews
{
    // 打点-点击删除-010504
    [Flurry logEvent:@"Favor_DelButton_Click"];
#if DEBUG
    [iConsole info:@"Favor_DelButton_Click",nil];
#endif
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.model) {
        __weak typeof(self) weakSelf = self;
        NSMutableArray *collectIDs = [NSMutableArray array];
        @autoreleasepool {
            for (NewsModel *model in _selectedList) {
                [collectIDs addObject:model.collect_id];
            }
        }
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:collectIDs forKey:@"ids"];
        [[SSHttpRequest sharedInstance] DELETE:kHomeUrl_Collect params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
            // 打点-删除成功-010505
            [Flurry logEvent:@"Favor_DelButton_Click_Y"];
#if DEBUG
            [iConsole info:@"Favor_DelButton_Click_Y",nil];
#endif
            [weakSelf.dataList removeObjectsInArray:_selectedList];
            [[CoreDataManager sharedInstance] removeAccountFavoriteModelWithCollectIDs:collectIDs];
            if (_dataList.count == 0) {
                weakSelf.showBlankView = YES;
            }
            [_tableView reloadData];
        } failure:^(NSError *error) {
            // 打点-删除失败-010506
            [Flurry logEvent:@"Favor_DelButton_Click_N"];
#if DEBUG
            [iConsole info:@"Favor_DelButton_Click_N",nil];
#endif
        } isShowHUD:NO];
    } else {
        [self.dataList removeObjectsInArray:_selectedList];
        [_detailList removeObjectsInArray:_selectedDetail];

        if (_needRemoveNews.count > 0) {
            [[CoreDataManager sharedInstance] removeLocalFavoriteModelWithNewsIDs:_needRemoveNews];
        }
        if (_dataList.count == 0) {
            self.showBlankView = YES;
        }
        [_tableView reloadData];
        // 打点-删除成功-010505
        [Flurry logEvent:@"Favor_DelButton_Click_Y"];
#if DEBUG
        [iConsole info:@"Favor_DelButton_Click_Y",nil];
#endif
    }
}

/**
 *  左滑删除收藏网络请求
 *
 *  @param model NewsModel
 */
- (void)deleteCollectNewsWithModel:(NewsModel *)model
{
    // 打点-点击删除-010504
    [Flurry logEvent:@"Favor_DelButton_Click"];
#if DEBUG
    [iConsole info:@"Favor_DelButton_Click",nil];
#endif
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.model) {
        __weak typeof(self) weakSelf = self;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:@[model.collect_id] forKey:@"ids"];
        [[SSHttpRequest sharedInstance] DELETE:kHomeUrl_Collect params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
            // 打点-删除成功-010505
            [Flurry logEvent:@"Favor_DelButton_Click_Y"];
#if DEBUG
            [iConsole info:@"Favor_DelButton_Click_Y",nil];
#endif
            [[CoreDataManager sharedInstance] removeAccountFavoriteModelWithCollectIDs:[NSArray arrayWithObject:model.collect_id]];
            if (_dataList.count == 0) {
                weakSelf.showBlankView = YES;
            }
        } failure:^(NSError *error) {
            // 打点-删除失败-010506
            [Flurry logEvent:@"Favor_DelButton_Click_N"];
#if DEBUG
            [iConsole info:@"Favor_DelButton_Click_N",nil];
#endif
        } isShowHUD:NO];
    } else {
        [[CoreDataManager sharedInstance] removeLocalFavoriteModelWithNewsIDs:[NSArray arrayWithObject:model.news_id]];
        if (_dataList.count == 0) {
            self.showBlankView = YES;
        }
        // 打点-删除成功-010505
        [Flurry logEvent:@"Favor_DelButton_Click_Y"];
#if DEBUG
        [iConsole info:@"Favor_DelButton_Click_Y",nil];
#endif
    }
}

- (void)uploadFavoritesWithDataList:(NSMutableArray *)dataList
{
    NSArray *favoritesArray = [NSArray array];
    if (dataList.count >= 10) {
        favoritesArray = [dataList subarrayWithRange:NSMakeRange(0, 10)];
    } else {
        favoritesArray = [NSArray arrayWithArray:dataList];
    }
    NSMutableArray *paramsArray = [NSMutableArray array];
    for (LocalFavorite *localFavorite in favoritesArray) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NewsModel *model = (NewsModel *)localFavorite.news_model;
        [params setObject:model.news_id forKey:@"news_id"];
        [params setObject:localFavorite.collect_time forKey:@"ctime"];
        [paramsArray addObject:params];
    }
    __weak typeof(self) weakSelf = self;
    [[SSHttpRequest sharedInstance] post:kHomeUrl_Collect params:paramsArray contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        if (dataList.count >= 10) {
            NSMutableArray *newsIDs = [NSMutableArray array];
            for (LocalFavorite *localFavorite in dataList) {
                NewsModel *model = (NewsModel *)localFavorite.news_model;
                [newsIDs addObject:model.news_id];
            }
            [[CoreDataManager sharedInstance] removeLocalFavoriteModelWithNewsIDs:newsIDs];
            [weakSelf uploadFavoritesWithDataList:dataList];
        } else {
            NSMutableArray *newsIDs = [NSMutableArray array];
            for (LocalFavorite *localFavorite in dataList) {
                NewsModel *model = (NewsModel *)localFavorite.news_model;
                [newsIDs addObject:model.news_id];
            }
            [[CoreDataManager sharedInstance] removeLocalFavoriteModelWithNewsIDs:newsIDs];
            [weakSelf requestDataWithIsFooter:NO];
        }
    } failure:^(NSError *error) {
        [weakSelf requestDataWithIsFooter:NO];
    } isShowHUD:NO];
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
            return 12 + 68 + 12;
            break;
        }
        case NEWS_SinglePic:
        {
            return 12 + 68 + 12;
            break;
        }
        case NEWS_NoPic:
        {
            CGSize titleLabelSize = [model.title calculateSize:CGSizeMake(kScreenWidth - 22, 60) font:titleFont];
            return 11 + titleLabelSize.height + 15 + 11 + 11;
            break;
        }
        case NEWS_BigPic:
        {
            return 12 + 68 + 12;
            break;
        }
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
            // 单图cell
            static NSString *cellID = @"SinglePicCellID";
            SinglePicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[SinglePicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
            }
            cell.model = model;
            [cell setNeedsLayout];
            return cell;
            break;
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
            [cell setNeedsLayout];
            return cell;
            break;
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
            break;
        }
        case NEWS_BigPic:
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
            break;
        }
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
    NewsModel *model = _dataList[indexPath.row];
    if (!_tableView.editing) {
        // 打点-点击列表文章-010502
        [Flurry logEvent:@"Favor_List_Click"];
#if DEBUG
        [iConsole info:@"Favor_List_Click",nil];
#endif
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        FavoriteDetailViewController *favDetVC = [[FavoriteDetailViewController alloc] init];
        favDetVC.model = model;
        favDetVC.detailModel = _detailList[indexPath.row];
        [self.navigationController pushViewController:favDetVC animated:YES];
    } else {
        [_selectedList addObject:_dataList[indexPath.row]];
        if (_detailList) {
            [_selectedDetail addObject:_detailList[indexPath.row]];
            [_needRemoveNews addObject:model.news_id];
        }
    }
    if (_selectedList.count > 0) {
        [_editBtn setTitle:@"Delete" forState:UIControlStateSelected];
    } else {
        [_editBtn setTitle:@"Cancel" forState:UIControlStateSelected];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_selectedList removeObject:_dataList[indexPath.row]];
    if (_detailList) {
        [_selectedDetail removeObject:_detailList[indexPath.row]];
        NewsModel *model = _dataList[indexPath.row];
        [_needRemoveNews removeObject:model.news_id];
    }
    if (_selectedList.count > 0) {
        [_editBtn setTitle:@"Delete" forState:UIControlStateSelected];
    } else {
        [_editBtn setTitle:@"Cancel" forState:UIControlStateSelected];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isEdit) {
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    } else {
        _indexPath = indexPath;
        [_editBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isEdit) {
        [_editBtn setTitle:@"Edit" forState:UIControlStateNormal];
    }
}

#pragma mark - setter/getter
- (void)setShowBlankView:(BOOL)showBlankView
{
    if (_showBlankView != showBlankView) {
        _showBlankView = showBlankView;
        
        if (showBlankView) {
            _blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height)];
            _blankView.backgroundColor = kWhiteBgColor;
            _blankView.userInteractionEnabled = YES;
            [self.tableView addSubview:_blankView];
            UIImageView *failureView = [[UIImageView alloc] initWithFrame:CGRectMake((_blankView.width - 28) * .5, 164 / kScreenHeight * 568, 28, 26)];
            failureView.backgroundColor = kWhiteBgColor;
            failureView.image = [UIImage imageNamed:@"icon_nofavorites"];
            [_blankView addSubview:failureView];
            UILabel *blankLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 300) * .5, failureView.bottom + 13, 300, 20)];
            blankLabel.backgroundColor = kWhiteBgColor;
            blankLabel.textAlignment = NSTextAlignmentCenter;
            blankLabel.textColor = SSColor(177, 177, 177);
            blankLabel.font = [UIFont systemFontOfSize:16];
            blankLabel.text = @"No favorites yet";
            [_blankView addSubview:blankLabel];
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
        [self.tableView.footer setTitle:@"No more favorites" forState:MJRefreshFooterStateNoMoreData];
    } else {
        [self.tableView removeFooter];
    }
}

#pragma mark - 表视图左划删除方法
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (_dataList.count > 0) {
            NewsModel *model = _dataList[indexPath.row];
            [_dataList removeObjectAtIndex:indexPath.row];
            if (_detailList) {
                [_detailList removeObjectAtIndex:indexPath.row];
            }
            [self deleteCollectNewsWithModel:model];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - 按钮点击事件
- (void)backAction:(UIButton *)button
{
    // 打点-点击收藏页返回按钮-010507
    [Flurry logEvent:@"Favor_BackButton_Click"];
#if DEBUG
    [iConsole info:@"Favor_BackButton_Click",nil];
#endif
    if (self.tableView.editing) {
        self.isEdit = NO;
        _editBtn.selected = NO;
        [self.tableView setEditing:NO animated:YES];
        return;
    }
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)editAction:(UIButton *)button
{
    if (button.selected) {
        if (_selectedList.count > 0) {
            // 多选删除收藏
            [self deleteCollectNews];
        }
        // 取消多选
        self.isEdit = NO;
        [self.tableView setEditing:NO animated:YES];
        [_editBtn setTitle:@"Edit" forState:UIControlStateNormal];
        [_editBtn setTitle:@"Cancel" forState:UIControlStateSelected];
    } else {
        if ([_editBtn.titleLabel.text isEqualToString:@"Cancel"]) {
            // 取消左滑
            [_editBtn setTitle:@"Edit" forState:UIControlStateNormal];
            [self.tableView setEditing:NO animated:YES];
            return;
        }
        // 进入多选
        self.isEdit = YES;
        [self.tableView setEditing:YES animated:YES];
        _selectedList = [NSMutableArray array];
        _selectedDetail = [NSMutableArray array];
        _needRemoveNews = [NSMutableArray array];
        
        // 打点-点击编辑-010503
        [Flurry logEvent:@"Favor_EditButton_Click"];
#if DEBUG
        [iConsole info:@"Favor_EditButton_Click",nil];
#endif
    }
    button.selected = !button.selected;
}

// 登录
- (void)login
{
    // 打点-点击登录-010508
    [Flurry logEvent:@"Menu_LoginButton_Click"];
#if DEBUG
    [iConsole info:@"Menu_LoginButton_Click",nil];
#endif
    BaseNavigationController *navCtrl = (BaseNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [navCtrl pushViewController:loginVC animated:YES];
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self requestDataWithIsFooter:YES];
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
