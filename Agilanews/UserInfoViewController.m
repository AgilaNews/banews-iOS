//
//  UserInfoViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/7/21.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "UserInfoViewController.h"
#import "AppDelegate.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = kWhiteBgColor;
    self.title = @"User info";
    self.isBackButton = YES;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = kWhiteBgColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = SSColor(235, 235, 235);
    _tableView.sectionHeaderHeight = 0;
    _tableView.sectionFooterHeight = 0;
    
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutButton.frame = CGRectMake(0, 0, kScreenWidth, 44);
    logoutButton.backgroundColor = [UIColor whiteColor];
    [logoutButton setBackgroundColor:SSColor(235, 235, 235) forState:UIControlStateHighlighted];
    [logoutButton setTitle:@"LOG OUT" forState:UIControlStateNormal];
    [logoutButton setTitleColor:kOrangeColor forState:UIControlStateNormal];
    logoutButton.titleLabel.font = [UIFont systemFontOfSize:16];
    logoutButton.titleLabel.backgroundColor = [UIColor whiteColor];
    [logoutButton addTarget:self action:@selector(logOutAction) forControlEvents:UIControlEventTouchUpInside];
    _tableView.tableFooterView = logoutButton;
    [self.view addSubview:_tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        default:
            return 1;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 79;
            break;
        default:
            return 44;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            return 10;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"userInfoCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = kBlackColor;
    switch (indexPath.section) {
        case 0:
        {
            cell.textLabel.text = @"Profile Picture";
            UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 13 - 57, 11, 57, 57)];
            [avatarView sd_setImageWithURL:[NSURL URLWithString:_model.portrait] placeholderImage:[UIImage imageNamed:@"icon_sidebar_head"] options:SDWebImageLowPriority | SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image)
                {
                    avatarView.image = [avatarView.image yal_imageWithRoundedCornersAndSize:avatarView.frame.size andCornerRadius:avatarView.height * 0.5];
                } else
                {
                    avatarView.image = [UIImage imageNamed:@"icon_sidebar_head"];
                }
            }];
            [cell.contentView addSubview:avatarView];
        }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = @"Name";
                    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
                    cell.detailTextLabel.textColor = SSColor(102, 102, 102);
                    cell.detailTextLabel.text = _model.name;
                }
                    break;
                case 1:
                {
                    cell.textLabel.text = @"Gender";
                    UIImageView *genderView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 13 - 19, 12, 19, 20)];
                    //0未知，1男，2女
                    switch ([_model.gender intValue]) {
                        case 0:
                            genderView.image = [UIImage imageNamed:@"icon_info_secrecy"];
                            break;
                        case 1:
                            genderView.image = [UIImage imageNamed:@"icon_info_male"];
                            break;
                        case 2:
                            genderView.image = [UIImage imageNamed:@"icon_info_female"];
                            break;
                        default:
                            break;
                    }
                    [cell.contentView addSubview:genderView];
                }
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - logout点击事件
- (void)logOutAction
{
    // 打点-点击logout-010702
    [Flurry logEvent:@"Info_Logout_Click"];
    NSString *title = @"Logout Confirmation";
    NSString *message = @"If you log out, you will not be able to post comments, are you sure to exit?";
    UIAlertController *logoutAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:title];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:kBlackColor range:NSMakeRange(0, title.length)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, title.length)];
    [logoutAlert setValue:alertControllerStr forKey:@"attributedTitle"];
    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:message];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:SSColor(102, 102, 102) range:NSMakeRange(0, message.length)];
    [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, message.length)];
    [logoutAlert setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 打点-logout成功-010703
        [Flurry logEvent:@"Info_Logout_Click_Y"];
        // 点击确定退出
        [FBSDKAccessToken setCurrentAccessToken:nil];
        [FBSDKProfile setCurrentProfile:nil];
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        [manager logOut];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userinfo.data"];
        [fileManager removeItemAtPath:documentsDirectory error:&error];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.model = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Logout_Success object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [logoutAlert addAction:noAction];
    [logoutAlert addAction:yesAction];
    [self presentViewController:logoutAlert animated:YES completion:nil];
}

- (void)backAction:(UIButton *)button
{
    // 打点-点击用户信息页返回按钮-010704
    [Flurry logEvent:@"Info_BackButton_Click"];
    [super backAction:button];
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
