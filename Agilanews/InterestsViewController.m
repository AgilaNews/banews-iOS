//
//  InterestsViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/12/22.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "InterestsViewController.h"
#import "AppDelegate.h"
#import "CategoriesModel.h"

@interface InterestsViewController ()

@end

@implementation InterestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (_isSkip) {
        // 添加导航栏右侧按钮
        UIButton *skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        skipBtn.frame = CGRectMake(0, 0, 80, 40);
        NSString *text = @"Skip";
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:text];
        [attributedStr addAttributes:@{NSFontAttributeName : [UIFont italicSystemFontOfSize:17],
                                       NSForegroundColorAttributeName : kGrayColor,
                                       NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle]
                                       } range:NSMakeRange(0, attributedStr.length)];
        [skipBtn setAttributedTitle:attributedStr forState:UIControlStateNormal];
        [skipBtn addTarget:self action:@selector(skipAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *editItem = [[UIBarButtonItem alloc]initWithCustomView:skipBtn];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -20;
        self.navigationItem.rightBarButtonItems = @[negativeSpacer, editItem];
    } else {
        self.isBackButton = YES;
        [self.backButton setImage:[UIImage imageNamed:@"icon_arrow_left_gary"] forState:UIControlStateNormal];
    }
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        NSArray *list = self.navigationController.navigationBar.subviews;
        for (id obj in list) {
            if ([UIDevice currentDevice].systemVersion.integerValue >= 10) {
                UIView *view = (UIView *)obj;
                for (id obj2 in view.subviews) {
                    if ([obj2 isKindOfClass:[UIImageView class]]) {
                        UIImageView *image = (UIImageView *)obj2;
                        image.hidden = YES;
                    }
                }
            } else {
                self.navigationController.navigationBar.shadowImage = [UIImage new];
            }
        }
    }
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
        UIView *barBgView = self.navigationController.navigationBar.subviews.firstObject;
        for (UIView *subview in barBgView.subviews) {
            if([subview isKindOfClass:[UIVisualEffectView class]]) {
                subview.backgroundColor = [UIColor whiteColor];
                [subview removeAllSubviews];
            }
        }
    } else {
        [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor whiteColor]];
    }
    
    // 页面布局
    NSString *titleStr = @"Let us know what you prefer to read";
    CGSize titleSize = [titleStr calculateSize:CGSizeMake(kScreenWidth - 40, 50) font:[UIFont boldSystemFontOfSize:19]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 64 + 20, kScreenWidth - 40, titleSize.height)];
    titleLabel.font = [UIFont boldSystemFontOfSize:19];
    titleLabel.textColor = kBlackColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    titleLabel.text = titleStr;
    [self.view addSubview:titleLabel];
    
    NSString *contentStr = @"We will give you more presonalized stories based on your selection";
    CGSize contentSize = [contentStr calculateSize:CGSizeMake(kScreenWidth - 40, 40) font:[UIFont systemFontOfSize:13]];
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, titleLabel.bottom + 16, kScreenWidth - 40, contentSize.height)];
    contentLabel.font = [UIFont systemFontOfSize:13];
    contentLabel.textColor = SSColor_RGB(102);
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.numberOfLines = 0;
    contentLabel.text = contentStr;
    [self.view addSubview:contentLabel];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(15, self.view.height - 15 - 45, kScreenWidth - 30, 45);
    [doneButton setBackgroundColor:kOrangeColor forState:UIControlStateNormal];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont systemFontOfSize:20];
    doneButton.layer.cornerRadius = 4;
    doneButton.layer.masksToBounds = YES;
    [doneButton addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneButton];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, contentLabel.bottom + 25, kScreenWidth, doneButton.top - contentLabel.bottom - 50)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_scrollView];
    
    self.interests = [NSMutableArray array];
    [self requestData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)setupScrollViewWith:(NSMutableArray *)titleArray
{
    NSMutableArray *markArray = [NSMutableArray array];
    NSInteger count = 0;
    CGFloat max_contentY = 0;
    // 分组
    for (int i = 0; i < titleArray.count; i++) {
        CategoriesModel *model = titleArray[i];
        CGSize titleSize = [model.name calculateSize:CGSizeMake(kScreenWidth - 40, 16) font:[UIFont systemFontOfSize:15]];
        if (max_contentY + titleSize.width + 18 + 11 <= kScreenWidth - 40) {
            // 放在本行
            if (i == 0) {
                max_contentY = titleSize.width + 18;
            } else {
                max_contentY += (titleSize.width + 18 + 11);
            }
            count++;
        } else {
            // 放在下一行
            [markArray addObject:[NSNumber numberWithInteger:count]];
            max_contentY = titleSize.width + 18;
            count = 1;
        }
        if (i == titleArray.count - 1) {
            [markArray addObject:[NSNumber numberWithInteger:count]];
        }
    }
    // 布局
    CGFloat widthCount = 0;
    CGFloat emptyWidth = 0;
    NSInteger lineNum = 0;
    NSNumber *mark = markArray[lineNum];
    int countNum = mark.intValue;
    for (int i = 0; i < countNum; i++) {
        CategoriesModel *model = titleArray[i];
        CGSize titleSize = [model.name calculateSize:CGSizeMake(kScreenWidth - 40, 16) font:[UIFont systemFontOfSize:15]];
        widthCount += titleSize.width + 18;
    }
    emptyWidth = kScreenWidth - 40 - widthCount - (mark.intValue - 1) * 11;
    CGFloat keyword_X = 20 + emptyWidth * .5;
    CGFloat keyword_Y = 0;
    for (int i = 0; i < titleArray.count; i++) {
        if (i == countNum) {
            lineNum++;
            NSNumber *markNum = markArray[lineNum];
            countNum += markNum.integerValue;
            // 重新计算开始位置
            widthCount = 0;
            for (int j = i; j < countNum; j++) {
                CategoriesModel *model = titleArray[j];
                CGSize titleSize = [model.name calculateSize:CGSizeMake(kScreenWidth - 40, 16) font:[UIFont systemFontOfSize:15]];
                widthCount += titleSize.width + 18;
            }
            emptyWidth = kScreenWidth - 40 - widthCount - (markNum.intValue - 1) * 11;
            keyword_X = 20 + emptyWidth * .5;
            keyword_Y += (15 + 16 + 14);
        }
        // 兴趣主题按钮
        CategoriesModel *model = titleArray[i];
        CGSize keywordSize = [model.name calculateSize:CGSizeMake(kScreenWidth - 40, 16) font:[UIFont systemFontOfSize:15]];
        UIButton *keywordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        keywordButton.frame = CGRectMake(keyword_X, keyword_Y, keywordSize.width + 18, 15 + 16);
        keywordButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [keywordButton setTitle:model.name forState:UIControlStateNormal];
        [keywordButton setTitleColor:kBlackColor forState:UIControlStateNormal];
        [keywordButton setTitleColor:kOrangeColor forState:UIControlStateSelected];
        keywordButton.layer.borderWidth = 1;
        keywordButton.layer.borderColor = kGrayColor.CGColor;
        keywordButton.layer.cornerRadius = 4;
        keywordButton.tag = 500 + i;
        [keywordButton addTarget:self action:@selector(clickKeyword:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:keywordButton];
        keyword_X += (keywordSize.width + 18 + 11);
        if (i == titleArray.count - 1) {
            _scrollView.contentSize = CGSizeMake(kScreenWidth, MAX(keywordButton.bottom, _scrollView.height));
        }
    }
}

- (void)requestData
{
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [[SSHttpRequest sharedInstance] get:kHomeUrl_Interest params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        [SVProgressHUD dismiss];
        NSMutableArray *models = [NSMutableArray array];
        for (NSDictionary *dic in responseObj[@"interests"]) {
            CategoriesModel *model = [CategoriesModel mj_objectWithKeyValues:dic];
            [models addObject:model];
        }
        weakSelf.baseArray = models;
        if (models.count) {
            [weakSelf setupScrollViewWith:models];
        } else {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            weakSelf.baseArray = appDelegate.categoriesArray;
            [weakSelf setupScrollViewWith:appDelegate.categoriesArray];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        weakSelf.baseArray = appDelegate.categoriesArray;
        [weakSelf setupScrollViewWith:appDelegate.categoriesArray];
    } isShowHUD:NO];
}

- (void)clickKeyword:(UIButton *)button
{
    if (button.selected) {
        button.layer.borderColor = kGrayColor.CGColor;
        if (button.tag - 500 < self.baseArray.count) {
            [self.interests removeObject:[self.baseArray objectAtIndex:button.tag - 500]];
        }
    } else {
        button.layer.borderColor = kOrangeColor.CGColor;
        if (button.tag - 500 < self.baseArray.count) {
            [self.interests addObject:[self.baseArray objectAtIndex:button.tag - 500]];
        }
    }
    button.selected = !button.selected;
}

- (void)doneAction
{
    if (!self.interests.count) {
        [SVProgressHUD showInfoWithStatus:@"Please select at least one item"];
        return;
    }
    [SVProgressHUD show];
    NSArray *interestArray = [CategoriesModel mj_keyValuesArrayWithObjectArray:self.interests];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:interestArray forKey:@"interests"];
    [[SSHttpRequest sharedInstance] post:kHomeUrl_Interest params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        [SVProgressHUD showSuccessWithStatus:@"Successful"];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"Successful"];
        [self.navigationController popViewControllerAnimated:YES];
    } isShowHUD:NO];
}

- (void)skipAction
{
    [self.navigationController popViewControllerAnimated:YES];
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
