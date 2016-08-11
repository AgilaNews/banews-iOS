//
//  LoginButton.m
//  Agilanews
//
//  Created by 张思思 on 16/7/20.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "LoginButton.h"

@implementation LoginButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 22;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1;
        self.layer.borderColor = SSColor(235, 235, 235).CGColor;
        [self setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setBackgroundColor:[UIColor colorWithRed:1 green:136 / 255.0 blue:0 alpha:.4] forState:UIControlStateHighlighted];
        [self setTitleColor:kBlackColor forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:18];
    }
    return self;
}

- (void)setLoginType:(LoginType)loginType
{
    _titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 34, 34)];
    _titleImageView.layer.cornerRadius = 17;
    _titleImageView.layer.masksToBounds = YES;
    [self addSubview:_titleImageView];
    
    switch (loginType) {
        case FacebookType:
        {
            _titleImageView.image = [UIImage imageNamed:@"icon_login_facebook"];
            [self setTitle:@"Facebook" forState:UIControlStateNormal];
        }
            break;
        case TwitterType:
        {
            _titleImageView.image = [UIImage imageNamed:@"icon_login_twitter"];
            [self setTitle:@"Twitter" forState:UIControlStateNormal];
        }
            break;
        case GooglePulsType:
        {
            _titleImageView.image = [UIImage imageNamed:@"icon_login_google"];
            [self setTitle:@"Google+" forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

@end
