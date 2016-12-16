//
//  HomeViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/7/14.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "HomeTableViewController.h"
#import "CategoriesModel.h"

static CGFloat const ButtonHeight = 40;

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = kWhiteBgColor;
    self.automaticallyAdjustsScrollViewInsets = NO;

    // 添加导航栏左侧按钮
    _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftButton.frame = CGRectMake(0, 0, 44, 44);
    [_leftButton setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
    [_leftButton addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_leftButton];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -12;
        self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
    }
    if ([DEF_PERSISTENT_GET_OBJECT(kHaveNewChannel) isEqual:@1] || [DEF_PERSISTENT_GET_OBJECT(kHaveNewNotif) isEqual:@1]) {
        [self addRedPoint];
    }
    
    // 添加导航栏标题按钮
    _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_titleButton setAdjustsImageWhenHighlighted:NO];
    _titleButton.frame = CGRectMake(0, 0, 126, 22);
    [_titleButton setImage:[UIImage imageNamed:@"logo_text"] forState:UIControlStateNormal];
    [_titleButton addTarget:self action:@selector(titleAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = _titleButton;
    
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addSegment:)
                                                 name:KNOTIFICATION_Categories
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh_success)
                                                 name:KNOTIFICATION_Refresh_Success
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(findNewChannel)
                                                 name:KNOTIFICATION_FindNewChannel
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanNewChannel)
                                                 name:KNOTIFICATION_CleanNewChannel
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(findNewNotif)
                                                 name:KNOTIFICATION_FindNewNotif
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanNewNotif)
                                                 name:KNOTIFICATION_CleanNewNotif
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkNewNotif)
                                                 name:KNOTIFICATION_CheckNewNotif
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeBackToTopView)
                                                 name:KNOTIFICATION_Refresh
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectChannelAction)
                                                 name:KNOTIFICATION_Secect_Channel
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeBackToTopView)
                                                 name:KNOTIFICATION_Scroll_Channel
                                               object:nil];
    
    // 添加分段控制器
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _segmentVC = [[SegmentViewController alloc]init];
    // 设置尺寸
    _segmentVC.buttonWidth = 80;
    _segmentVC.buttonHeight = ButtonHeight;
    _segmentVC.headViewBackgroundColor = [UIColor whiteColor];
    // 添加标题
    NSMutableArray *titleArray = [NSMutableArray array];
    if (appDelegate.categoriesArray.count > 0) {
        // 频道数组不为空
        for (CategoriesModel *model in appDelegate.categoriesArray) {
            [titleArray addObject:model.name];
        }
    } else {
        // 频道数组为空
//        [{"id":"10001","tag":0,"fixed":1,"name":"Hot","index":0},
//        {"id":"30001","tag":1,"fixed":0,"name":"Videos","index":1},
//        {"id":"10010","tag":0,"fixed":0,"name":"National","index":2},
//        {"id":"10004","tag":1,"fixed":0,"name":"Entertainment","index":3},
//        {"id":"10011","tag":1,"fixed":0,"name":"Photos","index":4},
//        {"id":"10013","tag":0,"fixed":0,"name":"NBA","index":5},
//        {"id":"10003","tag":0,"fixed":0,"name":"Sports","index":6},
//        {"id":"10002","tag":0,"fixed":0,"name":"World","index":7},
//        {"id":"10012","tag":0,"fixed":0,"name":"GIFs","index":8},
//        {"id":"10007","tag":0,"fixed":0,"name":"Business","index":9},
//        {"id":"10006","tag":0,"fixed":0,"name":"Lifestyle","index":10},
//        {"id":"10009","tag":0,"fixed":0,"name":"Opinion","index":11},
//        {"id":"10008","tag":0,"fixed":0,"name":"Sci&Tech","index":12},
//        {"id":"10015","tag":0,"fixed":0,"name":"Food","index":13},
//        {"id":"10005","tag":0,"fixed":0,"name":"Games","index":14}]
        NSArray *nameArray = @[@"Hot",
                               @"Videos",
                               @"National",
                               @"Entertainment",
                               @"Photos",
                               @"NBA",
                               @"Sports",
                               @"World",
                               @"GIFs",
                               @"Business",
                               @"Lifestyle",
                               @"Opinion",
                               @"Sci&Tech",
                               @"Food",
                               @"Games"];
        NSArray *channelIDArray = @[@10001,
                                    @30001,
                                    @10010,
                                    @10004,
                                    @10011,
                                    @10013,
                                    @10003,
                                    @10002,
                                    @10012,
                                    @10007,
                                    @10006,
                                    @10009,
                                    @10008,
                                    @10015,
                                    @10005];
        NSMutableArray *models = [NSMutableArray array];
        for (int i = 0; i < nameArray.count; i++) {
            CategoriesModel *model = [[CategoriesModel alloc] init];
            model.name = nameArray[i];
            model.channelID = channelIDArray[i];
            if (i == 0) {
                model.fixed = YES;
            }
            if (i == 1 || i == 3 || i == 4) {
                model.tag = YES;
            }
            [titleArray addObject:model.name];
            [models addObject:model];
        }
        appDelegate.categoriesArray = [NSMutableArray arrayWithArray:models];
    }
    _segmentVC.titleArray = titleArray;
    _segmentVC.titleColor = SSColor_RGB(102);
    _segmentVC.titleSelectedColor = kOrangeColor;
    // 添加表视图控制器
    NSMutableArray *controlArray = [NSMutableArray array];
    for (int i = 0; i < _segmentVC.titleArray.count; i++) {
        HomeTableViewController *homeTableCtrl = [[HomeTableViewController alloc] initWithModel:appDelegate.categoriesArray[i]];
        homeTableCtrl.segmentVC = _segmentVC;
        [controlArray addObject:homeTableCtrl];
    }
    _segmentVC.subViewControllers = controlArray;
    [_segmentVC initSegment];
    [_segmentVC addParentController:self navView:_navView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.view.top == 44) {
        self.view.frame = CGRectMake(self.view.left, self.view.top + 20, self.view.width, self.view.height - 20);
    }
}

