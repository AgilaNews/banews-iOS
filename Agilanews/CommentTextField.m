//
//  CommentTextField.m
//  Agilanews
//
//  Created by 张思思 on 16/7/27.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "CommentTextField.h"

@implementation CommentTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kWhiteBgColor;
        self.enabled = NO;
        self.layer.cornerRadius = 17;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1;
        self.layer.borderColor = SSColor(235, 235, 235).CGColor;
        self.placeholder = @"    Comments here...";
        [self setValue:kGrayColor forKeyPath:@"_placeholderLabel.textColor"];
        [self setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    }
    return self;
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    [super drawPlaceholderInRect:CGRectMake(0, 0, self.width, self.height)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
