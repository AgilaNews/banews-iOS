//
//  LoadingView.m
//  Agilanews
//
//  Created by 张思思 on 16/9/23.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _loading = [[UIImageView alloc] initWithFrame:CGRectZero];
        _loading.contentMode = UIViewContentModeScaleAspectFit;
        _loading.image = [UIImage imageNamed:@"loading"];
        [self addSubview:_loading];
        _numLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _numLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.9];
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.font = [UIFont systemFontOfSize:11];
        [self addSubview:_numLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _loading.frame = self.bounds;
    _numLabel.frame = self.bounds;
}

- (void)setPercent:(NSString *)percent
{
    if (_percent != percent) {
        _percent = percent;
        _numLabel.text = percent;
    }
}

- (void)startAnimation
{
    [_loading.layer removeAllAnimations];
    self.hidden = NO;
    self.percent = @"0%";
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-M_PI_2, 0.0, 0.0, -1.0)];
    animation.duration = 0.25;
    animation.cumulative = YES;
    animation.repeatCount = HUGE_VALF;
//    CGRect imageRrect = CGRectMake(0, 0,_loading.width, _loading.height);
//    UIGraphicsBeginImageContext(imageRrect.size);
//    [_loading.image drawInRect:CGRectMake(1 , 1, _loading.width - 2, _loading.height - 2)];
//    _loading.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    [_loading.layer addAnimation:animation forKey:nil];
}

- (void)stopAnimation
{
    self.hidden = YES;
    [_loading.layer removeAllAnimations];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
