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
#import "GuideVideoTab.h"
#import "GuideFirstVideoTab.h"
#import "GuideFirstMeTab.h"

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addRedPoint)
                                                 name:KNOTIFICATION_AddRedPoint
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeRedPoint)
                                                 name:KNOTIFICATION_RemoveRedPoint
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh_success)
                                                 name:KNOTIFICATION_Refresh_Success
                                               object:nil];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([DEF_PERSISTENT_GET_OBJECT(kHaveNewChannel) isEqual:@1] || [DEF_PERSISTENT_GET_OBJECT(kHaveNewNotif) isEqual:@1]) {
        [self addRedPoint];
    }
    
    if (![DEF_PERSISTENT_GET_OBJECT(SS_GuideVideoKey) isEqualToNumber:@1]) {
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:[GuideVideoTab sharedInstance]];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_PausedVideo object:nil];
    JTNavigationController *navCtrl = (JTNavigationController *)viewController;
    if ([navCtrl.jt_viewControllers.firstObject isKindOfClass:[HomeViewController class]]) {
        if (self.index == 0) {
            HomeViewController *homeVC = navCtrl.jt_viewControllers.firstObject;
            HomeTableViewController *homeTBC = homeVC.segmentVC.subViewControllers[homeVC.segmentVC.selectIndex - 10000];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Refresh object:homeTBC.model.channelID];
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
            animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-M_PI_2, 0.0, 0.0, -1.0)];
            animation.duration = 0.25;
            animation.cumulative = YES;
            animation.repeatCount = HUGE_VALF;
            UIView *view = [[self.tabBar subviews] objectAtIndex:tabBarController.selectedIndex + 1];
            [view.subviews.firstObject.layer addAnimation:animation forKey:nil];
        }
        self.index = 0;
    } else if ([navCtrl.jt_viewControllers.firstObject isKindOfClass:[VideoViewController class]]) {
        if (![DEF_PERSISTENT_GET_OBJECT(SS_GuideFirstVideoTab) isEqualToNumber:@1]) {
            [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:[GuideFirstVideoTab sharedInstance]];
        }
        if (self.index == 1) {
            VideoViewController *videoVC = navCtrl.jt_viewControllers.firstObject;
            HomeTableViewController *homeTBC = videoVC.segmentVC.subViewControllers[videoVC.segmentVC.selectIndex - 10000];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Refresh object:homeTBC.model.channelID];
        }
        self.index = 1;
    } else if ([navCtrl.jt_viewControllers.firstObject isKindOfClass:[MeViewController class]]) {
        if (![DEF_PERSISTENT_GET_OBJECT(SS_GuideFirstMeTab) isEqualToNumber:@1]) {
            [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:[GuideFirstMeTab sharedInstance]];
        }
        self.index = 2;
    }
}

- (void)addRedPoint
{
    float side = (kScreenWidth / 6.0) * 5 + 10;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(side, 5, 6, 6)];
    view.backgroundColor = SSColor(233, 51, 17);
    view.layer.cornerRadius = 3;
    view.layer.masksToBounds = YES;
    view.tag = 2017;
    [self.tabBar addSubview:view];
}
- (void)removeRedPoint
{
    if (![DEF_PERSISTENT_GET_OBJECT(kHaveNewNotif) isEqualToNumber:@1] && ![DEF_PERSISTENT_GET_OBJECT(kHaveNewChannel) isEqualToNumber:@1]) {
        DEF_PERSISTENT_SET_OBJECT(kHaveNewNotif, @0);
        DEF_PERSISTENT_SET_OBJECT(kHaveNewChannel, @0);
        UIView *view = [self.tabBar viewWithTag:2017];
        if (view) {
            [view removeFromSuperview];
        }
    }
}

- (void)refresh_success
{
    UIView *view = [[self.tabBar subviews] objectAtIndex:self.tabBarController.selectedIndex + 1];
    [view.subviews.firstObject.layer removeAllAnimations];
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
