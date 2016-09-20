//
//  FeedbackViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/8/1.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Feedback";
    self.isBackButton = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;

    // 添加导航栏右侧按钮
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton.frame = CGRectMake(0, 0, 80, 40);
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [_sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.4] forState:UIControlStateDisabled];
    [_sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc]initWithCustomView:_sendButton];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -20;
        self.navigationItem.rightBarButtonItems = @[negativeSpacer, sendItem];
    } else {
        self.navigationItem.rightBarButtonItem = sendItem;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedbackViewControllerTextChange) name:UITextViewTextDidChangeNotification object:nil];

    // 初始化子视图
    [self _initSubiews];
    _sendButton.enabled = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 初始化子视图
- (void)_initSubiews
{
    _textView = [[FeedbackTextView alloc] initWithFrame:CGRectMake(0, 64 + 10, kScreenWidth, 185)];
    [self.view addSubview:_textView];
    _textView.feedbackTextView.text = @" ";
    [_textView.feedbackTextView becomeFirstResponder];
    _textView.feedbackTextView.text = nil;
    
    _textField = [[FeedbackTextField alloc] initWithFrame:CGRectMake(0, _textView.bottom + 10, kScreenWidth, 44)];
    [self.view addSubview:_textField];
}

#pragma mark - 按钮点击事件
- (void)sendAction:(UIButton *)button
{
    // 打点-点击提交-010804
    [Flurry logEvent:@"FeedB_Submit_Click"];
#if DEBUG
    [iConsole info:@"FeedB_Submit_Click",nil];
#endif
    [SVProgressHUD show];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_textView.feedbackTextView.text forKey:@"fb_detail"];
    // 判断邮箱格式
    if (_textField.text.length > 0) {
        NSString *regex = @"^([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        BOOL isMatch = [pred evaluateWithObject:_textField.text];
        if (isMatch) {
            [params setObject:_textField.text forKey:@"email"];
        } else {
            // 打点-提交失败-010806
            [Flurry logEvent:@"FeedB_Submit_Click_N"];
#if DEBUG
            [iConsole info:@"FeedB_Submit_Click_N",nil];
#endif
            [SVProgressHUD showErrorWithStatus:@"Please input right email address"];
            return;
        }
    }
    [[SSHttpRequest sharedInstance] post:kHomeUrl_Feedback params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        // 打点-提交成功-010805
        [Flurry logEvent:@"FeedB_Submit_Click_Y"];
#if DEBUG
        [iConsole info:@"FeedB_Submit_Click_Y",nil];
#endif
        [SVProgressHUD showSuccessWithStatus:@"Successful"];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        // 打点-提交失败-010806
        [Flurry logEvent:@"FeedB_Submit_Click_N"];
#if DEBUG
        [iConsole info:@"FeedB_Submit_Click_N",nil];
#endif
    } isShowHUD:YES];
}

- (void)backAction:(UIButton *)button
{
    // 打点-点击反馈页返回按钮-010807
    [Flurry logEvent:@"FeedB_BackButton_Click"];
#if DEBUG
    [iConsole info:@"FeedB_BackButton_Click",nil];
#endif
    [super backAction:button];
}

#pragma mark - 输入框改变
- (void)feedbackViewControllerTextChange
{
    if (_textView.feedbackTextView.text.length > 0 && _textView.feedbackTextView.text.length <= 300) {
        _sendButton.enabled = YES;
    } else {
        _sendButton.enabled = NO;
    }
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
