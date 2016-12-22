//
//  BaseViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/7/19.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, assign) BOOL isBackButton;
@property (nonatomic, assign) BOOL isDismissButton;

#pragma mark - backAction返回按钮点击事件
- (void)backAction:(UIButton *)button;
- (void)closeAction:(UIButton *)button;
/**
 *  隐藏NavgationBar
 */
//- (void) hidenNavBar;

/**
 *  显示NavgationBar
 */
//- (void) showNavBar;
@end
