//
//  NotificationViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/11/15.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationModel.h"

@interface NotificationViewController ()

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Notification";
    self.isBackButton = YES;
    self.view.backgroundColor = kWhiteBgColor;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = kWhiteBgColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.sectionHeaderHeight = 0;
    _tableView.sectionFooterHeight = 0;
    _tableView.separatorColor = SSColor(235, 235, 235);
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    
    [self requestDataIsFooter:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 打点-页面进入-011401
    [Flurry logEvent:@"Notification_Enter"];
#if DEBUG
    [iConsole info:@"Notification_Enter",nil];
#endif
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Network
- (void)requestDataIsFooter:(BOOL)isFooter
{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@10 forKey:@"length"];
    if (isFooter) {
        NotificationModel *model = _dataList.lastObject;
        [params setObject:model.notify_id forKey:@"last_id"];
    } else {
        [SVProgressHUD show];
    }
    [[SSHttpRequest sharedInstance] get:kHomeUrl_Notification params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        [SVProgressHUD dismiss];
        NSMutableArray *models = [NSMutableArray array];
        @autoreleasepool {
            for (NSDictionary *dic in responseObj) {
                NotificationModel *model = [NotificationModel mj_objectWithKeyValues:dic];
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
        [SVProgressHUD dismiss];
    } isShowHUD:NO];
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self requestDataIsFooter:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"SinglePicCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
//    cell.model = model;
    [cell setNeedsLayout];
    return cell;
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
            blankLabel.text = @"No notifications yet";
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

    __weak typeof(self) weakSelf = self;
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        [weakSelf tableViewDidTriggerFooterRefresh];
        [weakSelf.tableView.footer beginRefreshing];
    }];
    [self.tableView.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
    [self.tableView.footer setTitle:@"Loading..." forState:MJRefreshFooterStateRefreshing];
    [self.tableView.footer setTitle:@"No more notifications" forState:MJRefreshFooterStateNoMoreData];
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
