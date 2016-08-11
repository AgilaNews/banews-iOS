//
//  CommentCell.m
//  Agilanews
//
//  Created by 张思思 on 16/7/26.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kWhiteBgColor;
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        // 初始化子视图
        [self _initSubviews];
    }
    return self;
}

- (void)_initSubviews
{
    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.timeView];
    [self.contentView addSubview:self.timeLabel];
    
    __weak typeof(self) weakSelf = self;
    // 头像布局
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.top.mas_equalTo(10);
        make.width.mas_equalTo(34);
        make.height.mas_equalTo(34);
    }];
    
    // 用户名布局
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.avatarView.mas_right).offset(10);
        make.top.mas_equalTo(weakSelf.avatarView.mas_top).offset(4);
        make.height.mas_equalTo(17);
    }];
    
    // 评论内容布局
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.nameLabel.mas_left);
        make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom).offset(8);
    }];
    
    // 评论时间布局
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-11);
        make.centerY.mas_equalTo(weakSelf.nameLabel.mas_centerY);
        make.height.mas_equalTo(13);
    }];
    
    // 时钟布局
    [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.timeLabel.mas_left).offset(-5);
        make.centerY.mas_equalTo(weakSelf.nameLabel.mas_centerY);
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(11);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    __weak typeof(self) weakSelf = self;
    // 用户名布局
    CGSize nameLabelSize = [_model.user_name calculateSize:CGSizeMake(kScreenWidth - 55 - 60, 17) font:self.nameLabel.font];
    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.avatarView.mas_right).offset(10);
        make.top.mas_equalTo(weakSelf.avatarView.mas_top).offset(4);
        make.width.mas_equalTo(nameLabelSize.width);
    }];
    // 评论内容布局
    CGSize commentLabelSize = [_model.comment calculateSize:CGSizeMake(kScreenWidth - 55 - 11, 1000) font:self.contentLabel.font];
    [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.nameLabel.mas_left);
        make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom).offset(8);
        make.width.mas_equalTo(commentLabelSize.width);
        make.height.mas_equalTo(commentLabelSize.height);
    }];
    // 评论时间布局
    NSString *time = [TimeStampToString getNewsStringWhitTimeStamp:[_model.time longLongValue]];
    CGSize timeLabelSize = [time calculateSize:CGSizeMake(120, 13) font:self.contentLabel.font];
    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.nameLabel.mas_centerY);
        make.width.mas_equalTo(timeLabelSize.width);
    }];
    // 时钟布局
    [self.timeView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.timeLabel.mas_left).offset(-5);
        make.centerY.mas_equalTo(weakSelf.nameLabel.mas_centerY);
    }];
    [super updateConstraints];

    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:_model.user_portrait_url] placeholderImage:[UIImage imageNamed:@"icon_sidebar_head"] options:SDWebImageLowPriority | SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image)
        {
            weakSelf.avatarView.image = [weakSelf.avatarView.image yal_imageWithRoundedCornersAndSize:weakSelf.avatarView.frame.size andCornerRadius:weakSelf.avatarView.height * 0.5];
        } else
        {
            weakSelf.avatarView.image = [UIImage imageNamed:@"icon_sidebar_head"];
        }
    }];
    self.nameLabel.text = _model.user_name;
    self.contentLabel.text = _model.comment;
    self.timeLabel.text = time;
}

- (UIImageView *)avatarView
{
    if (_avatarView == nil) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.backgroundColor = kWhiteBgColor;
        _avatarView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _avatarView;
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = kWhiteBgColor;
        _nameLabel.textColor = kGrayColor;
        _nameLabel.font = [UIFont systemFontOfSize:16];
    }
    return _nameLabel;
}

- (UILabel *)contentLabel
{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = kWhiteBgColor;
        _contentLabel.textColor = kBlackColor;
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UIImageView *)timeView
{
    if (_timeView == nil) {
        _timeView = [[UIImageView alloc] init];
        _timeView.backgroundColor = kWhiteBgColor;
        _timeView.contentMode = UIViewContentModeScaleAspectFill;
        _timeView.clipsToBounds = YES;
        _timeView.image = [UIImage imageNamed:@"clock"];
    }
    return _timeView;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = kGrayColor;
    }
    return _timeLabel;
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
