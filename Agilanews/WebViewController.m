//
//  WebViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/7/23.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (instancetype)initWithWebType:(WebType)webType
{
    self = [super init];
    if (self) {
        _webType = webType;
        if (webType == TermOfService) {
            self.title = @"Term Of Service";
        } else {
            self.title = @"Privacy Policy";
        }
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _webView.backgroundColor = kWhiteBgColor;
        _webView.scrollView.backgroundColor = kWhiteBgColor;
        _webView.delegate = self;
        [self.view addSubview:_webView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = kWhiteBgColor;
    self.isBackButton = YES;
    
    NSString *urlString = nil;
    if (_webType == TermOfService) {
        urlString = @"http://www.agilanews.com/agreement.html";
    } else {
        urlString = @"http://www.agilanews.com/privacy.html";
    }
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        [self.navigationController.navigationBar setBarTintColor:kOrangeColor];
        UIView *barBgView = self.navigationController.navigationBar.subviews.firstObject;
        for (UIView *subview in barBgView.subviews) {
            if([subview isKindOfClass:[UIVisualEffectView class]]) {
                subview.backgroundColor = kOrangeColor;
                [subview removeAllSubviews];
            }
        }
    } else {
        [self.navigationController.navigationBar lt_setBackgroundColor:kOrangeColor];
    }
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
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
