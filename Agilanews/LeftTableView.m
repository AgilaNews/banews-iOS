//
//  LeftTableView.m
//  Agilanews
//
//  Created by 张思思 on 16/7/20.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "LeftTableView.h"
#import "LeftCell.h"
#import "LeftView.h"
#import "BaseNavigationController.h"
#import "HomeViewController.h"
#import "LoginViewController.h"
#import "UserInfoViewController.h"
#import "SettingsViewController.h"
#import "FavoritesViewController.h"
#import "FeedbackViewController.h"
#import "ChannelViewController.h"

@implementation LeftTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor = kWhiteBgColor;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.dataSource = self;
        self.delegate = self;
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - 328)];
        footerView.backgroundColor = kWhiteBgColor;
        self.tableFooterView = footerView;
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 140)];
        headerView.backgroundColor = SSColor(214, 214, 214);
        _headerViewAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 57, 57)];
        _headerViewAvatar.center = headerView.center;
        _headerViewAvatar.backgroundColor = SSColor(214, 214, 214);
        _headerViewAvatar.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_headerViewAvatar addGestureRecognizer:tap];
        _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (_appDelegate.model) {
            [_headerViewAvatar sd_setImageWithURL:[NSURL URLWithString:_appDelegate.model.portrait] placeholderImage:[UIImage imageNamed:@"icon_sidebar_head"] options:SDWebImageLowPriority | SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image)
                {
                    _headerViewAvatar.image = [_headerViewAvatar.image yal_imageWithRoundedCornersAndSize:_headerViewAvatar.frame.size andCornerRadius:_headerViewAvatar.height * 0.5];
                } else
                {
                    _headerViewAvatar.image = [UIImage imageNamed:@"icon_sidebar_head"];
                }
            }];
        } else {
            _headerViewAvatar.image = [UIImage imageNamed:@"icon_sidebar_head"];
        }
        [headerView addSubview:_headerViewAvatar];
        self.tableHeaderView = headerView;
        
        // 注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:KNOTIFICATION_Login_Success object:nil];
    }
    return self;
}

- (void)dealloc
{
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 28;
            break;
            
        default:
            return 14;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 28)];
            view.backgroundColor = kWhiteBgColor;
            return view;
        }
            break;
            
        default:
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 14)];
            view.backgroundColor = kWhiteBgColor;
            return view;
            
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"leftCellID";
    LeftCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[LeftCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    switch (indexPath.section) {
        case 0:
            cell.titleImageView.image = [UIImage imageNamed:@"icon_sidebar_favorites"];
            cell.titleLabel.text = @"Channels";
            break;
        case 1:
            cell.titleImageView.image = [UIImage imageNamed:@"icon_sidebar_favorites"];
            cell.titleLabel.text = @"Favorites";
            break;
        case 2:
            cell.titleImageView.image = [UIImage imageNamed:@"icon_sidebar_feedback"];
            cell.titleLabel.text = @"Feedback";
            break;
        case 3:
            cell.titleImageView.image = [UIImage imageNamed:@"icon_sidebar_settings"];
            cell.titleLabel.text = @"Settings";
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LeftView *leftView = (LeftView *)self.superview;
    leftView.isShow = NO;
    BaseNavigationController *navCtrl = (BaseNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    switch (indexPath.section) {
        case 0:
        {
//            // 打点-点击收藏-010403
//            [Flurry logEvent:@"Info_Icon_Click"];
//#if DEBUG
//            [iConsole info:@"Info_Icon_Click",nil];
//#endif
            // 点击Channels
            ChannelViewController *channelVC = [[ChannelViewController alloc] init];
            [navCtrl pushViewController:channelVC animated:YES];
            break;
        }
        case 1:
        {
            // 打点-点击收藏-010403
            [Flurry logEvent:@"Info_Icon_Click"];
#if DEBUG
            [iConsole info:@"Info_Icon_Click",nil];
#endif
            // 点击Favorites
            if (_appDelegate.model) {
                // 直接进入收藏
                FavoritesViewController *favoritesVC = [[FavoritesViewController alloc] init];
                [navCtrl pushViewController:favoritesVC animated:YES];
            } else {
                // 登录后进入收藏
                LoginViewController *loginVC = [[LoginViewController alloc] init];
                loginVC.isFavorite = YES;
                [navCtrl pushViewController:loginVC animated:YES];
            }
            break;
        }
        case 2:
        {
            // 打点-点击反馈-010404
            [Flurry logEvent:@"Menu_FeedbackButton_Click"];
#if DEBUG
            [iConsole info:@"Menu_FeedbackButton_Click",nil];
#endif
            // 点击Feedback
            FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] init];
            [navCtrl pushViewController:feedbackVC animated:YES];
            break;
        }
        case 3:
        {
            // 打点-点击设置-010406
            [Flurry logEvent:@"Menu_SetButton_Click"];
#if DEBUG
            [iConsole info:@"Menu_SetButton_Click",nil];
#endif
            // 点击Settings
            SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
            [navCtrl pushViewController:settingsVC animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        self.backgroundColor = SSColor(214, 214, 214);
    } else {
        self.backgroundColor = kWhiteBgColor;
    }
}

#pragma mark - 登录头像点击事件
- (void)tapAction
{
    LeftView *leftView = (LeftView *)self.superview;
    leftView.isShow = NO;
    BaseNavigationController *navCtrl = (BaseNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if (_appDelegate.model) {
        // 打点-点击头像-010701
        [Flurry logEvent:@"Info_Icon_Click"];
#if DEBUG
        [iConsole info:@"Info_Icon_Click",nil];
#endif
        UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
        userInfoVC.model = _appDelegate.model;
        [navCtrl pushViewController:userInfoVC animated:YES];
    } else {
        // 打点-点击登陆-010402
        [Flurry logEvent:@"Menu_LoginButton_Click"];
#if DEBUG
        [iConsole info:@"Menu_LoginButton_Click",nil];
#endif
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [navCtrl pushViewController:loginVC animated:YES];
    }
}

/**
 *  登录成功
 */
- (void)loginSuccess
{
    [_headerViewAvatar sd_setImageWithURL:[NSURL URLWithString:_appDelegate.model.portrait] placeholderImage:[UIImage imageNamed:@"icon_sidebar_head"] options:SDWebImageLowPriority | SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image)
        {
            _headerViewAvatar.image = [_headerViewAvatar.image yal_imageWithRoundedCornersAndSize:_headerViewAvatar.frame.size andCornerRadius:_headerViewAvatar.height * 0.5];
        } else
        {
            _headerViewAvatar.image = [UIImage imageNamed:@"icon_sidebar_head"];
        }
    }];
}

/**
 *  退出登录
 */
- (void)userLogOut
{
    _headerViewAvatar.image = [UIImage imageNamed:@"icon_sidebar_head"];
    _appDelegate.model = nil;
}


@end
