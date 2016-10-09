//
//  ChannelCell.m
//  Agilanews
//
//  Created by 张思思 on 16/9/28.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "ChannelCell.h"

@implementation ChannelCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = SSColor(102, 102, 102);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.layer.cornerRadius = (self.height - 9) * .5;
        _titleLabel.layer.borderColor = SSColor(235, 235, 235).CGColor;
        _titleLabel.layer.borderWidth = 1;
        _titleLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _titleLabel.frame = CGRectMake(9 * .5, 9 * .5, self.width - 9, self.height - 9);
    _titleLabel.text = _title;
}

- (void)setHidden:(BOOL)hidden
{
    if (hidden) {
        _titleLabel.textColor = SSColor(246, 246, 246);
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.layer.borderColor = [UIColor clearColor].CGColor;
    } else {
        _titleLabel.textColor = SSColor(102, 102, 102);
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.layer.cornerRadius = (self.height - 9) * .5;
        _titleLabel.layer.borderColor = SSColor(235, 235, 235).CGColor;
        _titleLabel.layer.borderWidth = 1;
        _titleLabel.layer.masksToBounds = YES;
    }
}



@end