- (void)dealloc
{
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 添加分段控制器
- (void)addSegment:(NSNotification *)notif
{
    _segmentVC.subViewControllers = nil;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // 缓存频道数据
    NSString *categoryFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/category.data"];
    [NSKeyedArchiver archiveRootObject:appDelegate.categoriesArray toFile:categoryFilePath];
    // 存储频道版本号
    NSNumber *version = notif.object;
    if (version.integerValue > 0) {
        DEF_PERSISTENT_SET_OBJECT(@"channel_version", version);
    }
    // 添加标题
    NSMutableArray *titleArray = [NSMutableArray array];
    for (CategoriesModel *model in appDelegate.categoriesArray) {
        [titleArray addObject:model.name];
    }
    _segmentVC.titleArray = titleArray;
    _segmentVC.titleColor = SSColor_RGB(102);
    _segmentVC.titleSelectedColor = kOrangeColor;
    // 添加表视图控制器
    NSMutableArray *controlArray = [NSMutableArray array];
    for (int i = 0; i < _segmentVC.titleArray.count; i++) {
        HomeTableViewController *homeTableCtrl = [[HomeTableViewController alloc] initWithModel:appDelegate.categoriesArray[i]];
        homeTableCtrl.segmentVC = _segmentVC;
        [controlArray addObject:homeTableCtrl];
    }
    _segmentVC.subViewControllers = controlArray;
    // 设置尺寸
    _segmentVC.buttonWidth = 80;
    _segmentVC.buttonHeight = ButtonHeight;
    [_segmentVC initSegment];
    [_segmentVC addParentController:self navView:_navView];
}

/**
 *  导航栏左侧按钮点击事件
 *
 *  @param button 按钮
 */
- (void)leftAction:(UIButton *)button
{
    // 打点-点击侧边栏按钮-010115
    if (_segmentVC.titleArray.count > 0) {
        NSString *channelName = _segmentVC.titleArray[_segmentVC.selectIndex - 10000];
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       channelName, @"channel",
                                       nil];
        [Flurry logEvent:@"Home_MenuButton_Click" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Home_MenuButton_Click:%@",articleParams],nil];
#endif
    }
    if (_leftView == nil) {
        _leftView = [[LeftView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    }
    [[UIApplication sharedApplication].keyWindow addSubview:_leftView];
    _leftView.isShow = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_PausedVideo object:nil];
}

/**
 *  首页刷新按钮点击事件
 *
 *  @param button 标题按钮
 */
- (void)titleAction:(UIButton *)button
{
    // 打点-顶部banner刷新按钮被点击-010102
    NSString *channelName = _segmentVC.titleArray[_segmentVC.selectIndex - 10000];
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   channelName, @"channel",
                                   nil];
    [Flurry logEvent:@"Home_TopRefresh_Click" withParameters:articleParams];
#if DEBUG
    [iConsole info:[NSString stringWithFormat:@"Home_TopRefresh_Click:%@",articleParams],nil];
#endif
    // 创建弹性效果关键帧动画
    CAKeyframeAnimation *keyFrame = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    // 设置放大倍数
    keyFrame.values = @[@1.15,@1.0,@1.06,@1.0,@1.02,@1.0,@1.006,@1.0];
    // 设置动画时间
    keyFrame.duration = .5;
    // 设置放大效果每帧时间
    keyFrame.keyTimes = @[@.1,@.3,@.5,@.7,@.85,@.95,@1.0];
    // 添加关键帧动画
    [_titleButton.layer addAnimation:keyFrame forKey:@"keyFrame"];
    [_titleButton setUserInteractionEnabled:NO];
    HomeTableViewController *homeTBC = _segmentVC.subViewControllers[_segmentVC.selectIndex - 10000];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Refresh object:homeTBC.model.channelID];
}

