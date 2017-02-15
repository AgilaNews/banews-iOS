//
//  MeViewController.m
//  Agilanews
//
//  Created by 张思思 on 17/1/23.
//  Copyright © 2017年 banews. All rights reserved.
//

#import "MeViewController.h"
#import "UIButton+WebCache.h"
#import "LeftCell.h"
#import "UserInfoViewController.h"
#import "SettingsViewController.h"
#import "FavoritesViewController.h"
#import "FeedbackViewController.h"
#import "ChannelViewController.h"
#import "NotificationViewController.h"
#import "InterestsViewController.h"

#define Facebook   200
#define Twitter    201
#define GooglePuls 202

#define SectionHeaderHeight 8
#define RowHeight 48

@interface MeViewController ()

@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        NSArray *list = self.navigationController.navigationBar.subviews;
        for (id obj in list) {
            if ([UIDevice currentDevice].systemVersion.integerValue >= 10) {
                UIView *view = (UIView *)obj;
                for (id obj2 in view.subviews) {
                    if ([obj2 isKindOfClass:[UIImageView class]]) {
                        UIImageView *image = (UIImageView *)obj2;
                        image.hidden = YES;
                    }
                }
            }
        }
    }
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.view.backgroundColor = kWhiteBgColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 49) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 45, 0, 0);
    [self.view addSubview:_tableView];
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 190 * kScreenHeight / 568.0)];
    _headerView.backgroundColor = kOrangeColor;
    
    _avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _avatarButton.frame = CGRectMake((kScreenWidth - 80) * .5, (_headerView.height - 10 - 20 - 80) * .5 + 13, 80, 80);
    _avatarButton.layer.cornerRadius = 80 * .5;
    _avatarButton.layer.borderColor = SSColor(255, 189, 113).CGColor;
    _avatarButton.layer.borderWidth = 1;
    _avatarButton.layer.masksToBounds = YES;
    [_avatarButton addTarget:self action:@selector(enterUserInfo) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:_avatarButton];
    
    for (int i = 0; i < 3; i++) {
        float leftSide = (kScreenWidth - 60 * 3 - 37 * 2) * .5;
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        loginButton.frame = CGRectMake(leftSide + (60 + 37) * i, (_headerView.height - 25 - 20 - 60) * .5 + 13, 60, 60);
        loginButton.tag = 200 + i;
        [loginButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:loginButton];
        switch (i) {
            case 0:
                [loginButton setImage:[UIImage imageNamed:@"icon_facebook_white"] forState:UIControlStateNormal];
                break;
            case 1:
                [loginButton setImage:[UIImage imageNamed:@"icon_twitter_white"] forState:UIControlStateNormal];
                break;
            case 2:
                [loginButton setImage:[UIImage imageNamed:@"icon_google_white"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }
    _loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (_headerView.height - 25 - 20 - 60) * .5 + 60 + 25 + 13, kScreenWidth, 20)];
    _loginLabel.backgroundColor = kOrangeColor;
    _loginLabel.font = [UIFont boldSystemFontOfSize:18];
    _loginLabel.textColor = [UIColor whiteColor];
    _loginLabel.textAlignment = NSTextAlignmentCenter;
    [_headerView addSubview:_loginLabel];
#if DEBUG
    _loginLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapLogin = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autoLogin)];
    tapLogin.numberOfTapsRequired = 5;
//    tapLogin.numberOfTouchesRequired = 2;
    [_loginLabel addGestureRecognizer:tapLogin];
#endif
    
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
                    [button setImage:[UIImage imageNamed:@"icon_facebook_white"] forState:UIControlStateNormal];
                    break;
                case 1:
                    [button setImage:[UIImage imageNamed:@"icon_twitter_white"] forState:UIControlStateNormal];
                    break;
                case 2:
                    [button setImage:[UIImage imageNamed:@"icon_google_white"] forState:UIControlStateNormal];
                    break;
                default:
                    break;
            }
        }
        _avatarButton.hidden = YES;
        _loginLabel.text = @"Click to Log in";
    }
    _tableView.tableHeaderView = _headerView;
    float footerViewHeight = 0;
    if (iPhone4) {
        footerViewHeight = 8;
    } else {
        footerViewHeight = kScreenHeight - 49 - _headerView.height - RowHeight * 7 - SectionHeaderHeight;
    }
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, footerViewHeight)];
    footerView.backgroundColor = [UIColor whiteColor];
    _tableView.tableFooterView = footerView;
    
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:KNOTIFICATION_Login_Success object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogOut) name:KNOTIFICATION_Logout_Success object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor clearColor]];
        UIView *barBgView = self.navigationController.navigationBar.subviews.firstObject;
        for (UIView *subview in barBgView.subviews) {
            if([subview isKindOfClass:[UIVisualEffectView class]]) {
                subview.backgroundColor = [UIColor clearColor];
                [subview removeAllSubviews];
            }
        }
    } else {
        [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    }
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor clearColor]];
        UIView *barBgView = self.navigationController.navigationBar.subviews.firstObject;
        for (UIView *subview in barBgView.subviews) {
            if([subview isKindOfClass:[UIVisualEffectView class]]) {
                subview.backgroundColor = [UIColor clearColor];
                [subview removeAllSubviews];
            }
        }
    }
}

