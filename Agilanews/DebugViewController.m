//
//  DebugViewController.m
//  Agilanews
//
//  Created by 张思思 on 17/2/13.
//  Copyright © 2017年 banews. All rights reserved.
//

#import "DebugViewController.h"

@interface DebugViewController ()

@end

@implementation DebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Debug";
    self.isBackButton = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 64 + 20, kScreenWidth - 100, 20)];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"选择请求地址";
    [self.view addSubview:titleLabel];
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(50, titleLabel.bottom, kScreenWidth - 100, 216)];
    // 显示选中框
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    [self.view addSubview:pickerView];
    
    _apiArray = @[@"api",@"api1",@"api2",@"api3",@"api4",@"api5",@"api6",@"api7",@"api8",@"api9"];

    
}

#pragma Mark -- UIPickerViewDataSource
// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _apiArray.count;
}

#pragma Mark -- UIPickerViewDelegate
// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 200;
}

//返回当前行的内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_apiArray objectAtIndex:row];
}

// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *apiString = _apiArray[row];
    [SSHttpRequest sharedInstance].baseUrlString = [NSString stringWithFormat:@"http://%@.agilanews.info", apiString];
    NSString *home = [NSString stringWithFormat:@"http://%@.agilanews.info/v2", apiString];
    DEF_PERSISTENT_SET_OBJECT(Server_Home, home);
    NSString *homeV3 = [NSString stringWithFormat:@"http://%@.agilanews.info/v3", apiString];
    DEF_PERSISTENT_SET_OBJECT(Server_HomeV3, homeV3);
    NSString *log = [NSString stringWithFormat:@"http://%@.agilanews.info/v3", apiString];
    DEF_PERSISTENT_SET_OBJECT(Server_Log, log);
    NSString *mon = [NSString stringWithFormat:@"http://%@.agilanews.info/v2", apiString];
    DEF_PERSISTENT_SET_OBJECT(Server_Mon, mon);
    NSString *referrer = [NSString stringWithFormat:@"http://%@.agilanews.info/referrer", apiString];
    DEF_PERSISTENT_SET_OBJECT(Server_Referrer, referrer);
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
