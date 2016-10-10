//
//  GuideChannelView.m
//  Agilanews
//
//  Created by 张思思 on 16/10/10.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "GuideChannelView.h"

@implementation GuideChannelView

static GuideChannelView *_guideView = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _guideView = [[GuideChannelView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _guideView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
        [_guideView _initSubviews];
    });
    return _guideView;
}

- (void)_initSubviews
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeAction)];
    [_guideView addGestureRecognizer:tap];
    
    _channelView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 262) * .5, (kScreenHeight - 125 - 27 - 42) * .5, 262, 125)];
    _channelView.contentMode = UIViewContentModeScaleAspectFit;
    _channelView.image = [UIImage imageNamed:@"guide_channel"];
    [_guideView addSubview:_channelView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, _channelView.bottom + 27, kScreenWidth - 56, 42)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:@"Please long press and drag the tab to set your own channel order"];
    [attributedStr addAttributes:@{NSFontAttributeName : [UIFont italicSystemFontOfSize:17],
                                   NSForegroundColorAttributeName : [UIColor whiteColor]
                                   } range:NSMakeRange(0, attributedStr.length)];
    titleLabel.attributedText = attributedStr;
    [_guideView addSubview:titleLabel];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.3 animations:^{
            _guideView.backgroundColor = [UIColor clearColor];
            _channelView.alpha = 0;
        } completion:^(BOOL finished) {
//            DEF_PERSISTENT_SET_OBJECT(SS_GuideCnlKey, @1);
            [_guideView removeFromSuperview];
        }];
    });
}

- (void)removeAction
{
    [UIView animateWithDuration:.3 animations:^{
        _guideView.backgroundColor = [UIColor clearColor];
        _channelView.alpha = 0;
    } completion:^(BOOL finished) {
//        DEF_PERSISTENT_SET_OBJECT(SS_GuideCnlKey, @1);
        [_guideView removeFromSuperview];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
