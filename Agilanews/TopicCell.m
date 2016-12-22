//
//  TopicCell.m
//  Agilanews
//
//  Created by 张思思 on 16/12/21.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "TopicCell.h"
#import "ImageModel.h"

#define imageHeight 162 * kScreenWidth / 320.0


@implementation TopicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        // 初始化子视图
        [self _initSubviews];
    }
    return self;
}

/**
 *  初始化子视图
 */
- (void)_initSubviews
{
    [self.contentView addSubview:self.titleImageView];
    [self.titleImageView addSubview:self.shadowView];
    [self.titleImageView addSubview:self.titleLabel];
    [self.contentView addSubview:self.tagLabel];
    [self.contentView addSubview:self.timeView];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.dislikeButton];

    __weak typeof(self) weakSelf = self;
    // 标题图片布局
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(imageHeight);
    }];
    // 遮罩布局
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(0);
    }];
    // 标题布局
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.bottom.mas_equalTo(-8);
        make.width.mas_equalTo(kScreenWidth - 22);
        make.height.mas_equalTo(40);
    }];
    // 标签布局
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.bottom.mas_equalTo(-9);
        make.width.mas_equalTo(10);
        make.height.mas_equalTo(15);
    }];
    // 时钟布局
    [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_right).offset(15);
        make.centerY.mas_equalTo(weakSelf.tagLabel.mas_centerY);
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(11);
    }];
    // 时间布局
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.timeView.mas_right).offset(6);
        make.centerY.mas_equalTo(weakSelf.tagLabel.mas_centerY);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(13);
    }];
    // 不喜欢布局
    [self.dislikeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(weakSelf.tagLabel.mas_centerY);
        make.width.mas_equalTo(34);
        make.height.mas_equalTo(34);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    __weak typeof(self) weakSelf = self;
    
    // 标题图片布局
    [self.titleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(imageHeight);
    }];
    CGSize titleLabelSize = [_model.title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:self.titleLabel.font];
    // 遮罩布局
    [self.shadowView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(titleLabelSize.height + 10);
        _gradientLayer.frame = CGRectMake(0, 0, kScreenWidth, titleLabelSize.height + 10);
    }];
    // 标题布局
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.bottom.mas_equalTo(-8);
        make.width.mas_equalTo(kScreenWidth - 22);
        make.height.mas_equalTo(titleLabelSize.height);
    }];
    // 标签布局
    CGSize tagLabelSize = [_model.tag calculateSize:CGSizeMake(100, 13) font:self.tagLabel.font];
    [self.tagLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.bottom.mas_equalTo(-9);
        make.width.mas_equalTo(tagLabelSize.width + 9);
        make.height.mas_equalTo(15);
    }];
    // 时钟布局
    [self.timeView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.tagLabel.mas_right).offset(15);
        make.centerY.mas_equalTo(weakSelf.tagLabel.mas_centerY);
    }];
    // 时间布局
    NSString *timeString = [TimeStampToString getNewsStringWhitTimeStamp:[_model.public_time longLongValue]];
    CGSize timeLabelSize = [timeString calculateSize:CGSizeMake(80, 13) font:self.timeLabel.font];
    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(timeLabelSize.width);
        make.height.mas_equalTo(timeLabelSize.height);
        make.left.mas_equalTo(weakSelf.timeView.mas_right).offset(5);
        make.centerY.mas_equalTo(weakSelf.tagLabel.mas_centerY);
    }];
    // 不喜欢布局
    [self.dislikeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(weakSelf.tagLabel.mas_centerY);
        make.width.mas_equalTo(34);
        make.height.mas_equalTo(34);
    }];
    [super updateConstraints];
    
    // 设置内容
    self.titleLabel.text = _model.title;
    self.tagLabel.text = _model.tag;
    self.timeLabel.text = timeString;
    if (_model.filter_tags.count) {
        self.dislikeButton.hidden = NO;
    } else {
        self.dislikeButton.hidden = YES;
    }
    NSNumber *textOnlyMode = DEF_PERSISTENT_GET_OBJECT(SS_textOnlyMode);
    if ([textOnlyMode integerValue] == 1) {
        self.titleImageView.contentMode = UIViewContentModeCenter;
        self.titleImageView.image = [UIImage imageNamed:@"holderImage"];
        return;
    }
    self.titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    ImageModel *imageModel = _model.imgs.firstObject;
    NSString *imageUrl = [imageModel.pattern stringByReplacingOccurrencesOfString:@"{w}" withString:[NSString stringWithFormat:@"%d",((int)kScreenWidth * 2)]];
    imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{h}" withString:[NSString stringWithFormat:@"%d",(int)(imageHeight * 2)]];
    imageUrl = [imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"holderImage"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) {
            _titleImageView.image = [UIImage imageNamed:@"holderImage"];
        } else {
            _titleImageView.image = image;
        }
    }];
}

- (UIImageView *)titleImageView
{
    if (_titleImageView == nil) {
        _titleImageView = [[UIImageView alloc] init];
        _titleImageView.backgroundColor = SSColor(235, 235, 235);
        _titleImageView.contentMode = UIViewContentModeScaleAspectFit;
        _titleImageView.clipsToBounds = YES;
        _titleImageView.image = [UIImage imageNamed:@"holderImage"];
    }
    return _titleImageView;
}

- (UIView *)shadowView
{
    if (_shadowView == nil) {
        _shadowView = [[UIView alloc] init];
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor, (__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:.4].CGColor, (__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:.7].CGColor];
        _gradientLayer.locations = @[@0, @0.5, @1.0];
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint = CGPointMake(0, 1.0);
        [_shadowView.layer addSublayer:_gradientLayer];
    }
    return _shadowView;
}

- (UILabel *)titleLabel
{
    if (_titleLabel ==  nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)tagLabel
{
    if (_tagLabel == nil) {
        _tagLabel = [[UILabel alloc] init];
        _tagLabel.font = [UIFont systemFontOfSize:10];
        _tagLabel.backgroundColor = SSColor(78, 173, 240);
        _tagLabel.textColor = [UIColor whiteColor];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        _tagLabel.layer.cornerRadius = 7.5;
        _tagLabel.layer.masksToBounds = YES;
    }
    return _tagLabel;
}

- (UIImageView *)timeView
{
    if (_timeView == nil) {
        _timeView = [[UIImageView alloc] init];
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
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = kGrayColor;
    }
    return _timeLabel;
}

- (UIButton *)dislikeButton
{
    if (_dislikeButton == nil) {
        _dislikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dislikeButton setImage:[UIImage imageNamed:@"icon_dislike"] forState:UIControlStateNormal];
        [_dislikeButton setAdjustsImageWhenHighlighted:NO];
        _dislikeButton.hidden = YES;
    }
    return _dislikeButton;
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
