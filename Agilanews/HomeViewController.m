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

static CGFloat const ButtonHeight = 35;

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = kWhiteBgColor;
    self.automaticallyAdjustsScrollViewInsets = NO;

    // 添加导航栏左侧按钮
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 20, 50, 44);
    [leftButton setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue] >= 7) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;
        self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
    }
    
    // 添加导航栏标题按钮
    _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_titleButton setAdjustsImageWhenHighlighted:NO];
    _titleButton.frame = CGRectMake(0, 0, 126, 22);
    [_titleButton setImage:[UIImage imageNamed:@"logo_text"] forState:UIControlStateNormal];
    [_titleButton addTarget:self action:@selector(titleAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = _titleButton;
    
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSegment) name:KNOTIFICATION_Categories object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh_success) name:KNOTIFICATION_Refresh_Success object:nil];
    
    // 添加分段控制器
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _segmentVC = [[SegmentViewController alloc]init];
    // 设置尺寸
    _segmentVC.buttonWidth = 80;
    _segmentVC.buttonHeight = ButtonHeight;
    _segmentVC.headViewBackgroundColor = SSColor(235, 235, 235);
    // 添加标题
    NSMutableArray *titleArray = [NSMutableArray array];
    if (appDelegate.categoriesArray.count > 0) {
        // 频道数组不为空
        for (CategoriesModel *model in appDelegate.categoriesArray) {
            [titleArray addObject:model.name];
        }
    } else {
        // 频道数组为空
        NSArray *nameArray = @[@"Hot",@"World",@"Sports",@"Entertainment",@"Games",@"Lifestyle",@"Business",@"Sci&Tech",@"Opinion"];
        NSMutableArray *models = [NSMutableArray array];
        for (int i = 0; i < 9; i++) {
            CategoriesModel *model = [[CategoriesModel alloc] init];
            model.name = nameArray[i];
            model.channelID = [NSNumber numberWithInt:10001 + i];
            [titleArray addObject:model.name];
            [models addObject:model];
        }
        appDelegate.categoriesArray = models;
    }
    _segmentVC.titleArray = titleArray;
    _segmentVC.titleColor = [UIColor blackColor];
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

- (void)dealloc
{
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 添加分段控制器
- (void)addSegment
{
    _segmentVC.subViewControllers = nil;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // 添加标题
    NSMutableArray *titleArray = [NSMutableArray array];
    for (CategoriesModel *model in appDelegate.categoriesArray) {
        [titleArray addObject:model.name];
    }
    _segmentVC.titleArray = titleArray;
    _segmentVC.titleColor = [UIColor blackColor];
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
    NSString *channelName = _segmentVC.titleArray[_segmentVC.selectIndex - 10000];
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   channelName, @"channel",
                                   nil];
    [Flurry logEvent:@"Home_MenuButton_Click" withParameters:articleParams];
    if (_leftView == nil) {
        _leftView = [[LeftView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    }
    [[UIApplication sharedApplication].keyWindow addSubview:_leftView];
    _leftView.isShow = YES;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Refresh object:[NSNumber numberWithInteger:_segmentVC.selectIndex]];
}

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
