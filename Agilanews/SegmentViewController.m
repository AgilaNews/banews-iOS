//
//  SegmentViewController.m
//  SegmentView
//
//  Created by tom.sun on 16/5/26.
//  Copyright © 2016年 tom.sun. All rights reserved.
//

#import "SegmentViewController.h"
#import "HomeTableViewController.h"
#import "AppDelegate.h"

#define HEADBTN_TAG                 10000
#define Default_BottomLineHeight    2
#define Default_ButtonHeight        40
#define Default_TitleColor          [UIColor blackColor]
#define Default_HeadViewBackgroundColor  [UIColor whiteColor]
#define Default_FontSize            17
#define MainScreenWidth             [[UIScreen mainScreen]bounds].size.width
#define MainScreenHeight            [[UIScreen mainScreen]bounds].size.height

@interface SegmentViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *headerView;
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation SegmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSegment
{
    [self addButtonInScrollHeader:_titleArray];
    [self addContentViewScrollView:_subViewControllers];
}

/*!
 *  @brief  根据传入的title数组新建button显示在顶部scrollView上
 *
 *  @param titleArray  title数组
 */
- (void)addButtonInScrollHeader:(NSArray *)titleArray
{
    [self.headerView removeFromSuperview];
    [_lineView removeFromSuperview];
    self.headerView = nil;
    _lineView = nil;
    NSMutableArray *sizeArray = [NSMutableArray array];
    for (NSString *title in titleArray) {
        CGSize size = [title calculateSize:CGSizeMake(1000, 40) font:[UIFont boldSystemFontOfSize:Default_FontSize]];
        [sizeArray addObject:[NSNumber numberWithInt:MAX(size.width, 40) + 20]];
    }
    _sizeArray = sizeArray;
    self.headerView.frame = CGRectMake(0, 0, MainScreenWidth, self.buttonHeight + 10);
    if (_segmentHeaderType == 0) {
        CGFloat width = 0;
        for (NSNumber *size_x in sizeArray) {
            width += [size_x floatValue];
        }
//        self.headerView.contentSize = CGSizeMake(self.buttonWidth * titleArray.count, self.buttonHeight);
        self.headerView.contentSize = CGSizeMake(width, self.buttonHeight);
    }
    else {
        self.headerView.contentSize = CGSizeMake(MainScreenWidth, self.buttonHeight);
    }
    [self.view addSubview:self.headerView];
    
    for (NSInteger index = 0; index < titleArray.count; index++) {
        UIButton *segmentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = 0;
        for (int i = 0; i < index; i++) {
            width += [sizeArray[i] floatValue];
        }
//        segmentBtn.frame = CGRectMake(self.buttonWidth * index, 0, self.buttonWidth, self.buttonHeight);
        segmentBtn.frame = CGRectMake(width, 0, [sizeArray[index] floatValue], self.buttonHeight);
        [segmentBtn setTitle:titleArray[index] forState:UIControlStateNormal];
        segmentBtn.titleLabel.font = [UIFont boldSystemFontOfSize:self.fontSize];
        segmentBtn.titleLabel.backgroundColor = SSColor(235, 235, 235);
        segmentBtn.tag = index + HEADBTN_TAG;
        [segmentBtn setTitleColor:self.titleColor forState:UIControlStateNormal];
        [segmentBtn setTitleColor:self.titleSelectedColor forState:UIControlStateSelected];
        [segmentBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:segmentBtn];
        if (index == 0) {
            segmentBtn.selected = YES;
            self.selectIndex = segmentBtn.tag;
        }
    }
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.buttonHeight - self.bottomLineHeight, [[sizeArray firstObject] floatValue], self.bottomLineHeight)];
    _lineView.backgroundColor = self.bottomLineColor;
    [self.headerView addSubview:_lineView];
}

/*!
 *  @brief  根据传入的viewController数组，将viewController的view添加到显示内容的scrollView
 *
 *  @param subViewControllers  viewController数组
 */
- (void)addContentViewScrollView:(NSArray *)subViewControllers
{
    for (UIViewController *vc in self.childViewControllers) {
        [vc willMoveToParentViewController:nil];
        [vc removeFromParentViewController];
    }
    [_mainScrollView removeAllSubviews];
    [_mainScrollView removeFromSuperview];
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.buttonHeight, MainScreenWidth, MainScreenHeight - self.buttonHeight - 64)];
    _mainScrollView.contentSize = CGSizeMake(MainScreenWidth * subViewControllers.count, MainScreenHeight - self.buttonHeight - 64);
    _mainScrollView.scrollsToTop = NO;
    [_mainScrollView setPagingEnabled:YES];
    if (_segmentControlType == 0) {
        _mainScrollView.scrollEnabled = YES;
    }
    else {
        _mainScrollView.scrollEnabled = NO;
    }
    [_mainScrollView setShowsVerticalScrollIndicator:NO];
    [_mainScrollView setShowsHorizontalScrollIndicator:NO];
    _mainScrollView.directionalLockEnabled = YES;
    _mainScrollView.bounces = NO;
    _mainScrollView.delegate = self;
    [self.view addSubview:_mainScrollView];
    [subViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        UIViewController *viewController = (UIViewController *)_subViewControllers[idx];
        viewController.view.frame = CGRectMake(idx * MainScreenWidth, 0, MainScreenWidth, _mainScrollView.frame.size.height);
        [_mainScrollView addSubview:viewController.view];
        [self addChildViewController:viewController];
    }];
}

