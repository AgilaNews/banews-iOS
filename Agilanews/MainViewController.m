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
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:SSColor_RGB(102),
                                                       NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kOrangeColor,
                                                       NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
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
}

#pragma mark -标签栏代理方法
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
//    if ([viewController isKindOfClass:[UINavigationController class]]) {
//        [(UINavigationController *)viewController popToRootViewControllerAnimated:NO];
//    }
//    // 创建弹性效果关键帧动画
//    CAKeyframeAnimation *keyFrame = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
//    // 设置放大倍数
//    keyFrame.values = @[@1.4,@1.0,@1.25,@1.0,@1.125,@1.0,@1.06,@1.0];
//    // 设置动画时间
//    keyFrame.duration = .5;
//    // 设置放大效果每帧时间
//    keyFrame.keyTimes = @[@.1,@.3,@.5,@.7,@.85,@.95,@1.0];
//    // 添加关键帧动画
//    [[[[self.tabBar subviews] objectAtIndex:tabBarController.selectedIndex + 1] layer] addAnimation:keyFrame forKey:@"keyFrame"];
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