- (void)dealloc
{
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 2;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SectionHeaderHeight;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return SectionHeaderHeight;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, SectionHeaderHeight)];
    view.backgroundColor = SSColor_RGB(238);
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
//    lineView.backgroundColor = SSColor_RGB(217);
//    [view addSubview:lineView];
    return view;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, SectionHeaderHeight)];
//    view.backgroundColor = SSColor_RGB(238);
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return RowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LeftCell *cell = [[LeftCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"leftCell" HaveImage:YES];
    switch (indexPath.row) {
        case 0:
            cell.titleImageView.image = [UIImage imageNamed:@"icon_notification"];
            cell.titleLabel.text = @"Notification";
            if ([DEF_PERSISTENT_GET_OBJECT(kHaveNewNotif) isEqual:@1]) {
                [self addRedPointWithLable:cell.titleLabel Index:indexPath.row];
            } else {
                [cell.titleLabel removeAllSubviews];
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
            } else {
                [cell.titleLabel removeAllSubviews];
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
        case 5:
            cell.titleImageView.image = [UIImage imageNamed:@"icon_sidebar_feedback"];
            cell.titleLabel.text = @"Feedback";
            break;
        case 6:
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
    switch (indexPath.row) {
        case 0:
        {
            // 打点-点击通知按钮-010409
            [Flurry logEvent:@"Menu_Notification_Click"];
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
            notifVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:notifVC animated:YES];
            break;
        }
        case 1:
        {
            // 点击兴趣
            InterestsViewController *interestVC = [[InterestsViewController alloc] init];
            interestVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:interestVC animated:YES];
            break;
        }
        case 2:
        {
            // 打点-点击频道-010407
            [Flurry logEvent:@"Menu_Channels_Click"];
            // 点击Channels
            ChannelViewController *channelVC = [[ChannelViewController alloc] init];
            channelVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:channelVC animated:YES];
            break;
        }
        case 3:
        {
            // 打点-点击收藏-010403
            [Flurry logEvent:@"Info_Icon_Click"];
            // 点击Favorites
            FavoritesViewController *favoritesVC = [[FavoritesViewController alloc] init];
            favoritesVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:favoritesVC animated:YES];
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
        case 5:
        {
            // 打点-点击反馈-010404
            [Flurry logEvent:@"Menu_FeedbackButton_Click"];
            // 点击Feedback
            FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] init];
            feedbackVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:feedbackVC animated:YES];
            break;
        }
        case 6:
        {
            // 打点-点击设置-010406
            [Flurry logEvent:@"Menu_SetButton_Click"];
            // 点击Settings
            SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
            settingsVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:settingsVC animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        self.tableView.backgroundColor = kOrangeColor;
    } else {
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - 点击事件
- (void)enterUserInfo
{
    if (_appDelegate.model) {
        // 打点-点击头像-010701
        [Flurry logEvent:@"Info_Icon_Click"];
        UIViewController *viewCtrl = (JTNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        if ([viewCtrl isKindOfClass:[UITabBarController class]]) {
            UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
            userInfoVC.model = _appDelegate.model;
            userInfoVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:userInfoVC animated:YES];
            return;
        }
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
            button.enabled = NO;
            __weak typeof(self) weakSelf = self;
            if ([FBSDKAccessToken currentAccessToken]) {
                FBSDKGraphRequest *requset = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, gender, picture.type(large), email, cover"}];
                [requset startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    [SVProgressHUD dismiss];
                    if (!error) {
                        // 打点-登陆Facebook成功-010605
                        [Flurry logEvent:@"Login_Facebook_Click_Y"];
                        SSDKUser *userInfo = [[SSDKUser alloc] init];
                        userInfo.uid = result[@"id"];
                        userInfo.rawData = @{@"email" : result[@"email"]};
                        userInfo.nickname = result[@"name"];
                        NSString *gender = result[@"gender"];
                        if ([gender isEqualToString:@"female"]) {
                            userInfo.gender = SSDKGenderFemale;
                        } else if ([gender isEqualToString:@"male"]) {
                            userInfo.gender = SSDKGenderMale;
                        } else {
                            userInfo.gender = SSDKGenderUnknown;
                        }
                        userInfo.icon = result[@"picture"][@"data"][@"url"];
                        [weakSelf loginWithUserData:userInfo LoginType:Facebook];
                        button.enabled = YES;
                    } else {
                        // 打点-登陆Facebook失败-010608
                        [Flurry logEvent:@"Login_Facebook_Click_N"];
                        [SVProgressHUD dismiss];
                        button.enabled = YES;
                        SSLog(@"%@",error);
                    }
                }];
            } else {
                FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
                manager.defaultAudience = FBSDKDefaultAudienceEveryone;
                manager.loginBehavior = FBSDKLoginBehaviorNative;
                [manager logInWithReadPermissions:@[@"public_profile", @"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                    [SVProgressHUD dismiss];
                    if (!error && !result.isCancelled) {
                        [SVProgressHUD show];
                        FBSDKGraphRequest *requset = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, gender, picture.type(large), email, cover"}];
                        [requset startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                            [SVProgressHUD dismiss];
                            if (!error) {
                                // 打点-登陆Facebook成功-010605
                                [Flurry logEvent:@"Login_Facebook_Click_Y"];
                                SSDKUser *userInfo = [[SSDKUser alloc] init];
                                userInfo.uid = result[@"id"];
                                userInfo.rawData = @{@"email" : result[@"email"]};
                                userInfo.nickname = result[@"name"];
                                NSString *gender = result[@"gender"];
                                if ([gender isEqualToString:@"female"]) {
                                    userInfo.gender = SSDKGenderFemale;
                                } else if ([gender isEqualToString:@"male"]) {
                                    userInfo.gender = SSDKGenderMale;
                                } else {
                                    userInfo.gender = SSDKGenderUnknown;
                                }
                                userInfo.icon = result[@"picture"][@"data"][@"url"];
                                [weakSelf loginWithUserData:userInfo LoginType:Facebook];
                                button.enabled = YES;
                            } else {
                                // 打点-登陆Facebook失败-010608
                                [Flurry logEvent:@"Login_Facebook_Click_N"];
                                [SVProgressHUD dismiss];
                                button.enabled = YES;
                                SSLog(@"%@",error);
                            }
                        }];
                    } else {
                        button.enabled = YES;
                    }
                }];
            }
            break;
        }
        case Twitter:
        {
            // 打点-点击twitter-010603
            [Flurry logEvent:@"Login_Twitter_Click"];
            [SVProgressHUD show];
            button.enabled = NO;
            [ShareSDK getUserInfo:SSDKPlatformTypeTwitter onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
                if (state == SSDKResponseStateSuccess) {
                    // 打点-登陆twitter成功-010606
                    [Flurry logEvent:@"Login_Twitter_Click_Y"];
                    user.icon = [user.icon stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
                    [self loginWithUserData:user LoginType:Twitter];
                    button.enabled = YES;
                } else {
                    // 打点-登陆twitter失败-010609
                    [Flurry logEvent:@"Login_Twitter_Click_N"];
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"Successful"];
        });
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    } isShowHUD:YES];
}