- (void)addParentController:(UIViewController *)viewController navView:(UIView *)navView
{
    if ([viewController respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [viewController addChildViewController:self];
    [viewController.view addSubview:self.view];
    [viewController.view addSubview:navView];
}

// 频道按钮点击事件
- (void)btnClick:(UIButton *)button
{
    if (self.selectIndex == button.tag) {
        return;
    }
    [_mainScrollView scrollRectToVisible:CGRectMake((button.tag - HEADBTN_TAG) * MainScreenWidth, 0, MainScreenWidth, _mainScrollView.frame.size.height) animated:YES];
    [self didSelectSegmentIndex:button.tag];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Secect_Channel object:appDelegate.categoriesArray[button.tag - HEADBTN_TAG]];
}

/*!
 *  @brief  设置顶部选中button下方线条位置
 *
 *  @param index 第几个
 */
- (void)didSelectSegmentIndex:(NSInteger)index
{
    UIButton *btn = (UIButton *)[self.view viewWithTag:self.selectIndex];
    btn.selected = NO;
    self.selectIndex = index;
    UIButton *currentSelectBtn = (UIButton *)[self.view viewWithTag:index];
    currentSelectBtn.selected = YES;
    // 记录选中按钮位置
    _buttonX = currentSelectBtn.left - (kScreenWidth - currentSelectBtn.width) * .5;
    CGRect rect = self.lineView.frame;
//    rect.origin.x = (index - HEADBTN_TAG) * _buttonWidth;
    rect.origin.x = currentSelectBtn.left;
    [UIView animateWithDuration:0.4 animations:^{
        self.lineView.frame = rect;
        self.lineView.width = [_sizeArray[index - HEADBTN_TAG] floatValue];
    }];
    for (int i = 0; i < _subViewControllers.count; i++) {
        HomeTableViewController *viewCtrls = _subViewControllers[i];
        if (i == index - HEADBTN_TAG) {
            viewCtrls.tableView.scrollsToTop = YES;
        } else {
            viewCtrls.tableView.scrollsToTop = NO;
        }
    }
    if (_currentIndex == index - HEADBTN_TAG) {
        return;
    }
    // 打点-页面进入-010101
    NSString *channelName = _titleArray[index - HEADBTN_TAG];
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   channelName, @"channel",
                                   [NetType getNetType], @"network",
                                   nil];
    // mor(频道名称)_Enter
    [Flurry logEvent:[NSString stringWithFormat:@"%@_Enter",channelName] withParameters:articleParams];
#if DEBUG
    [iConsole info:[NSString stringWithFormat:@"%@_Enter:%@",channelName,articleParams],nil];
#endif
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _mainScrollView) {
        _currentIndex = scrollView.contentOffset.x / MainScreenWidth;
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _mainScrollView) {
//        float xx = scrollView.contentOffset.x * (_buttonWidth / MainScreenWidth) - _buttonWidth;
//        [_headerView scrollRectToVisible:CGRectMake(xx, 0, MainScreenWidth, _headerView.frame.size.height) animated:YES];
        NSInteger currentIndex = scrollView.contentOffset.x / MainScreenWidth;
        [self didSelectSegmentIndex:currentIndex + HEADBTN_TAG];
        [_headerView scrollRectToVisible:CGRectMake(_buttonX, 0, MainScreenWidth, _headerView.frame.size.height) animated:YES];
        if (_currentIndex == currentIndex) {
            return;
        }
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_Scroll_Channel object:appDelegate.categoriesArray[currentIndex]];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
{
    // 头视图偏移
//    float xx = scrollView.contentOffset.x * (_buttonWidth / MainScreenWidth) - _buttonWidth - 70;
    [_headerView scrollRectToVisible:CGRectMake(_buttonX, 0, MainScreenWidth, _headerView.frame.size.height) animated:YES];
}

#pragma mark - setter/getter
- (UIScrollView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[UIScrollView alloc] init];
        [_headerView setShowsVerticalScrollIndicator:NO];
        [_headerView setShowsHorizontalScrollIndicator:NO];
        _headerView.bounces = NO;
        _headerView.backgroundColor = self.headViewBackgroundColor;
        _headerView.scrollsToTop = NO;
    }
    return _headerView;
}

- (UIColor *)headViewBackgroundColor
{
    if (_headViewBackgroundColor == nil) {
        _headViewBackgroundColor = Default_HeadViewBackgroundColor;
    }
    return _headViewBackgroundColor;
}

- (UIColor *)titleColor
{
    if (_titleColor == nil) {
        _titleColor = Default_TitleColor;
    }
    return _titleColor;
}

- (UIColor *)titleSelectedColor
{
    if (_titleSelectedColor == nil) {
        _titleSelectedColor = Default_TitleColor;
    }
    return _titleSelectedColor;
}

- (CGFloat)fontSize
{
    if (_fontSize == 0) {
        _fontSize = Default_FontSize;
    }
    return _fontSize;
}

- (CGFloat)buttonWidth
{
    if (_buttonWidth == 0) {
        _buttonWidth = MainScreenWidth / 6;
    }
    return _buttonWidth;
}

- (CGFloat)buttonHeight
{
    if (_buttonHeight == 0) {
        _buttonHeight = Default_ButtonHeight;
    }
    return _buttonHeight;
}

- (CGFloat)bottomLineHeight
{
    if (_bottomLineHeight == 0) {
        _bottomLineHeight = Default_BottomLineHeight;
    }
    return _bottomLineHeight;
}

- (UIColor *)bottomLineColor
{
    if (_bottomLineColor == nil) {
        _bottomLineColor = kOrangeColor;
    }
    return _bottomLineColor;
}


@end
