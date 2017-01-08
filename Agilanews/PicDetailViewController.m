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
    } isShowHUD:NO];
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
