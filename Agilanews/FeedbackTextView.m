//
//  FeedbackTextView.m
//  Agilanews
//
//  Created by 张思思 on 16/8/2.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "FeedbackTextView.h"

@implementation FeedbackTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 1;
        self.layer.borderColor = SSColor(235, 235, 235).CGColor;
        
        _feedbackTextView = [[FeedbackSubview alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 160)];
        _feedbackTextView.backgroundColor = [UIColor whiteColor];
        _feedbackTextView.tintColor = kOrangeColor;
        _feedbackTextView.textColor = kBlackColor;
        _feedbackTextView.font = [UIFont systemFontOfSize:15];
        _feedbackTextView.contentInset = UIEdgeInsetsMake(6, 0, 25, 0);
        [self addSubview:_feedbackTextView];
        
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 13, 200, 18)];
        _placeholderLabel.backgroundColor = [UIColor whiteColor];
        _placeholderLabel.textColor = kGrayColor;
        _placeholderLabel.font = [UIFont systemFontOfSize:15];
        _placeholderLabel.enabled = NO;
        _placeholderLabel.text = @"Type here...";
        [self addSubview:_placeholderLabel];
        
        _letterNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height - 23, 100, 13)];
        _letterNumLabel.right = self.width - 13;
        _letterNumLabel.text = @"0/300";
        _letterNumLabel.textColor = kGrayColor;
        _letterNumLabel.font = [UIFont systemFontOfSize:12];
        _letterNumLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_letterNumLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedbackTextViewTextChange) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)feedbackTextViewTextChange
{
    _letterNumLabel.text = [NSString stringWithFormat:@"%ld/300",(unsigned long)_feedbackTextView.text.length];
    if (_feedbackTextView.text.length > 0) {
        _placeholderLabel.hidden = YES;
        _isInput = YES;
    } else {
        _placeholderLabel.hidden = NO;
        _isInput = NO;
    }
    if (_feedbackTextView.text.length > 300) {
        _letterNumLabel.textColor = SSColor(225, 65, 35);
    } else {
        _letterNumLabel.textColor = kGrayColor;
    }
}

- (void)setIsInput:(BOOL)isInput
{
    if (_isInput != isInput) {
        _isInput = isInput;
        
        if (isInput) {
            // 打点-输入反馈意见-010802
            [Flurry logEvent:@"FeedB_Sugg_Input"];
#if DEBUG
            [iConsole info:@"FeedB_Sugg_Input",nil];
#endif
        }
    }
}

@end
