//
//  RecommendedView.m
//  Agilanews
//
//  Created by 张思思 on 16/7/26.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "RecommendedView.h"

@implementation RecommendedView

- (instancetype)initWithFrame:(CGRect)frame titleImage:(UIImage *)image titleText:(NSString *)title HaveLoading:(BOOL)isLoading
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kWhiteBgColor;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, (30 - 13) * .5, 14, 13)];
        imageView.backgroundColor = kWhiteBgColor;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = image;
        [self addSubview:imageView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right + 10, 0, kScreenWidth - 70, 30)];
        titleLabel.backgroundColor = kWhiteBgColor;
        titleLabel.textColor = kBlackColor;
        titleLabel.font = [UIFont boldSystemFontOfSize:13];
        titleLabel.text = title;
        [self addSubview:titleLabel];
        
        if (isLoading) {
            NSString *text = @"Retry";
            CGSize textSize = [text calculateSize:CGSizeMake(100, 30) font:[UIFont italicSystemFontOfSize:12]];
            _retryLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 15 - textSize.width, (30 - textSize.height) * .5, textSize.width, textSize.height)];
            _retryLabel.backgroundColor = kWhiteBgColor;
            _retryLabel.textAlignment = NSTextAlignmentRight;
            _retryLabel.hidden = YES;
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:text];
            [attributedStr addAttributes:@{NSFontAttributeName : [UIFont italicSystemFontOfSize:12],
                                           NSForegroundColorAttributeName : SSColor(71, 174, 207),
                                           NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle]
                                           } range:NSMakeRange(0, attributedStr.length)];
            _retryLabel.attributedText = attributedStr;
            [self addSubview:_retryLabel];
            
            _loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            _loadingView.center = CGPointMake(0, self.height * .5);
            _loadingView.right = self.width - 20;
            _loadingView.backgroundColor = kWhiteBgColor;
            _loadingView.image = [UIImage imageNamed:@"loading_small"];
            _loadingView.hidden = YES;
            [self addSubview:_loadingView];
        }
    }
    return self;
}

- (void)startAnimation
{
    _retryLabel.hidden = YES;
    _loadingView.hidden = NO;
    [_loadingView.layer removeAllAnimations];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-M_PI_2, 0.0, 0.0, -1.0)];
    animation.duration = 0.25;
    animation.cumulative = YES;
    animation.repeatCount = HUGE_VALF;
    [_loadingView.layer addAnimation:animation forKey:nil];
}

- (void)stopAnimation
{
    _loadingView.hidden = YES;
    [_loadingView.layer removeAllAnimations];
}

@end
