//
//  NotificationViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/11/15.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationModel.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "NotificationCell.h"
#import "NotifDetailViewController.h"
#import "NewsDetailViewController.h"
#import "VideoDetailViewController.h"
#import "PushTransitionAnimate.h"

@interface NotificationViewController ()

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"Notification";
    self.isBackButton = YES;
    self.view.backgroundColor = kWhiteBgColor;
    
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
    if (appDelegate.model) {
        // 请求数据
        [self requestDataIsFooter:NO];
    }

    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginSuccess:)
                                                 name:KNOTIFICATION_Login_Success
                                               object:nil];
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CleanNewNotif
                                                        object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (IOS_VERSION_CODE <= 8) {
        __weak typeof(self.navigationController.delegate) weakDelegate = self.navigationController.delegate;
        if (weakDelegate != self) {
            weakDelegate = self;
        }
    } else {
        if (self.navigationController.delegate != self) {
            self.navigationController.delegate = self;
        }
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (!appDelegate.model) {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.isNotification = YES;
        [self.navigationController pushViewController:loginVC animated:NO];
    }
    // 打点-页面进入-011401
    [Flurry logEvent:@"Notification_Enter"];
#if DEBUG
    [iConsole info:@"Notification_Enter",nil];
#endif
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
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 打点-点击返回-011403
    [Flurry logEvent:@"Notification_BackButton_Click"];
#if DEBUG
    [iConsole info:@"Notification_BackButton_Click",nil];
#endif
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationModel *model = _dataList[indexPath.row];
    CGSize commentLabelSize = [model.comment calculateSize:CGSizeMake(kScreenWidth - 55 - 11, 1000) font:[UIFont systemFontOfSize:15]];
    CommentModel *commentModel = model.reply;
    if (commentModel.comment) {
        NSString *replyString = [NSString stringWithFormat:@"@%@: %@",commentModel.user_name,commentModel.comment];
        CGSize replyLabelSize = [replyString calculateSize:CGSizeMake(kScreenWidth - 11 - 7 - 55, 1000) font:[UIFont systemFontOfSize:13]];
        return 10 + 5 + 16 + 12 + commentLabelSize.height + 9 + replyLabelSize.height + 10;
    }
    return 10 + 5 + 16 + 12 + commentLabelSize.height + 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"SinglePicCellID";
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.model = _dataList[indexPath.row];
    [cell setNeedsLayout];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 打点-点击评论通知消息-011402
    [Flurry logEvent:@"Notification_ReplyComment_Click"];
#if DEBUG
    [iConsole info:@"Notification_ReplyComment_Click",nil];
#endif
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NotificationModel *model = _dataList[indexPath.row];
    model.status = @1;
    if ([model.type isEqualToNumber:@3] && model.news_id) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:model.notify_id forKey:@"notification_id"];
        [[SSHttpRequest sharedInstance] get:kHomeUrl_NotifRead params:params contentType:JsonType serverType:NetServer_Home success:nil failure:nil isShowHUD:NO];
        NewsModel *newsModel = [[NewsModel alloc] init];
        newsModel.news_id = model.news_id;
        if (model.tpl.integerValue == NEWS_HotVideo || model.tpl.integerValue == NEWS_OnlyVideo) {
            VideoDetailViewController *videoDetailVC = [[VideoDetailViewController alloc] init];
            videoDetailVC.model = newsModel;
            videoDetailVC.channelName = @"Videos";
            videoDetailVC.isNoModel = YES;
            [self.navigationController pushViewController:videoDetailVC animated:YES];
            return;
        }
        NewsDetailViewController *newsDetailVC = [[NewsDetailViewController alloc] init];
        newsDetailVC.model = newsModel;
        newsDetailVC.channelName = @"Hot";
        [self.navigationController pushViewController:newsDetailVC animated:YES];
        return;
    }
    NotifDetailViewController *notifDetailVC = [[NotifDetailViewController alloc] init];
    notifDetailVC.notify_id = model.notify_id;
    [self.navigationController pushViewController:notifDetailVC animated:YES];
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
            UIImageView *failureView = [[UIImageView alloc] initWithFrame:CGRectMake((_blankView.width - 32) * .5, 164 / kScreenHeight * 568, 32, 34)];
            failureView.backgroundColor = kWhiteBgColor;
            failureView.image = [UIImage imageNamed:@"icon_nonotification"];
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
    NotificationModel *model = dataList.firstObject;
    DEF_PERSISTENT_SET_OBJECT(kLastNotifID, model.notify_id);

    __weak typeof(self) weakSelf = self;
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        [weakSelf tableViewDidTriggerFooterRefresh];
        [weakSelf.tableView.footer beginRefreshing];
    }];
    [self.tableView.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
    [self.tableView.footer setTitle:@"Loading..." forState:MJRefreshFooterStateRefreshing];
    [self.tableView.footer setTitle:@"No more notifications" forState:MJRefreshFooterStateNoMoreData];
}

#pragma mark - Notification
- (void)loginSuccess:(NSNotification *)notif
{
    if ([notif.object[@"isNotification"] isEqualToNumber:@1]) {
        [self requestDataIsFooter:NO];
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
