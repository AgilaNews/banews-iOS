//
//  GuideVideoTab.m
//  Agilanews
//
//  Created by 张思思 on 17/2/9.
//  Copyright © 2017年 banews. All rights reserved.
//

#import "GuideVideoTab.h"
#import "MainViewController.h"
#import "GuideFirstVideoTab.h"

@implementation GuideVideoTab

static GuideVideoTab *_guideView = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _guideView = [[GuideVideoTab alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        [_guideView _initSubviews];
    });
    return _guideView;
}

- (void)_initSubviews
{
    UIGestureRecognizer *tap = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(removeAction)];
    tap.delegate = self;
    [_guideView addGestureRecognizer:tap];

    _videoView = [[UIImageView alloc] init];
    _videoView.userInteractionEnabled = YES;
    _videoView.contentMode = UIViewContentModeScaleToFill;
    
    NSString *guideString = @"Introducing, the new AgilaBuzz Video Tab!";
    CGSize guideLabelSize = [guideString calculateSize:CGSizeMake(220, 40) font:[UIFont systemFontOfSize:16]];
    UILabel *guideLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, guideLabelSize.width, guideLabelSize.height)];
    guideLabel.font = [UIFont systemFontOfSize:16];
    guideLabel.textColor = [UIColor whiteColor];
    guideLabel.numberOfLines = 0;
    guideLabel.text = guideString;
    
    float viewWidth = guideLabel.width + 10;
    float viewHeight = guideLabel.height + 10 + 6;
    _videoView.frame = CGRectMake((kScreenWidth - viewWidth) * .5, kScreenHeight - 49 - viewHeight, (viewWidth - 18) * .5 + 18, viewHeight);
    UIImage *image = [UIImage imageNamed:@"guide_bubble"];
    UIImage *newImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 8, 15)];
    _videoView.image = newImage;
    UIGraphicsBeginImageContextWithOptions(_videoView.size, NO, [UIScreen mainScreen].scale);
    [_videoView drawViewHierarchyInRect:_videoView.bounds afterScreenUpdates:YES];
    UIImage *changeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _videoView.frame = CGRectMake((kScreenWidth - viewWidth) * .5, kScreenHeight - 49 - viewHeight + 3, viewWidth, viewHeight);
    UIImage *finalImage = [changeImage resizableImageWithCapInsets:UIEdgeInsetsMake(3, (viewWidth - 18) * .5 + 18 - 3, 8, 3)];
    _videoView.image = finalImage;

    [_videoView addSubview:guideLabel];
    [_guideView addSubview:_videoView];
    
    UIButton *tabButton = [UIButton buttonWithType:UIButtonTypeCustom];
    float buttonWidth = kScreenWidth / 3.0;
    tabButton.frame = CGRectMake((kScreenWidth - buttonWidth) * .5, kScreenHeight - 50, buttonWidth, 50);
    [tabButton addTarget:self action:@selector(tapVideo) forControlEvents:UIControlEventTouchUpInside];
    [_guideView addSubview:tabButton];
}

- (void)tapVideo
{
    MainViewController *mainVC = (MainViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    mainVC.selectedViewController = mainVC.viewControllers[1];
    [UIView animateWithDuration:.3 animations:^{
        _guideView.backgroundColor = [UIColor clearColor];
        _videoView.alpha = 0;
    } completion:^(BOOL finished) {
        DEF_PERSISTENT_SET_OBJECT(SS_GuideVideoKey, @1);
        [_guideView removeFromSuperview];
        if (![DEF_PERSISTENT_GET_OBJECT(SS_GuideFirstVideoTab) isEqualToNumber:@1]) {
            [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:[GuideFirstVideoTab sharedInstance]];
        }
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    [self removeAction];
    return YES;
}

- (void)removeAction
{
    [UIView animateWithDuration:.3 animations:^{
        _guideView.backgroundColor = [UIColor clearColor];
        _videoView.alpha = 0;
    } completion:^(BOOL finished) {
        DEF_PERSISTENT_SET_OBJECT(SS_GuideVideoKey, @1);
        [_guideView removeFromSuperview];
    }];
}

@end