- (void)showBackToTopView
{
    if (![self.backToTop.superview isEqual:self.view]) {
        [self.view addSubview:self.backToTop];
        self.backToTop.alpha = 0;
        [UIView animateWithDuration:.3 animations:^{
            self.backToTop.alpha = 1;
        }];
    }
}

- (void)removeBackToTopView
{
    [UIView animateWithDuration:.3 animations:^{
        self.backToTop.alpha = 0;
    } completion:^(BOOL finished) {
        [self.backToTop removeFromSuperview];
    }];
}

#pragma mark - setter/getter
- (UIView *)backToTop
{
    if (_backToTop == nil) {
        _backToTop = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 64 - 43, kScreenWidth, 43)];
        _backToTop.backgroundColor = [UIColor colorWithRed:78 / 255.0 green:173 / 255.0 blue:240 / 255.0 alpha:.95];
        _backToTop.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToTopAction)];
        [_backToTop addGestureRecognizer:tap];
        NSString *toTopString = @"Get the latest stories";
        CGSize toTopSize = [toTopString calculateSize:CGSizeMake(300, 16) font:[UIFont systemFontOfSize:15]];
        UIImageView *toTopView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 13 - 8 - toTopSize.width) * .5, (_backToTop.height - 11) * .5, 13, 11)];
        toTopView.contentMode = UIViewContentModeScaleAspectFit;
        toTopView.image = [UIImage imageNamed:@"icon_arrow_top"];
        [_backToTop addSubview:toTopView];
        UILabel *toTopLabel = [[UILabel alloc] initWithFrame:CGRectMake(toTopView.right + 8, (_backToTop.height - toTopSize.height) * .5, toTopSize.width, toTopSize.height)];
        toTopLabel.font = [UIFont systemFontOfSize:15];
        toTopLabel.textColor = [UIColor whiteColor];
        toTopLabel.text = toTopString;
        [_backToTop addSubview:toTopLabel];
    }
    return _backToTop;
}

- (void)backToTopAction
{
    HomeTableViewController *homeTBC = _segmentVC.subViewControllers[_segmentVC.selectIndex - 10000];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Refresh object:homeTBC.model.channelID];
}

#pragma mark - Notification
/**
 *  刷新成功
 */
- (void)refresh_success
{
    [_titleButton setUserInteractionEnabled:YES];
}

// 发现新频道
- (void)findNewChannel
{
    DEF_PERSISTENT_SET_OBJECT(kHaveNewChannel, @1);
    [self addRedPoint];
}

// 删除小红点
- (void)cleanNewChannel
{
    DEF_PERSISTENT_SET_OBJECT(kHaveNewChannel, @0);
    if ([DEF_PERSISTENT_GET_OBJECT(kHaveNewNotif) isEqualToNumber:@1]) {
        return;
    }
    [_redPoint removeFromSuperview];
}
    
// 发现新通知
- (void)findNewNotif
{
    DEF_PERSISTENT_SET_OBJECT(kHaveNewNotif, @1);
    [self addRedPoint];
}
    
- (void)cleanNewNotif
{
    DEF_PERSISTENT_SET_OBJECT(kHaveNewNotif, @0);
    if ([DEF_PERSISTENT_GET_OBJECT(kHaveNewChannel) isEqualToNumber:@1]) {
        return;
    }
    [_redPoint removeFromSuperview];
}

/**
 检查是否有新通知
 */
- (void)checkNewNotif
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.model == nil) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSNumber *last_id = DEF_PERSISTENT_GET_OBJECT(kLastNotifID);
    if (last_id == nil) {
        last_id = @0;
    }
    [params setObject:last_id forKey:@"latest_id"];
    [[SSHttpRequest sharedInstance] get:kHomeUrl_NotifCheck params:params contentType:UrlencodedType serverType:NetServer_Home success:^(id responseObj) {
        NSString *status = responseObj[@"status"];
        if (status && [status isEqualToString:@"1"]) {
            // 有新通知
            DEF_PERSISTENT_SET_OBJECT(kHaveNewNotif, @1);
            [weakSelf addRedPoint];
        }
    } failure:^(NSError *error) {
        
    } isShowHUD:NO];
}


/**
 选择频道通知
 */
- (void)selectChannelAction
{
    [self removeBackToTopView];
    [self checkNewNotif];
}

// 添加小红点
- (void)addRedPoint
{
    _redPoint = [[UIView alloc] initWithFrame:CGRectMake(_leftButton.right - 15, _leftButton.top + 10, 6, 6)];
    _redPoint.backgroundColor = SSColor(233, 51, 17);
    _redPoint.layer.cornerRadius = 3;
    _redPoint.layer.masksToBounds = YES;
    [_leftButton addSubview:_redPoint];
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
