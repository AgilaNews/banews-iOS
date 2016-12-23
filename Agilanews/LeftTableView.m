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
#import "UserInfoViewController.h"
#import "SettingsViewController.h"
#import "FavoritesViewController.h"
#import "FeedbackViewController.h"
#import "ChannelViewController.h"
#import "NotificationViewController.h"
#import "InterestsViewController.h"
#import "LoginView.h"
#import "UIButton+WebCache.h"

#define Facebook   200
#define Twitter    201
#define GooglePuls 202

@implementation LeftTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, kScreenHeight * .28)];
        _headerView.backgroundColor = [UIColor whiteColor];

        _avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _avatarButton.frame = CGRectMake(12, (_headerView.height - 9 - 18 - 57) * .5, 57, 57);
        _avatarButton.layer.cornerRadius = 57 * .5;
        _avatarButton.layer.borderColor = SSColor_RGB(235).CGColor;
        _avatarButton.layer.borderWidth = 1;
        _avatarButton.layer.masksToBounds = YES;
        [_avatarButton addTarget:self action:@selector(enterUserInfo) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:_avatarButton];
        
        for (int i = 0; i < 3; i++) {
            UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
            loginButton.frame = CGRectMake(12 + (50 + 18) * i, (_headerView.height - 9 - 18 - 50) * .5, 50, 50);
            loginButton.tag = 200 + i;
            [loginButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
            [_headerView addSubview:loginButton];
            switch (i) {
                case 0:
                    [loginButton setImage:[UIImage imageNamed:@"icon_login_facebook"] forState:UIControlStateNormal];
                    break;
                case 1:
                    [loginButton setImage:[UIImage imageNamed:@"icon_login_twitter"] forState:UIControlStateNormal];
                    break;
                case 2:
                    [loginButton setImage:[UIImage imageNamed:@"icon_login_google"] forState:UIControlStateNormal];
                    break;
                default:
                    break;
            }
        }
        _loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, _headerView.height - 9 - 18, self.width - 24, 18)];
        _loginLabel.backgroundColor = [UIColor whiteColor];
        _loginLabel.font = [UIFont boldSystemFontOfSize:17];
        _loginLabel.textColor = kOrangeColor;
        [_headerView addSubview:_loginLabel];

        _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (_appDelegate.model) {
            for (int i = 0; i < 3; i++) {
                UIButton *button = [_headerView viewWithTag:200 + i];
                button.hidden = YES;
            }
            _avatarButton.hidden = NO;
            [_avatarButton sd_setImageWithURL:[NSURL URLWithString:_appDelegate.model.portrait] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_sidebar_head"] options:SDWebImageLowPriority | SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    [_avatarButton setImage:[image yal_imageWithRoundedCornersAndSize:_avatarButton.frame.size andCornerRadius:_avatarButton.height * .5] forState:UIControlStateNormal];
                } else {
                    [_avatarButton setImage:[UIImage imageNamed:@"icon_sidebar_head"] forState:UIControlStateNormal];
                }
            }];
            _loginLabel.text = _appDelegate.model.name;
        } else {
            for (int i = 0; i < 3; i++) {
                UIButton *button = [_headerView viewWithTag:200 + i];
                button.hidden = NO;
                switch (i) {
                    case 0:
                        [button setImage:[UIImage imageNamed:@"icon_login_facebook"] forState:UIControlStateNormal];
                        break;
                    case 1:
                        [button setImage:[UIImage imageNamed:@"icon_login_twitter"] forState:UIControlStateNormal];
                        break;
                    case 2:
                        [button setImage:[UIImage imageNamed:@"icon_login_google"] forState:UIControlStateNormal];
                        break;
                    default:
                        break;
                }
            }
            _avatarButton.hidden = YES;
            _loginLabel.text = @"Click to Log in";
        }
        self.tableHeaderView = _headerView;
        self.tableFooterView = [UIView new];
        
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 5;
    }
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 6;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 6)];
    view.backgroundColor = [UIColor whiteColor];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
    lineView.backgroundColor = SSColor_RGB(217);
    [view addSubview:lineView];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 6)];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LeftCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [[LeftCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leftCell" HaveImage:YES];
        switch (indexPath.row) {
            case 0:
                cell.titleImageView.image = [UIImage imageNamed:@"icon_notification"];
                cell.titleLabel.text = @"Notification";
                if ([DEF_PERSISTENT_GET_OBJECT(kHaveNewNotif) isEqual:@1]) {
                    [self addRedPointWithLable:cell.titleLabel Index:indexPath.row];
                }
                break;
            case 1:
                cell.titleImageView.image = [UIImage imageNamed:@"icon_sidebar_interest"];
                cell.titleLabel.text = @"Interests";
                break;
            case 2:
                cell.titleImageView.image = [UIImage imageNamed:@"icon_sidebar_channel"];
                cell.titleLabel.text = @"Channels";
                if ([DEF_PERSISTENT_GET_OBJECT(kHaveNewChannel) isEqual:@1]) {
                    [self addRedPointWithLable:cell.titleLabel Index:indexPath.row];
                }
                break;
            case 3:
                cell.titleImageView.image = [UIImage imageNamed:@"icon_sidebar_favorites"];
                cell.titleLabel.text = @"Favorites";
                break;
            case 4:
                cell.titleImageView.image = [UIImage imageNamed:@"icon_facebook"];
                cell.titleLabel.text = @"Follow us on Facebook";
                break;
            default:
                break;
        }
    } else {
        cell = [[LeftCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leftCell" HaveImage:NO];
        switch (indexPath.row) {
            case 0:
                cell.titleLabel.text = @"Feedback";
                break;
            case 1:
                cell.titleLabel.text = @"Settings";
                break;
            default:
                break;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.superview isKindOfClass:[LeftView class]]) {
        LeftView *leftView = (LeftView *)self.superview;
        leftView.isShow = NO;
    }

    HomeViewController *homeVC = nil;
    if ([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[JTNavigationController class]]) {
        JTNavigationController *navCtrl = (JTNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        homeVC = navCtrl.jt_viewControllers.firstObject;
    } else {
        return;
    }
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                // 打点-点击通知按钮-010409
                [Flurry logEvent:@"Menu_Notification_Click"];
#if DEBUG
                [iConsole info:@"Menu_Notification_Click",nil];
#endif
                // 服务器打点-notification点击-050105
                NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
                [eventDic setObject:@"050105" forKey:@"id"];
                [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
                [eventDic setObject:[NetType getNetType] forKey:@"net"];
                if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
                    [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
                    [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
                } else {
                    [eventDic setObject:@"" forKey:@"lng"];
                    [eventDic setObject:@"" forKey:@"lat"];
                }
                NSString *abflag = DEF_PERSISTENT_GET_OBJECT(@"abflag");
                if (abflag && abflag.length > 0) {
                    [eventDic setObject:abflag forKey:@"abflag"];
                }
                NSDictionary *sessionDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                            DEF_PERSISTENT_GET_OBJECT(@"UUID"), @"id",
                                            [NSArray arrayWithObject:eventDic], @"events",
                                            nil];
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[NSArray arrayWithObject:sessionDic] forKey:@"sessions"];
                [[SSHttpRequest sharedInstance] post:@"" params:params contentType:JsonType serverType:NetServer_Log success:^(id responseObj) {
                    // 打点成功
                } failure:^(NSError *error) {
                    // 打点失败
                    [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(@"UUID") forKey:@"session"];
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [appDelegate.eventArray addObject:eventDic];
                } isShowHUD:NO];
                // 点击Notification
                NotificationViewController *notifVC = [[NotificationViewController alloc] init];
                [homeVC.navigationController pushViewController:notifVC animated:YES];
                break;
            }
            case 1:
            {
                // 点击兴趣
                InterestsViewController *interestVC = [[InterestsViewController alloc] init];
                [homeVC.navigationController pushViewController:interestVC animated:YES];
                break;
            }
            case 2:
            {
                // 打点-点击频道-010407
                [Flurry logEvent:@"Menu_Channels_Click"];
#if DEBUG
                [iConsole info:@"Menu_Channels_Click",nil];
#endif
                // 点击Channels
                ChannelViewController *channelVC = [[ChannelViewController alloc] init];
                [homeVC.navigationController pushViewController:channelVC animated:YES];
                break;
            }
            case 3:
            {
                // 打点-点击收藏-010403
                [Flurry logEvent:@"Info_Icon_Click"];
#if DEBUG
                [iConsole info:@"Info_Icon_Click",nil];
#endif
                // 点击Favorites
                FavoritesViewController *favoritesVC = [[FavoritesViewController alloc] init];
                [homeVC.navigationController pushViewController:favoritesVC animated:YES];
                break;
            }
            case 4:
            {
                // 点击Follow
                NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/1037705142944222"];
                if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
                    [[UIApplication sharedApplication] openURL:facebookURL];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/AgilaBuzz/?fref=ts"]];
                }
                break;
            }
            default:
                break;
        }
    } else {        
        switch (indexPath.row) {
            case 0:
            {
                // 打点-点击反馈-010404
                [Flurry logEvent:@"Menu_FeedbackButton_Click"];
#if DEBUG
                [iConsole info:@"Menu_FeedbackButton_Click",nil];
#endif
                // 点击Feedback
                FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] init];
                [homeVC.navigationController pushViewController:feedbackVC animated:YES];
                break;
            }
            case 1:
            {
                // 打点-点击设置-010406
                [Flurry logEvent:@"Menu_SetButton_Click"];
#if DEBUG
                [iConsole info:@"Menu_SetButton_Click",nil];
#endif
                // 点击Settings
                SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
                [homeVC.navigationController pushViewController:settingsVC animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - 登录头像点击事件
- (void)enterUserInfo
{
    if (_appDelegate.model) {
        // 打点-点击头像-010701
        [Flurry logEvent:@"Info_Icon_Click"];
#if DEBUG
        [iConsole info:@"Info_Icon_Click",nil];
#endif
        LeftView *leftView = (LeftView *)self.superview;
        leftView.isShow = NO;
        JTNavigationController *navCtrl = (JTNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        HomeViewController *homeVC = navCtrl.jt_viewControllers.firstObject;
        
        UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
        userInfoVC.model = _appDelegate.model;
        [homeVC.navigationController pushViewController:userInfoVC animated:YES];
        return;
    }
}
/**
 *  登录按钮点击事件
 *
 *  @param button loginButton
 */
- (void)loginAction:(UIButton *)button
{
    switch (button.tag) {
        case Facebook:
        {
            // 打点-点击facebook-010602
            [Flurry logEvent:@"Login_Facebook_Click"];
#if DEBUG
            [iConsole info:@"Login_Facebook_Click",nil];
#endif
            [SVProgressHUD show];
            button.enabled = NO;
            [ShareSDK getUserInfo:SSDKPlatformTypeFacebook onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
                if (state == SSDKResponseStateSuccess) {
                    // 打点-登陆Facebook成功-010605
                    [Flurry logEvent:@"Login_Facebook_Click_Y"];
#if DEBUG
                    [iConsole info:@"Login_Facebook_Click_Y",nil];
#endif
                    [self loginWithUserData:user LoginType:Facebook];
                    button.enabled = YES;
                } else {
                    // 打点-登陆Facebook失败-010608
                    [Flurry logEvent:@"Login_Facebook_Click_N"];
#if DEBUG
                    [iConsole info:@"Login_Facebook_Click_N",nil];
#endif
                    [SVProgressHUD dismiss];
                    button.enabled = YES;
                    SSLog(@"%@",error);
                }
            }];
            break;
        }
        case Twitter:
        {
            // 打点-点击twitter-010603
            [Flurry logEvent:@"Login_Twitter_Click"];
#if DEBUG
            [iConsole info:@"Login_Twitter_Click",nil];
#endif
            [SVProgressHUD show];
            button.enabled = NO;
            [ShareSDK getUserInfo:SSDKPlatformTypeTwitter onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
                if (state == SSDKResponseStateSuccess) {
                    // 打点-登陆twitter成功-010606
                    [Flurry logEvent:@"Login_Twitter_Click_Y"];
#if DEBUG
                    [iConsole info:@"Login_Twitter_Click_Y",nil];
#endif
                    [self loginWithUserData:user LoginType:Twitter];
                    button.enabled = YES;
                } else {
                    // 打点-登陆twitter失败-010609
                    [Flurry logEvent:@"Login_Twitter_Click_N"];
#if DEBUG
                    [iConsole info:@"Login_Twitter_Click_N",nil];
#endif
                    [SVProgressHUD dismiss];
                    button.enabled = YES;
                    SSLog(@"%@",error);
                }
            }];
            break;
        }
        case GooglePuls:
        {
            // 打点-点击Google＋-010604
            [Flurry logEvent:@"Login_Google_Click"];
#if DEBUG
            [iConsole info:@"Login_Google_Click",nil];
#endif
            button.enabled = NO;
            [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
            [GIDSignIn sharedInstance].scopes = @[@"profile", @"email"];
            [GIDSignIn sharedInstance].delegate = self;
            [GIDSignIn sharedInstance].uiDelegate = self;
            [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;
            [[GIDSignIn sharedInstance] signIn];
            break;
        }
        default:
            break;
    }
}

- (void)loginWithUserData:(SSDKUser *)user LoginType:(int)LoginType
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // 用户第三方账户的id
    [params setValue:user.uid forKey:@"uid"];
    // 用户登录源和邮箱
    switch (LoginType) {
        case Facebook:
            [params setValue:@"facebook" forKey:@"source"];
            [params setValue:user.rawData[@"email"] forKey:@"email"];
            break;
        case Twitter:
            [params setValue:@"twitter" forKey:@"source"];
            break;
        case GooglePuls:
        {
            [params setValue:@"googleplus" forKey:@"source"];
            NSString *email = user.rawData[@"email"];
            [params setValue:email forKey:@"email"];
            break;
        }
        default:
            break;
    }
    // 用户名
    [params setValue:user.nickname forKey:@"name"];
    // 用户性别
    switch (user.gender) {
        case SSDKGenderMale:
            [params setValue:[NSNumber numberWithInt:1] forKey:@"gender"];
            break;
        case SSDKGenderFemale:
            [params setValue:[NSNumber numberWithInt:2] forKey:@"gender"];
            break;
        case SSDKGenderUnknown:
            [params setValue:[NSNumber numberWithInt:0] forKey:@"gender"];
            break;
        default:
            [params setValue:[NSNumber numberWithInt:0] forKey:@"gender"];
            break;
    }
    // 用户头像地址
    [params setValue:user.icon forKey:@"portrait"];
    [SVProgressHUD show];
    [[SSHttpRequest sharedInstance] post:kHomeUrl_Login params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.model = [LoginModel mj_objectWithKeyValues:responseObj];
        NSString *loginFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userinfo.data"];
        [NSKeyedArchiver archiveRootObject:appDelegate.model toFile:loginFilePath];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Login_Success object:nil];
        LeftView *leftView = (LeftView *)self.superview;
        leftView.isShow = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"Successful"];
        });
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    } isShowHUD:YES];
}

