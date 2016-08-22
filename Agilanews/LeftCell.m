//
//  LeftCell.m
//  Agilanews
//
//  Created by 张思思 on 16/7/20.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "LeftCell.h"

@implementation LeftCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kWhiteBgColor;
        _titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(27, 11, 22, 22)];
        _titleImageView.backgroundColor = kWhiteBgColor;
        [self.contentView addSubview:_titleImageView];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleImageView.right + 17, _titleImageView.top, 150, 22)];
        _titleLabel.backgroundColor = kWhiteBgColor;
        _titleLabel.textColor = kBlackColor;
        _titleLabel.font = [UIFont systemFontOfSize:17];
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
