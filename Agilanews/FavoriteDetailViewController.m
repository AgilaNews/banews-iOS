//
//  FavoriteDetailViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/7/28.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "FavoriteDetailViewController.h"
#import "AppDelegate.h"
#import "NewsDetailModel.h"
#import "ImageModel.h"

@interface FavoriteDetailViewController ()

@end

@implementation FavoriteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.isBackButton = YES;
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _webView.backgroundColor = kWhiteBgColor;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *htmlFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.data",appDelegate.model.user_id]];
    NSMutableDictionary *dataDic = [NSKeyedUnarchiver unarchiveObjectWithFile:htmlFilePath];
    NewsDetailModel *model = dataDic[_model.collect_id];

    if (model) {
        // css文件路径
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"webView" ofType:@"css"];
        // 格式化日期
        NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:[model.public_time longLongValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [dateFormatter stringFromDate:currentDate];
        // 替换图片url
        for (int i = 0; i < model.imgs.count; i++) {
            if ([DEF_PERSISTENT_GET_OBJECT(SS_textOnlyMode) isEqualToNumber:@1]) {
                NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"textonly" ofType:@"png"];
                NSString *imageUrl = [NSString stringWithFormat:@"<img src=file:///%@/>",imageFilePath];
                model.body = [model.body stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<!--IMG%d-->",i] withString:imageUrl];
            } else {
                ImageModel *imageModel = model.imgs[i];
                NSString *imageUrl = [NSString stringWithFormat:@"<img src=\"%@\"/>",imageModel.src];
                model.body = [model.body stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<!--IMG%d-->",i] withString:imageUrl];
            }
        }
        // 拼接HTML
        NSString *htmlString = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"file:///%@\"/></head><body><div class=\"title\">%@</div><div class=\"sourcetime\">%@  %@ <a class=\"source\" href=" ">/View source</a></div>%@",filePath,model.title,dateString,model.source,model.body];
        htmlString = [htmlString stringByAppendingString:@"</body></html>"];
        [_webView loadHTMLString:htmlString baseURL:nil];
    } else {
        // 请求新闻详情
        [self requestDataWithNewsID:_model.news_id];
    }
    
    // 添加导航栏右侧按钮
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(0, 0, 40, 38);
    [moreBtn setImage:[UIImage imageNamed:@"icon_article_font"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc]initWithCustomView:moreBtn];
    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue] >=7 ) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;
        self.navigationItem.rightBarButtonItems = @[negativeSpacer, moreItem];
    } else {
        self.navigationItem.rightBarButtonItem = moreItem;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChange) name:KNOTIFICATION_FontSize_Change object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Network
/**
 *  请求新闻详情
 *
 *  @param newID 新闻ID
 */
- (void)requestDataWithNewsID:(NSString *)newsID
{
    [SVProgressHUD show];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:newsID forKey:@"news_id"];
    _task = [[SSHttpRequest sharedInstance] get:kHomeUrl_NewsDetail params:params contentType:UrlencodedType serverType:NetServer_Home success:^(id responseObj)
    {
        [SVProgressHUD dismiss];
        NewsDetailModel *detailModel = [NewsDetailModel mj_objectWithKeyValues:responseObj];
        // css文件路径
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"webView" ofType:@"css"];
        // 格式化日期
        NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:[detailModel.public_time longLongValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [dateFormatter stringFromDate:currentDate];
        // 替换图片url
        for (int i = 0; i < detailModel.imgs.count; i++) {
            if ([DEF_PERSISTENT_GET_OBJECT(SS_textOnlyMode) isEqualToNumber:@1]) {
                NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"textonly" ofType:@"png"];
                NSString *imageUrl = [NSString stringWithFormat:@"<img src=file:///%@/>",imageFilePath];
                detailModel.body = [detailModel.body stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<!--IMG%d-->",i] withString:imageUrl];
            } else {
                ImageModel *imageModel = detailModel.imgs[i];
                NSString *imageUrl = [NSString stringWithFormat:@"<img src=\"%@\"/>",imageModel.src];
                detailModel.body = [detailModel.body stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<!--IMG%d-->",i] withString:imageUrl];
            }
        }
        // 拼接HTML
        NSString *htmlString = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"file:///%@\"/></head><body><div class=\"title\">%@</div><div class=\"sourcetime\">%@  %@ <a class=\"source\" href=" ">/View source</a></div>%@",filePath,detailModel.title,dateString,detailModel.source,detailModel.body];
        htmlString = [htmlString stringByAppendingString:@"</body></html>"];
        [_webView loadHTMLString:htmlString baseURL:nil];
    } failure:^(NSError *error) {
        
    } isShowHUD:YES];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD show];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
    NSInteger textSize = 100;
    switch ([DEF_PERSISTENT_GET_OBJECT(SS_FontSize) integerValue]) {
        case 0:
            textSize = 100;
            break;
        case 1:
            textSize = 145;
            break;
        case 2:
            textSize = 125;
            break;
        case 3:
            textSize = 80;
            break;
        default:
            textSize = 100;
            break;
    }
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%ld%%'",(long)textSize]];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        // 打点-页面进入-011001
        [Flurry logEvent:@"NetFailure_Enter"];
        
        [SVProgressHUD showErrorWithStatus:@"Please check your network connection"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } else {
        // 打点-页面进入-011001
        [Flurry logEvent:@"NetFailure_Enter"];
        
        [SVProgressHUD showErrorWithStatus:@"Fetching failed, please try again"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }
}

#pragma mark - 按钮点击事件
- (void)backAction:(UIButton *)button
{
    [SVProgressHUD dismiss];
    [_task cancel];
    [super backAction:button];
}

/**
 *  字体按钮点击事件
 */
- (void)moreAction
{
    UIAlertController *sheetAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *extraLarge = [UIAlertAction actionWithTitle:@"Extra Large" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DEF_PERSISTENT_SET_OBJECT(SS_FontSize, @1);
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_FontSize_Change object:nil];
    }];
    UIAlertAction *large = [UIAlertAction actionWithTitle:@"Large" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DEF_PERSISTENT_SET_OBJECT(SS_FontSize, @2);
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_FontSize_Change object:nil];
    }];
    UIAlertAction *normal = [UIAlertAction actionWithTitle:@"Normal" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DEF_PERSISTENT_SET_OBJECT(SS_FontSize, @0);
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_FontSize_Change object:nil];
    }];
    UIAlertAction *small = [UIAlertAction actionWithTitle:@"Small" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DEF_PERSISTENT_SET_OBJECT(SS_FontSize, @3);
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
 *  字体改变通知
 */
- (void)fontChange
{
    NSInteger textSize = 100;
    switch ([DEF_PERSISTENT_GET_OBJECT(SS_FontSize) integerValue]) {
        case 0:
            textSize = 100;
            break;
        case 1:
            textSize = 145;
            break;
        case 2:
            textSize = 125;
            break;
        case 3:
            textSize = 80;
            break;
        default:
            textSize = 100;
            break;
    }
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%ld%%'",(long)textSize]];
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