#pragma mark - GIDSignInDelegate
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // Perform any operations on signed in user here.
    UIButton *button = [self viewWithTag:GooglePuls];
    button.enabled = YES;
    if (error == nil) {
        // 打点-登陆Google＋成功-010607
        [Flurry logEvent:@"Login_Google_Click_Y"];
#if DEBUG
        [iConsole info:@"Login_Google_Click_Y",nil];
#endif
        SSDKUser *loginUser = [[SSDKUser alloc] init];
        loginUser.uid = user.userID;
        loginUser.rawData = @{@"email":user.profile.email};
        loginUser.nickname = user.profile.name;
        GIDProfileData *profile = user.profile;
        NSString *avatar = [NSString stringWithFormat:@"%@",[profile imageURLWithDimension:0]];
        loginUser.icon = avatar;
        [self loginWithUserData:loginUser LoginType:GooglePuls];
    } else {
        [SVProgressHUD dismiss];
        LeftView *leftView = (LeftView *)self.superview;
        leftView.alpha = 1;
        // 打点-登陆Google＋失败-010610
        [Flurry logEvent:@"Login_Google_Click_N"];
#if DEBUG
        [iConsole info:@"Login_Google_Click_N",nil];
#endif
        SSLog(@"%@",error.localizedDescription);
    }
}

- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error
{
    [SVProgressHUD show];
}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController
{
    [SVProgressHUD dismiss];
    LeftView *leftView = (LeftView *)self.superview;
    leftView.alpha = 0;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController
{
    LeftView *leftView = (LeftView *)self.superview;
    leftView.alpha = 1;
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  登录成功
 */
- (void)loginSuccess
{
    _avatarButton.hidden = NO;
    _loginLabel.text = self.appDelegate.model.name;
    [_avatarButton sd_setImageWithURL:[NSURL URLWithString:_appDelegate.model.portrait] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_sidebar_head"] options:SDWebImageLowPriority | SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [_avatarButton setImage:[image yal_imageWithRoundedCornersAndSize:_avatarButton.frame.size andCornerRadius:_avatarButton.height * .5] forState:UIControlStateNormal];
        } else {
            [_avatarButton setImage:[UIImage imageNamed:@"icon_sidebar_head"] forState:UIControlStateNormal];
        }
    }];
}

/**
 *  退出登录
 */
- (void)userLogOut
{
    _avatarButton.hidden = YES;
    for (int i = 0; i < 3; i++) {
        UIButton *button = [_headerView viewWithTag:200 + i];
        button.hidden = NO;
        switch (i) {
            case 0:
                [button setImage:[UIImage imageNamed:@"icon_login_facebook"] forState:UIControlStateNormal];
                break;
            case 1:
                [button setImage:[UIImage imageNamed:@"icon_login_twitter"] forState:UIControlStateNormal];
                break;
            case 2:
                [button setImage:[UIImage imageNamed:@"icon_login_google"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }
    _loginLabel.text = @"Click to Log in";
}

- (void)addRedPointWithLable:(UILabel *)label Index:(NSInteger)index
{
    NSInteger right = 0;
    switch (index) {
        case 0:
            right = 120;
            break;
        case 1:
            right = 140;
            break;
        default:
            break;
    }
    UIView *redPoint = [[UIView alloc] initWithFrame:CGRectMake(label.right - right, label.top - 10, 5, 5)];
    redPoint.backgroundColor = SSColor(233, 51, 17);
    redPoint.layer.cornerRadius = 2.5;
    redPoint.layer.masksToBounds = YES;
    [label addSubview:redPoint];
}


@end
