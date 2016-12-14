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
        _titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, (self.height - 18) * .5, 18, 18)];
        _titleImageView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(isHave ? 49 : 13, _titleImageView.top, 150, 18)];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = kBlackColor;
        _titleLabel.font = [UIFont systemFontOfSize:14];
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
