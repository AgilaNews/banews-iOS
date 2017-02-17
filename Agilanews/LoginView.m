//
//  LoginView.m
//  Agilanews
//
//  Created by 张思思 on 16/12/14.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "LoginView.h"
#import "AppDelegate.h"
#import "FavoritesViewController.h"

#define Facebook   200
#define Twitter    201
#define GooglePuls 202

@implementation LoginView

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
        self.alpha = 0;
        // 点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeAction)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
        [GIDSignIn sharedInstance].scopes = @[@"profile", @"email"];
        [GIDSignIn sharedInstance].delegate = self;
        [GIDSignIn sharedInstance].uiDelegate = self;
        [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;
        
        // 背景视图
        _bgView = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth - 270) * .5, (kScreenHeight - 181) * .5, 270, 181)];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 4;
        _bgView.layer.masksToBounds = YES;
        [self addSubview:_bgView];
        
        // 标题
        NSString *titleText = @"Log in";
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont boldSystemFontOfSize:13];
        titleLabel.textColor = kBlackColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = titleText;
        CGSize titleSize = [titleText calculateSize:CGSizeMake(200, 12) font:titleLabel.font];
        titleLabel.frame = CGRectMake((_bgView.width - titleSize.width) *.5, 12, titleSize.width, titleSize.height);
        [_bgView addSubview:titleLabel];
        // 横线
        for (int i = 0; i < 2; i++) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 43, 1)];
            lineView.backgroundColor = SSColor_RGB(178);
            if (i == 0) {
                lineView.right = titleLabel.left - 15;
            } else {
                lineView.left = titleLabel.right + 15;
            }
            lineView.center = CGPointMake(lineView.center.x, titleLabel.center.y);
            [_bgView addSubview:lineView];
        }
        
        // 登录按钮
        for (int i = 0; i < 3; i++) {
            // 按钮
            UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
            loginButton.frame = CGRectMake(25 + (50 + 36) * i, titleLabel.bottom + 18, 50, 50);
            loginButton.tag = 200 + i;
            [loginButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
            [_bgView addSubview:loginButton];
            NSString *loginText = nil;
            switch (i) {
                case 0:
                    [loginButton setImage:[UIImage imageNamed:@"icon_login_facebook"] forState:UIControlStateNormal];
                    loginText = @"Facebook";
                    break;
                case 1:
                    [loginButton setImage:[UIImage imageNamed:@"icon_login_twitter"] forState:UIControlStateNormal];
                    loginText = @"Twitter";
                    break;
                case 2:
                    [loginButton setImage:[UIImage imageNamed:@"icon_login_google"] forState:UIControlStateNormal];
                    loginText = @"Google+";
                    break;
                default:
                    break;
            }
            // 文字
            CGSize loginSize = [loginText calculateSize:CGSizeMake(100, 15) font:[UIFont systemFontOfSize:14]];
            UILabel *loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, loginButton.bottom + 12, loginSize.width, loginSize.height)];
            loginLabel.center = CGPointMake(loginButton.center.x, loginLabel.center.y);
            loginLabel.textAlignment = NSTextAlignmentCenter;
            loginLabel.font = [UIFont systemFontOfSize:14];
            loginLabel.textColor = SSColor_RGB(102);
            loginLabel.text = loginText;
            [_bgView addSubview:loginLabel];
            
            // 取消按钮
            UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            cancelButton.frame = CGRectMake(0, _bgView.height - 45, _bgView.width, 45);
            cancelButton.adjustsImageWhenHighlighted = NO;
            [cancelButton setBackgroundColor:SSColor_RGB(246) forState:UIControlStateNormal];
            [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
            [cancelButton setTitleColor:SSColor_RGB(178) forState:UIControlStateNormal];
            [cancelButton addTarget:self action:@selector(removeAction) forControlEvents:UIControlEventTouchUpInside];
            [_bgView addSubview:cancelButton];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 1;
    }];
    // 打点-页面进入-010601
    [Flurry logEvent:@"Login_Enter"];
}

- (void)removeAction
{
    [SVProgressHUD dismiss];
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.bgView]) {
        return NO;
    }
    return YES;
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
            [SVProgressHUD show];
            button.enabled = NO;
            __weak typeof(self) weakSelf = self;
            if ([FBSDKAccessToken currentAccessToken]) {
                FBSDKGraphRequest *requset = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, gender, picture.type(large), email, cover, friends"}];
                [requset startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    [SVProgressHUD dismiss];
                    if (!error) {
                        // 打点-登陆Facebook成功-010605
                        [Flurry logEvent:@"Login_Facebook_Click_Y"];
                        SSDKUser *userInfo = [[SSDKUser alloc] init];
                        userInfo.uid = result[@"id"];
                        userInfo.rawData = @{@"email" : result[@"email"],
                                             };
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
                [manager logInWithReadPermissions:@[@"public_profile", @"email"] fromViewController:self.ViewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                    [SVProgressHUD dismiss];
                    if (!error && !result.isCancelled) {
                        [SVProgressHUD show];
                        FBSDKGraphRequest *requset = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, gender, picture.type(large), email, cover, friends"}];
                        [requset startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                            [SVProgressHUD dismiss];
                            if (!error) {
                                // 打点-登陆Facebook成功-010605
                                [Flurry logEvent:@"Login_Facebook_Click_Y"];
                                SSDKUser *userInfo = [[SSDKUser alloc] init];
                                userInfo.uid = result[@"id"];
                                userInfo.rawData = @{@"email" : result[@"email"],
                                                     };
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
            [[GIDSignIn sharedInstance] signIn];
            break;
        }
        default:
            break;
    }
}

- (void)loginWithUserData:(SSDKUser *)user LoginType:(int)LoginType
{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // 用户第三方账户的id
    [params setValue:user.uid forKey:@"uid"];
    // 用户登录源和邮箱
    switch (LoginType) {
        case Facebook:
            [params setValue:@"facebook" forKey:@"source"];
            [params setValue:user.rawData[@"email"] forKey:@"email"];
            if ([FBSDKAccessToken currentAccessToken]) {
                [params setValue:[FBSDKAccessToken currentAccessToken] forKey:@""];
            }
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
        [weakSelf removeAction];
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
    //    NSString *userId = user.userID;                  // For client-side use only!
    //    NSString *idToken = user.authentication.idToken; // Safe to send to the server
    //    NSString *fullName = user.profile.name;
    //    NSString *givenName = user.profile.givenName;
    //    NSString *familyName = user.profile.familyName;
    //    NSString *email = user.profile.email;
    // ...
    UIButton *button = [self viewWithTag:GooglePuls];
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
        self.alpha = 1;
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
    self.alpha = 0;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController
{
    self.alpha = 1;
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
