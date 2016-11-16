//
//  CommentCell.m
//  Agilanews
//
//  Created by 张思思 on 16/7/26.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "CommentCell.h"
#import "AppDelegate.h"

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
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.likeButton];
    [self.contentView addSubview:self.replyLabel];
    [self.contentView addSubview:self.replyContentLabel];
    [self.contentView addSubview:self.verticalLine];
    
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
    // 点赞按钮布局
    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-11);
        make.centerY.mas_equalTo(weakSelf.nameLabel.mas_centerY);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(40);
    }];
    // 评论时间布局
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.nameLabel.mas_left);
        make.top.mas_equalTo(weakSelf.contentLabel.mas_bottom).offset(5);
        make.height.mas_equalTo(12);
    }];
    // 评论回复按钮布局
    [self.replyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.timeLabel.mas_right);
        make.centerY.mas_equalTo(weakSelf.timeLabel.mas_centerY);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(20);
    }];
    // 评论回复布局
    [self.replyContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.nameLabel.mas_left).offset(7);
        make.top.mas_equalTo(weakSelf.timeLabel.mas_bottom).offset(11);
    }];
    // 竖线布局
    [self.verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.nameLabel.mas_left);
        make.top.mas_equalTo(weakSelf.timeLabel.mas_bottom).offset(9);
        make.width.mas_equalTo(3);
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
    // 点赞按钮布局
    [self.likeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-11);
        make.centerY.mas_equalTo(weakSelf.nameLabel.mas_centerY);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(40);
    }];
    // 评论时间布局
    NSString *time = [TimeStampToString getNewsStringWhitTimeStamp:[_model.time longLongValue]];
    CGSize timeLabelSize = [time calculateSize:CGSizeMake(120, 13) font:self.contentLabel.font];
    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.nameLabel.mas_left);
        make.top.mas_equalTo(weakSelf.contentLabel.mas_bottom).offset(6);
        make.width.mas_equalTo(timeLabelSize.width);
    }];
    // 评论回复按钮布局
    NSString *text = @"Reply";
    CGSize textSize = [text calculateSize:CGSizeMake(50, 20) font:[UIFont italicSystemFontOfSize:11]];
    [self.replyLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.timeLabel.mas_right);
        make.centerY.mas_equalTo(weakSelf.timeLabel.mas_centerY);
        make.width.mas_equalTo(textSize.width + 10);
        make.height.mas_equalTo(textSize.height + 5);
    }];
    // 评论回复布局
    CommentModel *commentModel = _model.reply;
    NSString *replyString = [NSString stringWithFormat:@"@%@: %@",commentModel.user_name,commentModel.comment];
    CGSize replyLabelSize = [replyString calculateSize:CGSizeMake(kScreenWidth - 11 - 7 - 55, 1000) font:self.replyContentLabel.font];
    [self.replyContentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.nameLabel.mas_left).offset(7);
        make.top.mas_equalTo(weakSelf.timeLabel.mas_bottom).offset(11);
        make.width.mas_equalTo(replyLabelSize.width);
        make.height.mas_equalTo(replyLabelSize.height);
    }];
    // 竖线布局
    [self.verticalLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.nameLabel.mas_left);
        make.top.mas_equalTo(weakSelf.timeLabel.mas_bottom).offset(9);
        make.width.mas_equalTo(3);
        make.height.mas_equalTo(replyLabelSize.height + 4);
    }];
    [super updateConstraints];

    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:_model.user_portrait_url] placeholderImage:[UIImage imageNamed:@"icon_comment_head"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            _avatarView.image = image;
        } else {
            _avatarView.image = [UIImage imageNamed:@"icon_comment_head"];
        }
    }];
    self.nameLabel.text = _model.user_name;
    self.contentLabel.text = _model.comment;
    self.timeLabel.text = time;
    NSNumber *likeNum = _model.device_liked;
    if (likeNum != nil && [likeNum isEqualToNumber:@1]) {
        self.likeButton.selected = YES;
    } else {
        self.likeButton.selected = NO;
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.model && [appDelegate.model.user_id isEqualToString:_model.user_id]) {
        _replyLabel.hidden = YES;
    } else {
        _replyLabel.hidden = NO;
    }
    if (commentModel.comment) {
        self.replyContentLabel.text = replyString;
        self.verticalLine.hidden = NO;
    } else {
        self.replyContentLabel.text = @"";
        self.verticalLine.hidden = YES;
    }
}

