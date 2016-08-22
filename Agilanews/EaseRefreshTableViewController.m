//
//  EaseRefreshTableViewController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/24.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EaseRefreshTableViewController.h"

#import "MJRefresh.h"

@interface EaseRefreshTableViewController ()

@property (nonatomic, readonly) UITableViewStyle style;

@end

@implementation EaseRefreshTableViewController

@synthesize rightItems = _rightItems;

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        _style = style;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:self.style];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    _tableView.delaysContentTouches = NO;
//    _tableView.canCancelContentTouches = NO;
    _tableView.tableFooterView = self.defaultFooterView;
    [self.view addSubview:_tableView];
    
    _page = 0;
    _showOldRefreshHeader = NO;
    _showRefreshHeader = NO;
    _showRefreshFooter = NO;
    _showTableBlankView = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setter

- (void)setShowOldRefreshHeader:(BOOL)showOldRefreshHeader
{
    if (_showOldRefreshHeader != showOldRefreshHeader) {
        _showOldRefreshHeader = showOldRefreshHeader;
        
        if (_showOldRefreshHeader) {
            __weak EaseRefreshTableViewController *weakSelf = self;
            MJRefreshLegendHeader *header = [self.tableView addLegendHeaderWithRefreshingBlock:^{
                [weakSelf tableViewDidTriggerHeaderRefresh];
                [weakSelf.tableView.header beginRefreshing];
            }];
            header.updatedTimeHidden = YES;
        }
        else{
            [self.tableView removeHeader];
        }
    }
}

- (void)setShowRefreshHeader:(BOOL)showRefreshHeader
{
    if (_showRefreshHeader != showRefreshHeader) {
        _showRefreshHeader = showRefreshHeader;
        if (_showRefreshHeader) {
            __weak EaseRefreshTableViewController *weakSelf = self;
        
            MJRefreshGifHeader *header = [self.tableView  addGifHeaderWithRefreshingBlock:^{
                [weakSelf tableViewDidTriggerHeaderRefresh];
                [weakSelf.tableView.header beginRefreshing];
            }];
            
            [weakSelf.tableView.header setTitle:@"Recommending..." forState:MJRefreshHeaderStateIdle];
            [weakSelf.tableView.header setTitle:@"Recommending..." forState:MJRefreshHeaderStatePulling];
            [weakSelf.tableView.header setTitle:@"Recommending..." forState:MJRefreshHeaderStateRefreshing];
//            // 设置普通状态的动画图片
//            NSMutableArray *idleImages = [NSMutableArray array];
//            for (NSUInteger i = 1; i<=14; i++) {
//                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_anim_%zd", i]];
//                [idleImages addObject:image];
//            }
//            [header setImages:idleImages forState:MJRefreshHeaderStateIdle];
//            
//            // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
//            NSMutableArray *refreshingImages = [NSMutableArray array];
//            for (NSUInteger i = 1; i<=3; i++) {
//                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_%zd", i]];
//                [refreshingImages addObject:image];
//            }
//            [header setImages:refreshingImages forState:MJRefreshHeaderStatePulling];
//            
//            // 设置正在刷新状态的动画图片
//            [header setImages:refreshingImages forState:MJRefreshHeaderStateRefreshing];
//            
            header.updatedTimeHidden = YES;
//            header.stateHidden = YES;
        }
        else{
            [self.tableView removeHeader];
        }
    }
}

