//
//  PullDownListView.m
//  Agilanews
//
//  Created by 张思思 on 16/12/8.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "PullDownListView.h"
#import "AppDelegate.h"
#import "SegmentViewController.h"
#import "MainViewController.h"

@implementation PullDownListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSInteger count = 0;
        MainViewController *mainVC = (MainViewController *)appDelegate.window.rootViewController;
        NSMutableArray *categories = [NSMutableArray array];
        if (mainVC.index == 0) {
            categories = appDelegate.categoriesArray;
        } else {
            categories = appDelegate.videoCategories;
        }
        if (categories.count % 3 == 0) {
            count = categories.count / 3;
        } else {
            count = categories.count / 3 + 1;
        }
        _whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40 + count * 40 + 10)];
        _whiteView.backgroundColor = [UIColor whiteColor];
        _whiteView.alpha = .98;
        [self addSubview:_whiteView];
        
        UIButton *upButton = [UIButton buttonWithType:UIButtonTypeCustom];
        upButton.frame = CGRectMake(kScreenWidth - 34, 0, 34, 40);
        [upButton setImage:[UIImage imageNamed:@"icon_arrow_up"] forState:UIControlStateNormal];
        upButton.userInteractionEnabled = NO;
        [_whiteView addSubview:upButton];
        
        UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, _whiteView.bottom, kScreenWidth, self.height - _whiteView.height)];
        blackView.backgroundColor = [UIColor blackColor];
        blackView.alpha = .4;
        [self addSubview:blackView];

        CGFloat spacing_H = 12;
        CGFloat spacing_V = 10;
        CGFloat itemWidth = (kScreenWidth - spacing_H * 4) / 3.0;
        CGFloat itemHeight = 30;
        for (int i = 0; i < categories.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(spacing_H + i % 3 * (itemWidth + spacing_H), 40 + i / 3 * (itemHeight + spacing_V), itemWidth, itemHeight);
            CategoriesModel *model = categories[i];
            [button setTitle:model.name forState:UIControlStateNormal];
            if ([model.name isEqualToString:@"Entertainment"]) {
                button.titleLabel.font = [UIFont systemFontOfSize:12];
            } else {
                button.titleLabel.font = [UIFont systemFontOfSize:14];
            }
            [button setTitleColor:SSColor_RGB(102) forState:UIControlStateNormal];
            button.tag = 10000 + i;
            button.layer.borderColor = SSColor_RGB(178).CGColor;
            button.layer.borderWidth = .5;
            button.layer.cornerRadius = itemHeight * .5;
            button.layer.masksToBounds = YES;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_whiteView addSubview:button];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    MainViewController *mainVC = (MainViewController *)appDelegate.window.rootViewController;
    NSMutableArray *categories = [NSMutableArray array];
    if (mainVC.index == 0) {
        categories = appDelegate.categoriesArray;
    } else {
        categories = appDelegate.videoCategories;
    }
    for (int i = 0; i < categories.count; i++) {
        CategoriesModel *model = categories[i];
        UIButton *button = [_whiteView viewWithTag:10000 + i];
        [button setTitle:model.name forState:UIControlStateNormal];
        if ([model.name isEqualToString:@"Entertainment"]) {
            button.titleLabel.font = [UIFont systemFontOfSize:12];
        } else {
            button.titleLabel.font = [UIFont systemFontOfSize:14];
        }
    }
}

- (void)buttonAction:(UIButton *)button
{
    SegmentViewController *segmentVC = (SegmentViewController *)self.ViewController;
    UIButton *channelButton = [segmentVC.headerView viewWithTag:button.tag];
    [channelButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    segmentVC.isPullDownListShow = NO;
    segmentVC.pullDownButton.selected = NO;
}

@end
