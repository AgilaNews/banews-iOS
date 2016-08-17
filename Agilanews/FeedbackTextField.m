//
//  FeedbackTextField.m
//  Agilanews
//
//  Created by 张思思 on 16/8/2.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "FeedbackTextField.h"

@implementation FeedbackTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 0, 22, 22)];
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.image = [UIImage imageNamed:@"icon_mail"];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(imageView.right + 10, (self.height - 22) * .5, 1, 22)];
        lineView.backgroundColor = kOrangeColor;
        [self addSubview:lineView];
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 1;
        self.layer.borderColor = SSColor(235, 235, 235).CGColor;
        self.leftViewMode = UITextFieldViewModeAlways;
        self.leftView = imageView;
        self.tintColor = kOrangeColor;
        self.textColor = kBlackColor;
        self.font = [UIFont systemFontOfSize:16];
        self.placeholder = @"Your email here...";
        self.adjustsFontSizeToFitWidth = YES;
        [self setValue:kGrayColor forKeyPath:@"_placeholderLabel.textColor"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}



- (CGRect)textRectForBounds:(CGRect)bounds
{
    bounds.origin.x += 45 + 10;
    return bounds;
}

-(CGRect)editingRectForBounds:(CGRect)bounds
{
    bounds.origin.x += 45 + 10;
    return bounds;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    bounds.origin.x = 13;
    bounds.origin.y = (self.height - 22) * .5;
    bounds.size.width = 22;
    bounds.size.height = 22;
    return bounds;
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    [super drawPlaceholderInRect:CGRectMake(0, 0, self.width - 10, self.height)];
}

- (void)textChange
{
    if (self.text.length > 0) {
        _isInput = YES;
    } else {
        _isInput = NO;
    }
}

- (void)setIsInput:(BOOL)isInput
{
    if (_isInput != isInput) {
        _isInput = isInput;
        
        if (isInput) {
            // 打点-输入邮箱地址-010803
            [Flurry logEvent:@"FeedB_EMail_Input"];
#if DEBUG
            [iConsole info:@"FeedB_EMail_Input",nil];
#endif
        }
    }
}

@end
