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
#import "FavoriteDetailViewController.h"
#import "AppDelegate.h"

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
    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue] >= 7) {
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
    
    // 请求数据
    [self requestDataWithIsFooter:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 打点-页面进入-010501
    [Flurry logEvent:@"Favor_Enter"];
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
        NSMutableArray *models = [NSMutableArray array];
        for (NSDictionary *dic in responseObj) {
            NewsModel *model = [NewsModel mj_objectWithKeyValues:dic];
            [models addObject:model];
        }
        if (isFooter) {
            if (((NSArray *)responseObj).count <= 0) {
                weakSelf.tableView.footer.state = MJRefreshFooterStateNoMoreData;
                return;
            }
            [_dataList addObjectsFromArray:models];
        } else {
            _dataList = [NSMutableArray arrayWithArray:models];
            if (_dataList.count > 9) {
                [weakSelf.tableView addLegendFooterWithRefreshingBlock:^{
                    [weakSelf tableViewDidTriggerFooterRefresh];
                    [weakSelf.tableView.footer beginRefreshing];
                }];
                [weakSelf.tableView.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
                [weakSelf.tableView.footer setTitle:@"Loading..." forState:MJRefreshFooterStateRefreshing];
                [weakSelf.tableView.footer setTitle:@"No more date" forState:MJRefreshFooterStateNoMoreData];
            } else {
                [weakSelf.tableView removeFooter];
            }
        }
        if (_dataList.count == 0) {
            self.showBlankView = YES;
        } else {
            self.showBlankView = NO;
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
    
    __weak typeof(self) weakSelf = self;
    NSMutableArray *collectIDs = [NSMutableArray array];
    for (NewsModel *model in _selectedList) {
        [collectIDs addObject:model.collect_id];
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:collectIDs forKey:@"ids"];
    [[SSHttpRequest sharedInstance] DELETE:kHomeUrl_Collect params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        // 打点-删除成功-010505
        [Flurry logEvent:@"Favor_DelButton_Click_Y"];
        
        [_dataList removeObjectsInArray:_selectedList];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *htmlFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.data",appDelegate.model.user_id]];
        NSMutableDictionary *dataDic = [NSKeyedUnarchiver unarchiveObjectWithFile:htmlFilePath];
        if ([dataDic isKindOfClass:[NSMutableDictionary class]] && dataDic.count > 0) {
            [dataDic removeObjectsForKeys:collectIDs];
            [NSKeyedArchiver archiveRootObject:dataDic toFile:htmlFilePath];
        }
        if (_dataList.count == 0) {
            weakSelf.showBlankView = YES;
        }
        [_tableView reloadData];
    } failure:^(NSError *error) {
        // 打点-删除失败-010506
        [Flurry logEvent:@"Favor_DelButton_Click_N"];
    } isShowHUD:NO];
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
    
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@[model.collect_id] forKey:@"ids"];
    [[SSHttpRequest sharedInstance] DELETE:kHomeUrl_Collect params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        // 打点-删除成功-010505
        [Flurry logEvent:@"Favor_DelButton_Click_Y"];
        
        [_dataList removeObjectsInArray:_selectedList];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.data",appDelegate.model.user_id]];
        NSMutableDictionary *dataDic = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if ([dataDic isKindOfClass:[NSMutableDictionary class]] && dataDic.count > 0) {
            [dataDic removeObjectForKey:model.collect_id];
            [NSKeyedArchiver archiveRootObject:dataDic toFile:filePath];
        }
        if (_dataList.count == 0) {
            weakSelf.showBlankView = YES;
        }
    } failure:^(NSError *error) {
        // 打点-删除失败-010506
        [Flurry logEvent:@"Favor_DelButton_Click_N"];
//        [weakSelf deleteCollectNewsWithModel:model];
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
    switch ([model.tpl integerValue])
    {
        case NEWS_ManyPic:
        {
            return 12 + 68 + 12;
        }
            break;
        case NEWS_SinglePic:
        {
            return 12 + 68 + 12;
        }
            break;
        case NEWS_NoPic:
        {
            CGSize titleLabelSize = [model.title calculateSize:CGSizeMake(kScreenWidth - 20, 60) font:[UIFont systemFontOfSize:16]];
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
    if (!_tableView.editing) {
        // 打点-点击列表文章-010502
        [Flurry logEvent:@"Favor_List_Click"];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NewsModel *model = _dataList[indexPath.row];
        FavoriteDetailViewController *favDetVC = [[FavoriteDetailViewController alloc] init];
        favDetVC.model = model;
        [self.navigationController pushViewController:favDetVC animated:YES];
    } else {
        [_selectedList addObject:_dataList[indexPath.row]];
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
            _blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
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

#pragma mark - 表视图左划删除方法
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (_dataList.count > 0) {
            NewsModel *model = _dataList[indexPath.row];
            [self deleteCollectNewsWithModel:model];
            [_dataList removeObjectAtIndex:indexPath.row];
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
    
    if (self.tableView.editing) {
        self.isEdit = NO;
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
        
        // 打点-点击编辑-010503
        [Flurry logEvent:@"Favor_EditButton_Click"];
    }
    button.selected = !button.selected;
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