- (UIImageView *)avatarView
{
    if (_avatarView == nil) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.backgroundColor = kWhiteBgColor;
        _avatarView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarView.layer.cornerRadius = 17;
        _avatarView.layer.masksToBounds = YES;
    }
    return _avatarView;
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = kWhiteBgColor;
        _nameLabel.textColor = SSColor_RGB(102);
        _nameLabel.font = [UIFont systemFontOfSize:14];
    }
    return _nameLabel;
}

- (UILabel *)contentLabel
{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = kWhiteBgColor;
        _contentLabel.textColor = kBlackColor;
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:11];
        _timeLabel.textColor = kGrayColor;
    }
    return _timeLabel;
}

- (UIButton *)likeButton
{
    if (_likeButton == nil) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeButton.titleLabel.font = [UIFont systemFontOfSize:11];
        _likeButton.adjustsImageWhenHighlighted = NO;
        [_likeButton setTitleColor:SSColor(102, 102, 102) forState:UIControlStateNormal];
        [_likeButton setTitleColor:kOrangeColor forState:UIControlStateSelected];
        [_likeButton setImage:[UIImage imageNamed:@"icon_commentlike_d"] forState:UIControlStateNormal];
        [_likeButton setImage:[UIImage imageNamed:@"icon_commentlike_s"] forState:UIControlStateSelected];
    }
    if (_model.liked.integerValue > 0) {
        NSString *buttonTitle = [NSString stringWithFormat:@"%@",_model.liked];
        switch (buttonTitle.length) {
            case 1:
                _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 0);
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -2);
                [_likeButton setTitle:buttonTitle forState:UIControlStateNormal];
                break;
            case 2:
                _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 0);
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -6);
                [_likeButton setTitle:buttonTitle forState:UIControlStateNormal];
                break;
            case 3:
                _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 0);
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -14);
                [_likeButton setTitle:buttonTitle forState:UIControlStateNormal];
                break;
            case 4:
                _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 0);
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -22);
                [_likeButton setTitle:@"999+" forState:UIControlStateNormal];
                break;
            default:
                _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 0);
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -2);
                [_likeButton setTitle:buttonTitle forState:UIControlStateNormal];
                break;
        }
    } else {
        _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [_likeButton setTitle:@"" forState:UIControlStateNormal];
    }
    return _likeButton;
}

- (UILabel *)replyLabel
{
    if (_replyLabel == nil) {
        _replyLabel = [[UILabel alloc] init];
        _replyLabel.userInteractionEnabled = YES;
        _replyLabel.hidden = YES;
        _replyLabel.textAlignment = NSTextAlignmentCenter;
        NSString *text = @"Reply";
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:text];
        [attributedStr addAttributes:@{NSFontAttributeName : [UIFont italicSystemFontOfSize:11],
                                       NSForegroundColorAttributeName : SSColor(71, 174, 201),
                                       NSUnderlineStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle]
                                       } range:NSMakeRange(0, attributedStr.length)];
        _replyLabel.attributedText = attributedStr;
    }
    return _replyLabel;
}

- (UILabel *)replyContentLabel
{
    if (_replyContentLabel == nil) {
        _replyContentLabel = [[UILabel alloc] init];
        _replyContentLabel.font = [UIFont systemFontOfSize:13];
        _replyContentLabel.textColor = kGrayColor;
    }
    return _replyContentLabel;
}

- (UIView *)verticalLine
{
    if (_verticalLine == nil) {
        _verticalLine = [[UIView alloc] init];
        _verticalLine.backgroundColor = SSColor_RGB(204);
        _verticalLine.hidden = YES;
    }
    return _verticalLine;
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
