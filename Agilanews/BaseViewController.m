//
//  BaseViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/7/19.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseNavigationController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置背景颜色
    self.view.backgroundColor = kWhiteBgColor;
    [self.navigationController.navigationBar lt_setBackgroundColor:kOrangeColor];
    // 设置导航栏标题字体大小
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self changeCanSideBack];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self changeCanSideBack];
}

/**
 *  修改侧滑返回手势
 */
- (void)changeCanSideBack
{
    BaseNavigationController *baseNavCtrl = nil;
    if ([self.navigationController isKindOfClass:[BaseNavigationController class]]) {
        baseNavCtrl = (BaseNavigationController *)self.navigationController;
    }
    if (self.navigationController.viewControllers.count > 1) {
        baseNavCtrl.isCanSideBack = YES;
    } else {
        baseNavCtrl.isCanSideBack = NO;
    }
}

#pragma mark - 设置返回按钮
- (void)setIsBackButton:(BOOL)isBackButton
{
    if (_isBackButton != isBackButton) {
        _isBackButton = isBackButton;
        
        // 创建返回按钮
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0, 50, 44);
        [backButton setImage:[UIImage imageNamed:@"icon_arrow_left"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // 设置导航栏左侧按钮
        [self setLeftBarButtonItemWithButton:backButton andBool:isBackButton];
    }
}

#pragma mark - 设置关闭按钮
- (void)setIsDismissButton:(BOOL)isDismissButton
{
    if (_isDismissButton != isDismissButton) {
        _isDismissButton = isDismissButton;
        
        // 创建关闭按钮
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(0, 0, 50, 44);
        [closeButton setImage:[UIImage imageNamed:@"icon_cancel"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // 设置导航栏左侧按钮
        [self setLeftBarButtonItemWithButton:closeButton andBool:isDismissButton];
    }
}

#pragma mark - 设置导航栏左侧按钮
- (void)setLeftBarButtonItemWithButton:(UIButton *)button andBool:(BOOL)Bool
{
    if (Bool == YES) {
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue] >=7 ) {
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            negativeSpacer.width = -20;
            self.navigationItem.leftBarButtonItems = @[negativeSpacer, buttonItem];
        }else{
            self.navigationItem.leftBarButtonItem = buttonItem;
        }
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

#pragma mark - backAction返回按钮点击事件
- (void)backAction:(UIButton *)button
{
    [SVProgressHUD dismiss];
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - backAction关闭按钮点击事件
- (void)closeAction:(UIButton *)button
{
    [SVProgressHUD dismiss];
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
    
     [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
// 显示NavgationBar
- (void) showNavBar
{
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar lt_setBackgroundColor:kOrangeColor];
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
