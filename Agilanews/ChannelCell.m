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
        if (iPhone4 || iPhone5) {
            _titleLabel.font = [UIFont systemFontOfSize:13];
        } else if (iPhone6) {
            _titleLabel.font = [UIFont systemFontOfSize:15];
        } else if (iPhone6Plus){
            _titleLabel.font = [UIFont systemFontOfSize:16];
        } else {
            _titleLabel.font = [UIFont systemFontOfSize:15];
        }
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = SSColor(102, 102, 102);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.layer.cornerRadius = (self.height - 12) * .5;
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
    _titleLabel.frame = CGRectMake(12 * .5, 12 * .5, self.width - 12, self.height - 12);
    _titleLabel.text = _model.name;
    if ([_model.channelID isEqualToNumber:@10004]) {
        if (iPhone4 || iPhone5) {
            _titleLabel.font = [UIFont systemFontOfSize:10];
        } else if (iPhone6) {
            _titleLabel.font = [UIFont systemFontOfSize:11];
        } else if (iPhone6Plus){
            _titleLabel.font = [UIFont systemFontOfSize:13];
        } else {
            _titleLabel.font = [UIFont systemFontOfSize:11];
        }
    }
    if (_model.fixed) {
        _titleLabel.textColor = SSColor(204, 204, 204);
    }
    if (_model.isNew) {
        self.labelView.image = [UIImage imageNamed:@"channel_new"];
        [_titleLabel addSubview:self.labelView];
    }
    if (_model.tag) {
        self.labelView.image = [UIImage imageNamed:@"channel_hot"];
        [_titleLabel addSubview:self.labelView];
    }
}


#pragma mark - setter/getter
- (void)setHidden:(BOOL)hidden
{
    if (hidden) {
        if (_model.fixed) {
            _titleLabel.textColor = SSColor(204, 204, 204);
        } else {
            _titleLabel.textColor = SSColor(246, 246, 246);
        }
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.layer.borderColor = [UIColor clearColor].CGColor;
        self.labelView.hidden = YES;
    } else {
        if (_model.fixed) {
            _titleLabel.textColor = SSColor(204, 204, 204);
        } else {
            _titleLabel.textColor = SSColor(102, 102, 102);
        }
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.layer.cornerRadius = (self.height - 12) * .5;
        _titleLabel.layer.borderColor = SSColor(235, 235, 235).CGColor;
        _titleLabel.layer.borderWidth = 1;
        _titleLabel.layer.masksToBounds = YES;
        self.labelView.hidden = NO;
    }
}

- (UIImageView *)labelView
{
    if (_labelView == nil) {
        _labelView = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 26, 23)];
        /*
         张思思
         */
        _labelView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _labelView;
}


@end
