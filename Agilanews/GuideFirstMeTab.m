//
//  GuideFirstMeTab.m
//  Agilanews
//
//  Created by 张思思 on 17/2/9.
//  Copyright © 2017年 banews. All rights reserved.
//

#import "GuideFirstMeTab.h"
#import "MainViewController.h"

@implementation GuideFirstMeTab

static GuideFirstMeTab *_guideView = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _guideView = [[GuideFirstMeTab alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        [_guideView _initSubviews];
    });
    return _guideView;
}

- (void)_initSubviews
{
    UIGestureRecognizer *tap = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(removeAction)];
    tap.delegate = self;
    [_guideView addGestureRecognizer:tap];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.userInteractionEnabled = YES;
    _imageView.contentMode = UIViewContentModeScaleToFill;
    
    NSString *guideString = @"Get easier access to your personal settings!";
    CGSize guideLabelSize = [guideString calculateSize:CGSizeMake(220, 40) font:[UIFont systemFontOfSize:16]];
    UILabel *guideLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, guideLabelSize.width, guideLabelSize.height)];
    guideLabel.font = [UIFont systemFontOfSize:16];
    guideLabel.textColor = [UIColor whiteColor];
    guideLabel.numberOfLines = 0;
    guideLabel.text = guideString;
    
    float viewWidth = guideLabel.width + 10;
    float viewHeight = guideLabel.height + 10 + 6;
    _imageView.frame = CGRectMake(kScreenWidth / 3.0 * 2.5 - viewWidth * .5 - (viewWidth - 18) * .3, kScreenHeight - 49 - viewHeight, (viewWidth - 18) * .8 + 18, viewHeight);
    UIImage *image = [UIImage imageNamed:@"guide_bubble"];
    UIImage *newImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 8, 15)];
    _imageView.image = newImage;
    UIGraphicsBeginImageContextWithOptions(_imageView.size, NO, [UIScreen mainScreen].scale);
    [_imageView drawViewHierarchyInRect:_imageView.bounds afterScreenUpdates:YES];
    UIImage *changeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _imageView.frame = CGRectMake(kScreenWidth / 3.0 * 2.5 - viewWidth * .5 - (viewWidth - 18) * .3, kScreenHeight - 49 - viewHeight + 3, viewWidth, viewHeight);
    UIImage *finalImage = [changeImage resizableImageWithCapInsets:UIEdgeInsetsMake(3, (viewWidth - 18) * .8 + 18 - 3, 8, 3)];
    _imageView.image = finalImage;
    
    [_imageView addSubview:guideLabel];
    [_guideView addSubview:_imageView];
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
        _imageView.alpha = 0;
    } completion:^(BOOL finished) {
        DEF_PERSISTENT_SET_OBJECT(SS_GuideFirstMeTab, @1);
        [_guideView removeFromSuperview];
    }];
}

@end
