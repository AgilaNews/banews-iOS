//
//  VideoViewController.m
//  Agilanews
//
//  Created by 张思思 on 17/1/23.
//  Copyright © 2017年 banews. All rights reserved.
//

#import "VideoViewController.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "HomeViewController.h"
#import "HomeTableViewController.h"
#import "SearchViewController.h"

static CGFloat const ButtonHeight = 40;

@interface VideoViewController ()

@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = kWhiteBgColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 添加导航栏右侧按钮
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.backgroundColor = kOrangeColor;
    searchBtn.frame = CGRectMake(0, 0, 40, 38);
    searchBtn.imageView.backgroundColor = kOrangeColor;
    [searchBtn setImage:[UIImage imageNamed:@"icon_search"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc]initWithCustomView:searchBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, searchItem];

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
                                             selector:@selector(updateChannel:)
                                                 name:KNOTIFICATION_UpdateCategories
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh_success)
                                                 name:KNOTIFICATION_Refresh_Success
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_segmentVC) {
        // 添加分段控制器
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _segmentVC = [[SegmentViewController alloc]init];
        // 设置尺寸
        _segmentVC.buttonWidth = 80;
        _segmentVC.buttonHeight = ButtonHeight;
        _segmentVC.headViewBackgroundColor = [UIColor whiteColor];
        // 添加标题
        NSMutableArray *titleArray = [NSMutableArray array];
        if (appDelegate.videoCategories.count > 0) {
            // 频道数组不为空
            for (CategoriesModel *model in appDelegate.videoCategories) {
                [titleArray addObject:model.name];
            }
        } else {
            // 频道数组为空
            NSArray *nameArray = @[@"Hot",
                                   @"News",
                                   @"Ent",
                                   @"Fun",
                                   @"Show",
                                   @"Sports",
                                   @"Lifestyle"];
            NSArray *channelIDArray = @[@30001,
                                        @31001,
                                        @31002,
                                        @31003,
                                        @31004,
                                        @31005,
                                        @31006];
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
            appDelegate.videoCategories = [NSMutableArray arrayWithArray:models];
        }
        _segmentVC.titleArray = titleArray;
        _segmentVC.titleColor = SSColor_RGB(102);
        _segmentVC.titleSelectedColor = kOrangeColor;
        // 添加表视图控制器
        NSMutableArray *controlArray = [NSMutableArray array];
        for (int i = 0; i < _segmentVC.titleArray.count; i++) {
            HomeTableViewController *homeTableCtrl = [[HomeTableViewController alloc] initWithModel:appDelegate.videoCategories[i]];
            homeTableCtrl.segmentVC = _segmentVC;
            [controlArray addObject:homeTableCtrl];
        }
        _segmentVC.subViewControllers = controlArray;
        [_segmentVC initSegment];
        [_segmentVC addParentController:self navView:_navView];
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
    NSString *videoCategoryFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/videoCategory.data"];
    [NSKeyedArchiver archiveRootObject:appDelegate.videoCategories toFile:videoCategoryFilePath];
    // 存储频道版本号
    NSNumber *version = notif.object;
    if (version.integerValue > 0) {
        DEF_PERSISTENT_SET_OBJECT(@"channel_version", version);
    }
    // 添加标题
    NSMutableArray *titleArray = [NSMutableArray array];
    for (CategoriesModel *model in appDelegate.videoCategories) {
        [titleArray addObject:model.name];
    }
    _segmentVC.titleArray = titleArray;
    _segmentVC.titleColor = SSColor_RGB(102);
    _segmentVC.titleSelectedColor = kOrangeColor;
    // 添加表视图控制器
    NSMutableArray *controlArray = [NSMutableArray array];
    for (int i = 0; i < _segmentVC.titleArray.count; i++) {
        HomeTableViewController *homeTableCtrl = [[HomeTableViewController alloc] initWithModel:appDelegate.videoCategories[i]];
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

- (void)updateChannel:(NSNotification *)notif
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSNumber *version = notif.object[@"version"];
    NSMutableArray *categoryArray = notif.object[@"videoCategory"];
    NSMutableArray *newArray = [NSMutableArray array];
    // 查找是否有新频道
    for (CategoriesModel *newModel in categoryArray) {
        BOOL isNew = YES;
        for (CategoriesModel *model in appDelegate.videoCategories) {
            if ([newModel.channelID isEqualToNumber:model.channelID]) {
                isNew = NO;
                break;
            }
        }
        if (isNew) {
            // 发现新频道
            newModel.isNew = YES;
            [newArray addObject:newModel];
        }
    }
    // 插入新频道
    for (CategoriesModel *newModel in newArray) {
        [appDelegate.videoCategories insertObject:newModel atIndex:newModel.index.integerValue];
    }
    if (newArray.count > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_AddRedPoint object:nil];
    }
    // 查找是否有删除频道
    NSMutableArray *deleteArray = [NSMutableArray array];
    for (CategoriesModel *model in appDelegate.videoCategories) {
        BOOL isHave = NO;
        for (CategoriesModel *newModel in categoryArray) {
            if ([newModel.channelID isEqualToNumber:model.channelID]) {
                isHave = YES;
                break;
            }
        }
        if (!isHave) {
            // 发现删除频道
            [deleteArray addObject:model];
        }
    }
    // 删除频道
    if (deleteArray.count <= 3) {
        for (CategoriesModel *model in deleteArray) {
            [appDelegate.videoCategories removeObject:model];
        }
    }
    if (newArray.count > 0 || deleteArray.count > 0) {
        [self addSegment:[NSNotification notificationWithName:KNOTIFICATION_Categories object:version]];
        return;
    }
    // 判断是否有调整顺序
    if (appDelegate.videoCategories.count == categoryArray.count) {
        for (int i = 0; i < appDelegate.videoCategories.count; i++) {
            CategoriesModel *model = appDelegate.videoCategories[i];
            CategoriesModel *newModel = categoryArray[i];
            if (![model.channelID isEqualToNumber:newModel.channelID]) {
                appDelegate.videoCategories = categoryArray;
                [self addSegment:[NSNotification notificationWithName:KNOTIFICATION_Categories object:version]];
            }
        }
    }
}

/**
 *  导航栏右侧按钮点击事件
 *
 *  @param button 按钮
 */
- (void)searchAction
{
    SearchViewController *searchVC = [[SearchViewController alloc] init];
    searchVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchVC animated:YES];
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
    //#if DEBUG
    //    [iConsole info:[NSString stringWithFormat:@"Home_TopRefresh_Click:%@",articleParams],nil];
    //#endif
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

#pragma mark - Notification
/**
 *  刷新成功
 */
- (void)refresh_success
{
    [_titleButton setUserInteractionEnabled:YES];
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
