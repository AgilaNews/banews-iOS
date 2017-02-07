//
//  LeftCell.m
//  Agilanews
//
//  Created by 张思思 on 16/7/20.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "LeftCell.h"

@implementation LeftCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier HaveImage:(BOOL)isHave
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, (self.height - 18) * .5, 18, 18)];
        _titleImageView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(isHave ? 47 : 13, _titleImageView.top, kScreenWidth - 47 * 2, 18)];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = kBlackColor;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _titleImageView.top = (self.height - 18) * .5;
    _titleLabel.top = _titleImageView.top;
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
