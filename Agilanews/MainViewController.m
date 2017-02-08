//
//  MainViewController.m
//  Agilanews
//
//  Created by 张思思 on 17/1/23.
//  Copyright © 2017年 banews. All rights reserved.
//

#import "MainViewController.h"
#import "HomeViewController.h"
#import "VideoViewController.h"
#import "MeViewController.h"
#import "HomeTableViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

+ (instancetype)shareTabBarViewController
{
    static MainViewController *tabBarVC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tabBarVC = [[self alloc] init];
    });
    return tabBarVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    // 初始化视图控制器
    [self _initViewControllers];
    // 初始化标签栏
    [self _initTabBarView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addRedPoint) name:KNOTIFICATION_AddRedPoint object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRedPoint) name:KNOTIFICATION_RemoveRedPoint object:nil];

    if ([DEF_PERSISTENT_GET_OBJECT(kHaveNewChannel) isEqual:@1] || [DEF_PERSISTENT_GET_OBJECT(kHaveNewNotif) isEqual:@1]) {
        [self addRedPoint];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 初始化视图控制器
- (void)_initViewControllers
{
    // 创建标签视图控制器
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    VideoViewController *videoVC = [[VideoViewController alloc] init];
    MeViewController *meVC = [[MeViewController alloc] init];
    // 将控制器存入数组
    NSArray *viewCtrlArray = @[homeVC, videoVC, meVC];
    // 创建可变数组，存放导航控制器
    NSMutableArray *navCtrls = [NSMutableArray array];
    // 遍历视图控制器数组
    for (UIViewController *viewCtrl in viewCtrlArray) {
        // 为视图控制器添加导航栏
        JTNavigationController *navCtrl = [[JTNavigationController alloc] initWithRootViewController:viewCtrl];
//        navCtrl.delegate = self;
        [navCtrls addObject:navCtrl];
    }
    // 将导航控制器数组存入标签控制器
    self.viewControllers = navCtrls;
}

// 设置标签栏
- (void)_initTabBarView
{
    self.tabBar.translucent = NO;
    self.tabBar.hidden = NO;
    self.tabBar.barTintColor = [UIColor whiteColor];
    self.tabBar.tintColor = [UIColor whiteColor];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : SSColor_RGB(102),
                                                        NSFontAttributeName : [UIFont systemFontOfSize:11]}
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : kOrangeColor,
                                                        NSFontAttributeName : [UIFont systemFontOfSize:11]}
                                             forState:UIControlStateSelected];
    // 定义标签栏图片数组
    NSArray *titles = @[@"Home",
                        @"Video",
                        @"Me"];
    NSArray *imageNames = @[@"icon_nav_home_default",
                            @"icon_nav_video_default",
                            @"icon_nav_me_default"];
    NSArray *selectedImageNames = @[@"icon_nav_home_refresh",
                                    @"icon_nav_video_select",
                                    @"icon_nav_me_select"];
    
    for (int i = 0; i < imageNames.count; i++) {
        UITabBarItem *item = self.tabBar.items[i];
        item.title = titles[i];
        item.titlePositionAdjustment = UIOffsetMake(0, -2);
        item.selectedImage = [[UIImage imageNamed:selectedImageNames[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.tag = 10 + i;
        item.image = [[UIImage imageNamed:imageNames[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    }
    self.index = 0;
}

#pragma mark -标签栏代理方法
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    JTNavigationController *navCtrl = (JTNavigationController *)viewController;
    if ([navCtrl.jt_viewControllers.firstObject isKindOfClass:[HomeViewController class]]) {
        if (self.index == 0) {
            HomeViewController *homeVC = navCtrl.jt_viewControllers.firstObject;
            HomeTableViewController *homeTBC = homeVC.segmentVC.subViewControllers[homeVC.segmentVC.selectIndex - 10000];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Refresh object:homeTBC.model.channelID];
        }
        self.index = 0;
    } else if ([navCtrl.jt_viewControllers.firstObject isKindOfClass:[VideoViewController class]]) {
        self.index = 1;
    } else if ([navCtrl.jt_viewControllers.firstObject isKindOfClass:[MeViewController class]]) {
        self.index = 2;
    }
}

- (void)addRedPoint
{
    float side = (kScreenWidth / 3.0) / 2.0 + 10;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(side, 5, 6, 6)];
    view.backgroundColor = SSColor(233, 51, 17);
    view.layer.cornerRadius = 3;
    view.layer.masksToBounds = YES;
    [self.tabBar.subviews.lastObject addSubview:view];
}
- (void)removeRedPoint
{
    if (![DEF_PERSISTENT_GET_OBJECT(kHaveNewNotif) isEqualToNumber:@1] && ![DEF_PERSISTENT_GET_OBJECT(kHaveNewChannel) isEqualToNumber:@1]) {
        DEF_PERSISTENT_SET_OBJECT(kHaveNewNotif, @0);
        DEF_PERSISTENT_SET_OBJECT(kHaveNewChannel, @0);
        [self.tabBar.subviews.lastObject removeAllSubviews];
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
