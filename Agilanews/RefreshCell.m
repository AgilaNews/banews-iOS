//
//  RefreshCell.m
//  Agilanews
//
//  Created by 张思思 on 16/9/27.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "RefreshCell.h"

@implementation RefreshCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = SSColor(222, 239, 243);
        
        _refreshLabel = [[UILabel alloc] init];
        _refreshLabel.backgroundColor = self.backgroundColor;
        _refreshLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_refreshLabel];
        
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:@"You were here last time,Tap to refresh"];
        [attributedStr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                       NSForegroundColorAttributeName : SSColor(0, 172, 215),
                                       NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleNone]
                                       } range:NSMakeRange(0, 24)];
        [attributedStr addAttributes:@{NSFontAttributeName : [UIFont italicSystemFontOfSize:14],
                                       NSForegroundColorAttributeName : SSColor(0, 203, 254),
                                       NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle]
                                       } range:NSMakeRange(24, 14)];
        _refreshLabel.attributedText = attributedStr;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _refreshLabel.frame = self.bounds;
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