- (void)autoLogin
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    LoginModel *model = [[LoginModel alloc] init];
    model.user_id = @"57a6f7ff2016dff95ec3a4cb8f7cedba86280587";
    model.name = @"Sisi Zhang";
    model.gender = @1;
    model.portrait = @"https://fb-s-b-a.akamaihd.net/h-ak-xfa1/v/t1.0-1/c15.0.50.50/p50x50/10354686_10150004552801856_220367501106153455_n.jpg?oh=0bb129c4bacce2fd26d99c098ed48ce3&oe=5938E12F&__gda__=1497377938_82d2c1baf61feaae03debc75ad5146f4";
    model.email = @"zss232010@gmail.com";
    model.create_time = @1481773390;
    model.source = @"facebook";
    appDelegate.model = model;
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Login_Success object:nil];
    [SVProgressHUD showSuccessWithStatus:@"Successful"];
}

#pragma mark - GIDSignInDelegate
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // Perform any operations on signed in user here.
    UIButton *button = [self.view viewWithTag:GooglePuls];
    button.enabled = YES;
    if (error == nil) {
        // 打点-登陆Google＋成功-010607
        [Flurry logEvent:@"Login_Google_Click_Y"];
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
        // 打点-登陆Google＋失败-010610
        [Flurry logEvent:@"Login_Google_Click_N"];
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
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController
{
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  登录成功
 */
- (void)loginSuccess
{
    for (int i = 0; i < 3; i++) {
        UIButton *button = [_headerView viewWithTag:200 + i];
        button.hidden = YES;
    }
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
//    NSInteger right = 0;
//    switch (index) {
//        case 0:
//            right = 120;
//            break;
//        case 1:
//            right = 140;
//            break;
//        default:
//            break;
//    }
    UIView *redPoint = [[UIView alloc] initWithFrame:CGRectMake(label.width + 5, label.height * .5 - 5 * .5, 5, 5)];
    redPoint.backgroundColor = SSColor(233, 51, 17);
    redPoint.layer.cornerRadius = 2.5;
    redPoint.layer.masksToBounds = YES;
    [label addSubview:redPoint];
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
