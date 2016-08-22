//
//  SettingsViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/7/23.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "SettingsViewController.h"
#import "WebViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Settings";
    self.isBackButton = YES;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = kWhiteBgColor;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.sectionFooterHeight = 0;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        _cacheSize = [NSString stringWithFormat : @"%.2fMB" , [self filePath]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            break;
        default:
            return 2;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    view.backgroundColor = kWhiteBgColor;
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"settingsCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = kBlackColor;
    cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = SSColor(102, 102, 102);
    cell.accessoryView.backgroundColor = [UIColor whiteColor];
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    // cell （0，0）
                    cell.textLabel.text = @"Font Size";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    NSInteger fontSize = [DEF_PERSISTENT_GET_OBJECT(SS_FontSize) integerValue];
                    switch (fontSize) {
                        case Normal:
                            cell.detailTextLabel.text = @"Normal";
                            break;
                        case ExtraLarge:
                            cell.detailTextLabel.text = @"Extra Large";
                            break;
                        case Large:
                            cell.detailTextLabel.text = @"Large";
                            break;
                        case Small:
                            cell.detailTextLabel.text = @"Small";
                            break;
                        default:
                            cell.detailTextLabel.text = @"Normal";
                            break;
                    }
                }
                    break;
                case 1:
                {
                    // cell （0，1）
                    cell.textLabel.text = @"Text-Only Mode";
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [cell.contentView addSubview:self.textOnlySwith];
                    [self.textOnlySwith mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.right.equalTo(cell.contentView.mas_right).offset(-13);
                        make.centerY.equalTo(cell.contentView.mas_centerY);
                    }];
                }
                    break;
                case 2:
                {
                    // cell （0，2）
                    cell.textLabel.text = @"Clear Cache";
                    cell.detailTextLabel.text = _cacheSize;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            switch (indexPath.row) {
                case 0:
                {
                    // cell （1，0）
                    cell.textLabel.text = @"Rate us";
                }
                    break;
                case 1:
                {
                    // cell （1，1）
                    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"v%@",version];
                    cell.textLabel.text = @"Check for Updates";
                }
                    break;
            }
        }
            break;
        case 2:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            switch (indexPath.row) {
                case 0:
                {
                    // cell （2，0）
                    cell.textLabel.text = @"Term of Service";
                }
                    break;
                case 1:
                {
                    // cell （2，1）
                    cell.textLabel.text = @"Privacy Policy";
                }
                    break;
            }
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    // 打点-点击文字设置-010901
                    [Flurry logEvent:@"Set_FontSize_Set"];
#if DEBUG
                    [iConsole info:@"Set_FontSize_Set",nil];
#endif
                    // cell （0，0）
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    // 字体设置弹出提示框
                    [self showFontSizeAlert];
                    break;
                }
                case 2:
                {
                    // 打点-点击清理缓存-010907
                    [Flurry logEvent:@"Set_CacheClean_Click"];
#if DEBUG
                    [iConsole info:@"Set_CacheClean_Click",nil];
#endif
                    // cell （0，2）
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    // 提示清理缓存
                    [self showClearCacheAlert];
                    break;
                }
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            switch (indexPath.row) {
                case 0:
                {
                    // 打点-点击为app评分-010908
                    [Flurry logEvent:@"Set_Score_Click"];
#if DEBUG
                    [iConsole info:@"Set_Score_Click",nil];
#endif
                }
                    break;
                case 1:
                {
                    // 打点-点击版本更新-010909
                    [Flurry logEvent:@"Set_Update_Click"];
#if DEBUG
                    [iConsole info:@"Set_Update_Click",nil];
#endif
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            switch (indexPath.row) {
                case 0:
                {
                    // cell （2，0）
                    WebViewController *webVC = [[WebViewController alloc] initWithWebType:TermOfService];
                    [self.navigationController pushViewController:webVC animated:YES];
                }
                    break;
                case 1:
                {
                    // cell （2，1）
                    WebViewController *webVC = [[WebViewController alloc] initWithWebType:PrivacyPolicy];
                    [self.navigationController pushViewController:webVC animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Alert
/**
 *  字体设置弹出提示框
 */
- (void)showFontSizeAlert
{
    UIAlertController *sheetAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *extraLarge = [UIAlertAction actionWithTitle:@"Extra Large" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 打点-选择字体大小-010902
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"Extra Large", @"text_size",
                                       nil];
        [Flurry logEvent:@"Set_FontSize_Set_Click" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Set_FontSize_Set_Click:%@",articleParams],nil];
#endif
        DEF_PERSISTENT_SET_OBJECT(SS_FontSize, @1);
        [_tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_FontSize_Change object:nil];
    }];
    UIAlertAction *large = [UIAlertAction actionWithTitle:@"Large" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 打点-选择字体大小-010902
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"Large", @"text_size",
                                       nil];
        [Flurry logEvent:@"Set_FontSize_Set_Click" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Set_FontSize_Set_Click:%@",articleParams],nil];
#endif
        DEF_PERSISTENT_SET_OBJECT(SS_FontSize, @2);
        [_tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_FontSize_Change object:nil];
    }];
    UIAlertAction *normal = [UIAlertAction actionWithTitle:@"Normal" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 打点-选择字体大小-010902
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"Normal", @"text_size",
                                       nil];
        [Flurry logEvent:@"Set_FontSize_Set_Click" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Set_FontSize_Set_Click:%@",articleParams],nil];
#endif
        DEF_PERSISTENT_SET_OBJECT(SS_FontSize, @0);
        [_tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_FontSize_Change object:nil];
    }];
    UIAlertAction *small = [UIAlertAction actionWithTitle:@"Small" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 打点-选择字体大小-010902
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"Small", @"text_size",
                                       nil];
        [Flurry logEvent:@"Set_FontSize_Set_Click" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Set_FontSize_Set_Click:%@",articleParams],nil];
#endif
        DEF_PERSISTENT_SET_OBJECT(SS_FontSize, @3);
        [_tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_FontSize_Change object:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [sheetAlert addAction:extraLarge];
    [sheetAlert addAction:large];
    [sheetAlert addAction:normal];
    [sheetAlert addAction:small];
    [sheetAlert addAction:cancel];
    [self presentViewController:sheetAlert animated:YES completion:nil];
}

/**
 *  清除缓存弹出提示框
 */
- (void)showClearCacheAlert
{
    NSString *title = @" \nClear all the caches?\n ";
    UIAlertController *clearAlert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:title];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:kBlackColor range:NSMakeRange(0, title.length)];
    [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, title.length)];
    if ([clearAlert valueForKey:@"attributedTitle"]) {
        [clearAlert setValue:alertControllerStr forKey:@"attributedTitle"];
    }

    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 点击确定清除
        [self clearLocalCache];
    }];

    [clearAlert addAction:noAction];
    [clearAlert addAction:yesAction];
    [self presentViewController:clearAlert animated:YES completion:nil];
}

