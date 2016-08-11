//
//  LeftViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/7/19.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "LeftView.h"

#define SLIP_WIDTH 100

@interface LeftView ()

@end

@implementation LeftView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        _leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(spanHide:)];
        [self addGestureRecognizer:_leftPan];
    }
    return self;
}

/**
 *  滑动隐藏方法
 *
 *  @param swipe 滑动手势
 */
- (void)spanHide:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:self];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            _panX = point.x;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            _tableView.left = - MAX((_panX - point.x), 0);
            _shadowView.left = kScreenWidth - SLIP_WIDTH - MAX((_panX - point.x), 0);
            _shadowView.alpha = (1 - (1 / (kScreenWidth - SLIP_WIDTH) * MAX((_panX - point.x), 0))) * .7;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (_tableView.right > (kScreenWidth - SLIP_WIDTH) * .5) {
                [self show];
            } else {
                [self hide];
                _isShow = NO;
            }
        }
            break;
        default:
            break;
    }
}

/**
 *  遮罩点击方法
 */
- (void)tapAction
{
    self.isShow = NO;
}

#pragma mark - getter/setter
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[LeftTableView alloc] initWithFrame:CGRectMake(-kScreenWidth, 0, kScreenWidth - 100, kScreenHeight) style:UITableViewStylePlain];
    }
    return _tableView;
}

- (UIView *)shadowView
{
    if (_shadowView == nil) {
        _shadowView = [[UIView alloc] initWithFrame:CGRectMake(-SLIP_WIDTH, 0, kScreenWidth + SLIP_WIDTH, kScreenHeight)];
        _shadowView.backgroundColor = [UIColor blackColor];
        _shadowView.alpha = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_shadowView addGestureRecognizer:tap];
    }
    return _shadowView;
}

- (void)setIsShow:(BOOL)isShow
{
    if (_isShow != isShow) {
        _isShow = isShow;
        
        if (isShow) {
            [self show];
        } else {
            [self hide];
        }
    }
}

- (void)show
{
    [self addSubview:self.shadowView];
    [self addSubview:self.tableView];
    [UIView animateWithDuration:0.3 animations:^{
        _tableView.left = 0;
        _shadowView.left = kScreenWidth - SLIP_WIDTH;
        _shadowView.alpha = .7;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.3 animations:^{
        _tableView.left = -kScreenWidth;
        _shadowView.left = -SLIP_WIDTH;
        _shadowView.alpha = 0;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        [_tableView removeFromSuperview];
        [_shadowView removeFromSuperview];
        _tableView = nil;
        _shadowView = nil;
        [self removeFromSuperview];
    }];
}

@end