- (void)setShowRefreshFooter:(BOOL)showRefreshFooter
{
    if (_showRefreshFooter != showRefreshFooter) {
        _showRefreshFooter = showRefreshFooter;
        
        if (_showRefreshFooter) {
            __weak EaseRefreshTableViewController *weakSelf = self;
            [self.tableView addLegendFooterWithRefreshingBlock:^{
                [weakSelf tableViewDidTriggerFooterRefresh];
                [weakSelf.tableView.footer beginRefreshing];
            }];
            [weakSelf.tableView.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
            [weakSelf.tableView.footer setTitle:@"Loading..." forState:MJRefreshFooterStateRefreshing];
            [weakSelf.tableView.footer setTitle:@"No more data" forState:MJRefreshFooterStateNoMoreData];
        } else {
            [self.tableView removeFooter];
        }
    }
}

- (void) setCustomBottomFotter:(BOOL)customBottomFotter {

    if (_customBottomFotter != customBottomFotter) {
        _customBottomFotter = customBottomFotter;
        if (_customBottomFotter) {
            
            __weak EaseRefreshTableViewController *weakSelf = self;
            
            MJRefreshGifFooter *footer = [self.tableView  addGifFooterWithRefreshingBlock:^{
                [weakSelf tableViewDidTriggerFooterRefresh];
                [weakSelf.tableView.footer beginRefreshing];
            }];
            
            // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
            NSMutableArray *refreshingImages = [NSMutableArray array];
            for (NSUInteger i = 1; i<=3; i++)
            {
                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_%zd", i]];
                [refreshingImages addObject:image];
            }
            
            [footer setTitle:@"" forState:MJRefreshFooterStateIdle];
            
            [footer setState:MJRefreshFooterStateIdle];
            [footer setStateHidden:YES];
            [footer setRefreshingImages:refreshingImages];
            
        }else {
            [self.tableView removeFooter];
        }
    }
}

- (void)setShowTableBlankView:(BOOL)showTableBlankView
{
    if (_showTableBlankView != showTableBlankView) {
        _showTableBlankView = showTableBlankView;
        if (showTableBlankView) {
            _blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
            _blankView.backgroundColor = [UIColor whiteColor];
            _blankView.userInteractionEnabled = YES;
            [self.view addSubview:_blankView];
            _failureView = [[UIImageView alloc] initWithFrame:CGRectMake((_blankView.width - 28) * .5, 164 / kScreenHeight * 568, 28, 26)];
            _failureView.image = [UIImage imageNamed:@"icon_common_netoff"];
            [_blankView addSubview:_failureView];
            _blankLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 300) * .5, _failureView.bottom + 13, 300, 20)];
            _blankLabel.backgroundColor = [UIColor whiteColor];
            _blankLabel.textAlignment = NSTextAlignmentCenter;
            _blankLabel.textColor = SSColor(177, 177, 177);
            _blankLabel.font = [UIFont systemFontOfSize:16];
            [_blankView addSubview:_blankLabel];
        } else {
            [_blankView removeFromSuperview];
            [_blankLabel removeFromSuperview];
            _blankView = nil;
            _blankLabel = nil;
        }
    }
}

#pragma mark - getter

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (NSMutableDictionary *)dataDictionary
{
    if (_dataDictionary == nil) {
        _dataDictionary = [NSMutableDictionary dictionary];
    }
    
    return _dataDictionary;
}

- (UIView *)defaultFooterView
{
    if (_defaultFooterView == nil) {
        _defaultFooterView = [[UIView alloc] init];
    }
    
    return _defaultFooterView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KCELLDEFAULTHEIGHT;
}

#pragma mark - public refresh

- (void)autoTriggerHeaderRefresh
{
    if (self.showRefreshHeader) {
        [self tableViewDidTriggerHeaderRefresh];
    }
}

/**
 *  下拉刷新事件
 */
- (void)tableViewDidTriggerHeaderRefresh
{
    
}

/**
 *  上拉加载事件
 */
- (void)tableViewDidTriggerFooterRefresh
{
    
}

- (void)tableViewDidFinishTriggerHeader:(BOOL)isHeader reload:(BOOL)reload
{
    __weak EaseRefreshTableViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (reload) {
            [weakSelf.tableView reloadData];
            weakSelf.showTableBlankView = NO;
        }
        
        if (isHeader) {
            [weakSelf.tableView.header endRefreshing];
            [weakSelf.tableView setContentOffset:CGPointMake(weakSelf.tableView.contentOffset.x, weakSelf.tableView.contentOffset.y + 0.5) animated:YES];
        }
        else{
            [weakSelf.tableView.footer endRefreshing];
        }
    });
}

#pragma mark - 设置返回按钮
- (void)setIsBackButton
{
    // 创建返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 50, 44);
    [backButton setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -20;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
}

- (void) backAction:(UIButton *) leftBtn {

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 设置关闭按钮
- (void)setIsDismissButton
{
    // 创建关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0, 0, 50, 44);
    [closeButton setImage:[UIImage imageNamed:@"CloseCommentView"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -20;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
}

- (void)closeAction:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  隐藏navgationbar
 */
- (void)hidenNavBar
{
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBarHidden = YES;
    
    // [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}
//// 显示NavgationBar
//- (void) showNavBar:(UIColor *) color{
//    
//    self.navigationController.navigationBarHidden = NO;
//    if (color) {
//        [self.navigationController.navigationBar lt_setBackgroundColor:color];
//    } else {
//        [self.navigationController.navigationBar lt_setBackgroundColor:kNavBackgroundColor];
//    }
//}

#pragma mark - 设置标题颜色为白色
//- (void)setTitleColorIsWhite:(BOOL)titleColorIsWhite
//{
//    if (titleColorIsWhite == YES) {
//        [self.navigationController.navigationBar setTitleTextAttributes:
//         [NSDictionary dictionaryWithObjectsAndKeys:
//          [UIColor whiteColor],
//          NSForegroundColorAttributeName,
//          nil]];
//    } else {
//        [self.navigationController.navigationBar setTitleTextAttributes:
//         [NSDictionary dictionaryWithObjectsAndKeys:
//          kBlackTextColor,
//          NSForegroundColorAttributeName,
//          nil]];
//    }
//}

@end
