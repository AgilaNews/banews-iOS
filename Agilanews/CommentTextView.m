//
//  CommentTextView.m
//  Agilanews
//
//  Created by 张思思 on 16/7/27.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "CommentTextView.h"
#import "HomeViewController.h"

@implementation CommentTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _shadowView = [[UIView alloc] initWithFrame:frame];
        _shadowView.backgroundColor = [UIColor blackColor];
        _shadowView.alpha = 0;
        [self addSubview:_shadowView];
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 174, kScreenWidth, 174)];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.alpha = 0;
        [self addSubview:_bgView];
        
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 13, kScreenWidth - 20, 122)];
        _textView.backgroundColor = kWhiteBgColor;
        _textView.layer.cornerRadius = 2;
        _textView.layer.masksToBounds = YES;
        _textView.layer.borderColor = SSColor(235, 235, 235).CGColor;
        _textView.layer.borderWidth = 1;
        _textView.tintColor = kOrangeColor;
        _textView.textColor = kBlackColor;
        _textView.contentInset = UIEdgeInsetsMake(0, 0, 25, 0);
        _textView.font = [UIFont systemFontOfSize:14];
        [_bgView addSubview:_textView];
        
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 200, 15)];
        _placeholderLabel.backgroundColor = kWhiteBgColor;
        _placeholderLabel.textColor = kGrayColor;
        _placeholderLabel.font = [UIFont systemFontOfSize:14];
        _placeholderLabel.enabled = NO;
        _placeholderLabel.text = @"Comments here...";
        [_textView addSubview:_placeholderLabel];
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        _cancelButton.frame = CGRectMake(kScreenWidth - 145, _textView.bottom + 2, 60, 35);
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:SSColor(129, 129, 137) forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_bgView addSubview:_cancelButton];

        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.backgroundColor = [UIColor whiteColor];
        _sendButton.frame = CGRectMake(_cancelButton.right + 20, _cancelButton.top, _cancelButton.width, _cancelButton.height);
        [_sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [_sendButton setTitleColor:SSColor(129, 129, 137) forState:UIControlStateNormal];
        [_sendButton setTitleColor:kOrangeColor forState:UIControlStateSelected];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_bgView addSubview:_sendButton];
        
        _letterNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _textView.height - 10, 100, 13)];
        _letterNumLabel.right = _bgView.width - 23;
        _letterNumLabel.text = @"0/300";
        _letterNumLabel.textColor = kGrayColor;
        _letterNumLabel.font = [UIFont systemFontOfSize:12];
        _letterNumLabel.textAlignment = NSTextAlignmentRight;
        [_bgView addSubview:_letterNumLabel];
        
        [_textView becomeFirstResponder];
        [UIView animateWithDuration:.5 animations:^{
            _shadowView.alpha = .7;
            _bgView.alpha = 1;
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentTextViewTextChange) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setIsInput:(BOOL)isInput
{
    if (_isInput != isInput) {
        _isInput = isInput;
        
        if (isInput) {
            // 打点-输入评论-010208
            UINavigationController *navCtrl = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            HomeViewController *homeVC = navCtrl.viewControllers.firstObject;
            NSString *channelName = homeVC.segmentVC.titleArray[homeVC.segmentVC.selectIndex - 10000];
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           channelName, @"channel",
                                           _news_id, @"article",
                                           [NetType getNetType], @"network",
                                           nil];
            [Flurry logEvent:@"Article_Comments_Input" withParameters:articleParams];
#if DEBUG
            [iConsole info:[NSString stringWithFormat:@"Article_Comments_Input:%@",articleParams],nil];
#endif
        }
    }
}

- (void)commentTextViewTextChange
{
    _letterNumLabel.text = [NSString stringWithFormat:@"%ld/300",(unsigned long)_textView.text.length];
    if (_textView.text.length > 300) {
        _letterNumLabel.textColor = SSColor(225, 65, 35);
    } else {
        _letterNumLabel.textColor = kGrayColor;
    }
}

@end