- (void)backAction:(UIButton *)button
{
    // 打点-点击设置页面返回按钮-010910
    [Flurry logEvent:@"Set_BackButton_Click"];
#if DEBUG
    [iConsole info:@"Set_BackButton_Click",nil];
#endif
    [super backAction:button];
}

#pragma mark - setter/getter
- (UISwitch *)textOnlySwith
{
    if (_textOnlySwith == nil) {
        _textOnlySwith = [[UISwitch alloc] init];
        _textOnlySwith.backgroundColor = [UIColor whiteColor];
        [_textOnlySwith addTarget:self action:@selector(switchStateChanges:) forControlEvents:UIControlEventValueChanged];
        if ([DEF_PERSISTENT_GET_OBJECT(SS_textOnlyMode) isEqualToNumber:@1]) {
            [_textOnlySwith setOn:YES];
        } else {
            [_textOnlySwith setOn:NO];
        }
    }
    return _textOnlySwith;
}

- (void)switchStateChanges:(UISwitch *)rightSwitch
{
    if (rightSwitch.isOn) {
        // 打点-打开低流量模式-010905
        [Flurry logEvent:@"Set_LowData_Open"];
#if DEBUG
        [iConsole info:@"Set_LowData_Open",nil];
#endif
        DEF_PERSISTENT_SET_OBJECT(SS_textOnlyMode, @1);
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_TextOnly_ON object:nil];
    }else{
        // 打点-关闭低流量模式-010906
        [Flurry logEvent:@"Set_LowData_Close"];
#if DEBUG
        [iConsole info:@"Set_LowData_Close",nil];
#endif
        DEF_PERSISTENT_SET_OBJECT(SS_textOnlyMode, @0);
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_TextOnly_OFF object:nil];
    }

}

- (void)setCacheSize:(NSString *)cacheSize
{
    if (_cacheSize != cacheSize) {
        _cacheSize = cacheSize;
        
        [_tableView reloadData];
    }
}

#pragma mark - 计算缓存文件大小
// 计算缓存文件大小
- (long long)fileSizeAtPath:(NSString *)filePath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0 ;
}
// 遍历文件夹获得文件夹大小，返回多少 M
- (float)folderSizeAtPath:(NSString *)folderPath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0 ;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString *fileName;
    long long folderSize = 0 ;
    while ((fileName = [childFilesEnumerator nextObject]) != nil)
    {
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize / (1024.0 * 1024.0);
}
// 显示缓存大小
- (float)filePath
{
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    return [self folderSizeAtPath:cachPath];
}

#pragma mark - 清理缓存
- (void)clearLocalCache
{
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSArray * filesArray = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
    for (NSString *branchPath in filesArray)
    {
        @autoreleasepool {
            NSError * error = nil ;
            NSString * path = [cachPath stringByAppendingPathComponent:branchPath];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path])
            {
                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            }
        }
    }
    [self performSelectorOnMainThread:@selector(clearCachSuccess) withObject:nil waitUntilDone:YES ];
}
/**
 *  清理缓存后刷新列表
 */
- (void)clearCachSuccess
{
    self.cacheSize = [NSString stringWithFormat : @"%.2fMB" , [self filePath]];
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
