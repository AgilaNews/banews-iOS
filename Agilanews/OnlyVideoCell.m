//
//  OnlyVideoCell.m
//  Agilanews
//
//  Created by 张思思 on 16/10/24.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "OnlyVideoCell.h"

@implementation OnlyVideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier bgColor:(UIColor *)bgColor
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgColor = bgColor;
        self.backgroundColor = bgColor;
        // 初始化子视图
        [self _initSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fontChange)
                                                     name:KNOTIFICATION_FontSize_Change
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  初始化子视图
 */
- (void)_initSubviews
{
//    [self.contentView addSubview:self.titleLabel];
//    [self.contentView addSubview:self.titleImageView];
//    [self.contentView addSubview:self.playButton];
//    [self.contentView addSubview:self.loadingView];
//    [self.contentView addSubview:self.likeButton];
//    [self.contentView addSubview:self.shareButton];
}

#pragma mark - Notification
- (void)fontChange
{
//    switch ([DEF_PERSISTENT_GET_OBJECT(SS_FontSize) integerValue]) {
//        case 0:
//            _titleLabel.font = titleFont_Normal;
//            break;
//        case 1:
//            _titleLabel.font = titleFont_ExtraLarge;
//            break;
//        case 2:
//            _titleLabel.font = titleFont_Large;
//            break;
//        case 3:
//            _titleLabel.font = titleFont_Small;
//            break;
//        default:
//            _titleLabel.font = titleFont_Normal;
//            break;
//    }
    [self setNeedsLayout];
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
