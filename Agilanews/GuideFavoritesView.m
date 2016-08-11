//
//  GuideFavoritesView.m
//  Agilanews
//
//  Created by 张思思 on 16/8/5.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "GuideFavoritesView.h"

@implementation GuideFavoritesView

static GuideFavoritesView *_guideView = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _guideView = [[GuideFavoritesView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _guideView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
        [_guideView _initSubviews];
    });
    return _guideView;
}

- (void)_initSubviews
{
    _favoritesView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 269 - 20, kScreenHeight - 151, 269, 151)];
    _favoritesView.image = [UIImage imageNamed:@"guide_favorites"];
    [_guideView addSubview:_favoritesView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 90, kScreenHeight - 50, 50, 50)];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [_guideView addSubview:button];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.3 animations:^{
            _guideView.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
            DEF_PERSISTENT_SET_OBJECT(SS_GuideFavKey, @1);
            [_guideView removeFromSuperview];
        }];
    });
}

- (void)buttonAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_TouchFavorite object:nil];
    [UIView animateWithDuration:.3 animations:^{
        _guideView.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        DEF_PERSISTENT_SET_OBJECT(SS_GuideFavKey, @1);
        [_guideView removeFromSuperview];
    }];
}

@end
