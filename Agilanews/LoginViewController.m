//
//  LoginViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/7/20.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginButton.h"
#import "AppDelegate.h"
#import "LoginModel.h"
#import "FavoritesViewController.h"

#define Facebook   200
#define Twitter    201
#define GooglePuls 202

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kWhiteBgColor;
    self.title = @"Log in";
    if (_isCollect || _isComment || _isShareFacebook || _isShareTwitter || _isShareGoogle) {
        self.isDismissButton = YES;
    } else {
        self.isBackButton = YES;
    }
    [GIDSignIn sharedInstance].clientID = @"220913118121-tsfqho6sgkbh2frs2k8h3kludcnnunf1.apps.googleusercontent.com";
    [GIDSignIn sharedInstance].scopes = @[@"profile", @"email"];
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;
    // 登录头像上边距
    float height = iPhone4 ? (kScreenHeight - 64 - 75 - 50 - 40 - 44 * 3) * .5 : 77 * kScreenHeight / 568;
    _titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 75) * .5, height + 64, 75, 75)];
    _titleImageView.backgroundColor = self.view.backgroundColor;
    _titleImageView.image = [UIImage imageNamed:@"icon_sidebar_head"];
    _titleImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_titleImageView];
    
    for (int i = 0; i < 3; i++) {
        LoginButton *loginButton = [LoginButton buttonWithType:UIButtonTypeCustom];
        loginButton.frame = CGRectMake(30, _titleImageView.bottom + 50 + 64 * i, kScreenWidth - 60, 44);
        loginButton.tag = 200 + i;
        [loginButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:loginButton];
        switch (i) {
            case 0:
                loginButton.loginType = FacebookType;
                break;
            case 1:
                loginButton.loginType = TwitterType;
                break;
            case 2:
                loginButton.loginType = GooglePulsType;
                break;
            default:
                break;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 打点-页面进入-010601
    [Flurry logEvent:@"Login_Enter"];
#if DEBUG
    [iConsole info:@"Login_Enter",nil];
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
            [ShareSDK getUserInfo:SSDKPlatformTypeFacebook onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
                if (state == SSDKResponseStateSuccess) {
                    // 打点-登陆Facebook成功-010605
                    [Flurry logEvent:@"Login_Facebook_Click_Y"];
#if DEBUG
                    [iConsole info:@"Login_Facebook_Click_Y",nil];
#endif
                    [self loginWithUserData:user LoginType:Facebook];
                } else {
                    // 打点-登陆Facebook失败-010608
                    [Flurry logEvent:@"Login_Facebook_Click_N"];
#if DEBUG
                    [iConsole info:@"Login_Facebook_Click_N",nil];
#endif
                    SSLog(@"%@",error);
                }
            }];
        }
            break;
        case Twitter:
        {
            // 打点-点击twitter-010603
            [Flurry logEvent:@"Login_Twitter_Click"];
#if DEBUG
            [iConsole info:@"Login_Twitter_Click",nil];
#endif
            [ShareSDK getUserInfo:SSDKPlatformTypeTwitter onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
                if (state == SSDKResponseStateSuccess) {
                    // 打点-登陆twitter成功-010606
                    [Flurry logEvent:@"Login_Twitter_Click_Y"];
#if DEBUG
                    [iConsole info:@"Login_Twitter_Click_Y",nil];
#endif
                    [self loginWithUserData:user LoginType:Twitter];
                } else {
                    // 打点-登陆twitter失败-010609
                    [Flurry logEvent:@"Login_Twitter_Click_N"];
#if DEBUG
                    [iConsole info:@"Login_Twitter_Click_N",nil];
#endif
                    SSLog(@"%@",error);
                }
            }];
        }
            break;
        case GooglePuls:
        {
            // 打点-点击Google＋-010604
            [Flurry logEvent:@"Login_Google_Click"];
#if DEBUG
            [iConsole info:@"Login_Google_Click",nil];
#endif
            [[GIDSignIn sharedInstance] signIn];
//            [ShareSDK getUserInfo:SSDKPlatformTypeGooglePlus onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
//                if (state == SSDKResponseStateSuccess) {
//                    // 打点-登陆Google＋成功-010607
//                    [Flurry logEvent:@"Login_Google_Click_Y"];
//#if DEBUG
//                    [iConsole info:@"Login_Google_Click_Y",nil];
//#endif
//                    [self loginWithUserData:user LoginType:GooglePuls];
//                } else {
//                    // 打点-登陆Google＋失败-010610
//                    [Flurry logEvent:@"Login_Google_Click_N"];
//#if DEBUG
//                    [iConsole info:@"Login_Google_Click_N",nil];
//#endif
//                    SSLog(@"%@",error);
//                }
//            }];
        }
            break;
            
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
            break;
        case Twitter:
            [params setValue:@"twitter" forKey:@"source"];
            break;
        case GooglePuls:
        {
            [params setValue:@"googleplus" forKey:@"source"];
//            NSString *email = user.rawData[@"emails"][0][@"value"];
            NSString *email = user.rawData[@"email"];
            [params setValue:email forKey:@"email"];
        }
            break;
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
        [SVProgressHUD showSuccessWithStatus:@"Successful"];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.model = [LoginModel mj_objectWithKeyValues:responseObj];
        NSString *loginFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userinfo.data"];
        [NSKeyedArchiver archiveRootObject:appDelegate.model toFile:loginFilePath];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Login_Success object:[NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithBool:_isCollect], @"isCollect",
                    [NSNumber numberWithBool:_isComment], @"isComment",
                    [NSNumber numberWithBool:_isShareFacebook], @"isShareFacebook",
                    [NSNumber numberWithBool:_isShareTwitter], @"isShareTwitter",
                    [NSNumber numberWithBool:_isShareGoogle], @"isShareGoogle",
                    nil]];
        if (_isFavorite) {
            FavoritesViewController *favoritesVC = [[FavoritesViewController alloc] init];
            [weakSelf.navigationController pushViewController:favoritesVC animated:YES];
        } else if (_isCollect || _isComment || _isShareFacebook || _isShareTwitter || _isShareGoogle) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        } else {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    } isShowHUD:YES];
}

#pragma mark - 按钮点击事件
- (void)backAction:(UIButton *)button
{
    // 打点-点击返回-010611
    [Flurry logEvent:@"Login_BackButton_Click"];
#if DEBUG
    [iConsole info:@"Login_BackButton_Click",nil];
#endif
    [super backAction:button];
}

- (void)closeAction:(UIButton *)button
{
    // 打点-点击返回-010611
    [Flurry logEvent:@"Login_BackButton_Click"];
#if DEBUG
    [iConsole info:@"Login_BackButton_Click",nil];
#endif
    [super closeAction:button];
}


- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // Perform any operations on signed in user here.
//    NSString *userId = user.userID;                  // For client-side use only!
//    NSString *idToken = user.authentication.idToken; // Safe to send to the server
//    NSString *fullName = user.profile.name;
//    NSString *givenName = user.profile.givenName;
//    NSString *familyName = user.profile.familyName;
//    NSString *email = user.profile.email;
    // ...
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
        // 打点-登陆Google＋失败-010610
        [Flurry logEvent:@"Login_Google_Click_N"];
#if DEBUG
        [iConsole info:@"Login_Google_Click_N",nil];
#endif
        SSLog(@"%@",error);
    }
}

- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error
{
//    NSLog(@"%@",signIn);
}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController
{
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options
{
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
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
