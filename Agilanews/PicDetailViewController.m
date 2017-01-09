//
//  PicDetailViewController.m
//  Agilanews
//
//  Created by 张思思 on 17/1/8.
//  Copyright © 2017年 banews. All rights reserved.
//

#import "PicDetailViewController.h"

@interface PicDetailViewController ()

@end

@implementation PicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isBackButton = YES;
    
    _cell = [[OnlyPicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OnlyPicCell" bgColor:kWhiteBgColor];
    [self.view addSubview:_cell];
    // 详情网络请求
    [self requsetDetailWithNewsID:_model.news_id];
}

/**
 新闻详情网络请求
 
 @param newsID
 */
- (void)requsetDetailWithNewsID:(NSString *)newsID
{
    SVProgressHUD.defaultStyle = SVProgressHUDStyleCustom;
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:newsID forKey:@"news_id"];
    [[SSHttpRequest sharedInstance] get:kHomeUrl_NewsDetail params:params contentType:UrlencodedType serverType:NetServer_V3 success:^(id responseObj) {
        [SVProgressHUD dismiss];
        weakSelf.model = [NewsModel mj_objectWithKeyValues:responseObj];
        weakSelf.cell.model = _model;
        [weakSelf.cell tapAction];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (!_blankView) {
            _blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, weakSelf.view.width, weakSelf.view.height)];
            _blankView.backgroundColor = [UIColor whiteColor];
            _blankView.userInteractionEnabled = YES;
            [weakSelf.view addSubview:_blankView];
            _failureView = [[UIImageView alloc] initWithFrame:CGRectMake((_blankView.width - 28) * .5, 200 / kScreenHeight * 568 + 64, 28, 26)];
            _failureView.image = [UIImage imageNamed:@"icon_common_netoff"];
            [_blankView addSubview:_failureView];
            _blankLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 300) * .5, _failureView.bottom + 13, 300, 20)];
            _blankLabel.backgroundColor = [UIColor whiteColor];
            _blankLabel.textAlignment = NSTextAlignmentCenter;
            _blankLabel.textColor = SSColor(177, 177, 177);
            _blankLabel.font = [UIFont systemFontOfSize:16];
            [_blankView addSubview:_blankLabel];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(requestData)];
            [_blankView addGestureRecognizer:tap];
        }
        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
            weakSelf.blankLabel.text = @"Network unavailable";
            weakSelf.failureView.image = [UIImage imageNamed:@"icon_common_netoff"];
        } else {
            weakSelf.blankLabel.text = @"Sorry,please try again";
            weakSelf.failureView.image = [UIImage imageNamed:@"icon_common_failed"];
        }
    } isShowHUD:NO];
}

/**
 *  失败页面请求网络
 */
- (void)requestData
{
    if (self.blankView) {
        [self.blankView removeFromSuperview];
        self.blankView = nil;
        SVProgressHUD.defaultStyle = SVProgressHUDStyleCustom;
        [SVProgressHUD show];
    }
    [self requsetDetailWithNewsID:_model.news_id];
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
