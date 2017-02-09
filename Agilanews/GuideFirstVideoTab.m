//
//  GuideFirstVideoTab.m
//  Agilanews
//
//  Created by 张思思 on 17/2/9.
//  Copyright © 2017年 banews. All rights reserved.
//

#import "GuideFirstVideoTab.h"

@implementation GuideFirstVideoTab

static GuideFirstVideoTab *_guideView = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _guideView = [[GuideFirstVideoTab alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        [_guideView _initSubviews];
    });
    return _guideView;
}

- (void)_initSubviews
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeAction)];
    [_guideView addGestureRecognizer:tap];
    
    _videoView = [[UIImageView alloc] init];
    _videoView.userInteractionEnabled = YES;
    _videoView.contentMode = UIViewContentModeScaleToFill;
    
    NSString *guideString = @"An endless supply of videos for you!";
    CGSize guideLabelSize = [guideString calculateSize:CGSizeMake(220, 40) font:[UIFont systemFontOfSize:16]];
    UILabel *guideLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5 + 5, guideLabelSize.width, guideLabelSize.height)];
    guideLabel.font = [UIFont systemFontOfSize:16];
    guideLabel.textColor = [UIColor whiteColor];
    guideLabel.numberOfLines = 0;
    guideLabel.text = guideString;
    
    float viewWidth = guideLabel.width + 10;
    float viewHeight = guideLabel.height + 10 + 6;
    _videoView.frame = CGRectMake((kScreenWidth - viewWidth) * .5, 64 + 37, (viewWidth - 18) * .5 + 18, viewHeight);
    UIImage *image = [UIImage imageNamed:@"guide_bubble_up"];
    UIImage *newImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(8, 3, 3, 15)];
    _videoView.image = newImage;
    UIGraphicsBeginImageContextWithOptions(_videoView.size, NO, [UIScreen mainScreen].scale);
    [_videoView drawViewHierarchyInRect:_videoView.bounds afterScreenUpdates:YES];
    UIImage *changeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _videoView.frame = CGRectMake((kScreenWidth - viewWidth) * .5, 64 + 37, viewWidth, viewHeight);
    UIImage *finalImage = [changeImage resizableImageWithCapInsets:UIEdgeInsetsMake(8, (viewWidth - 18) * .5 + 18 - 3, 3, 3)];
    _videoView.image = finalImage;
    
    [_videoView addSubview:guideLabel];
    [_guideView addSubview:_videoView];
}

- (void)removeAction
{
    [UIView animateWithDuration:.3 animations:^{
        _guideView.backgroundColor = [UIColor clearColor];
        _videoView.alpha = 0;
    } completion:^(BOOL finished) {
        DEF_PERSISTENT_SET_OBJECT(SS_GuideFirstVideoTab, @1);
        [_guideView removeFromSuperview];
    }];
}

@end
