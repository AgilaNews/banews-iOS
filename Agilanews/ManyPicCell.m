//
//  ManyPicCell.m
//  Agilanews
//
//  Created by 张思思 on 16/7/15.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "ManyPicCell.h"
#import "ImageModel.h"
#import "AppDelegate.h"

#define titleFont_Normal        [UIFont systemFontOfSize:16]
#define titleFont_ExtraLarge    [UIFont systemFontOfSize:20]
#define titleFont_Large         [UIFont systemFontOfSize:18]
#define titleFont_Small         [UIFont systemFontOfSize:14]

@implementation ManyPicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier bgColor:(UIColor *)bgColor
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgColor = bgColor;
        self.backgroundColor = bgColor;
        // 初始化子视图
        [self _initSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChange) name:KNOTIFICATION_FontSize_Change object:nil];
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
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.tagLabel];
    [self.contentView addSubview:self.sourceLabel];
    [self.contentView addSubview:self.timeView];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.imageViewOne];
    [self.contentView addSubview:self.imageViewTwo];
    [self.contentView addSubview:self.imageViewThree];
    
    __weak typeof(self) weakSelf = self;
    
    // 标题布局
    CGSize titleLabelSize = [_model.title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:self.titleLabel.font];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.top.mas_equalTo(11);
        make.width.mas_equalTo(titleLabelSize.width);
        make.height.mas_equalTo(titleLabelSize.height);
    }];
    // 图片1布局
    [self.imageViewOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).offset(10);
        make.width.mas_equalTo((kScreenWidth - 22 - 10) / 3.0);
        make.height.mas_equalTo(68);
    }];
    // 图片2布局
    [self.imageViewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.imageViewOne.mas_right).offset(5);
        make.top.mas_equalTo(weakSelf.imageViewOne.mas_top);
        make.width.mas_equalTo(weakSelf.imageViewOne.mas_width);
        make.height.mas_equalTo(68);
    }];
    // 图片3布局
    [self.imageViewThree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.imageViewTwo.mas_right).offset(5);
        make.top.mas_equalTo(weakSelf.imageViewOne.mas_top);
        make.width.mas_equalTo(weakSelf.imageViewOne.mas_width);
        make.height.mas_equalTo(68);
    }];
    // 标签布局
    CGSize tagLabelSize = [_model.tag calculateSize:CGSizeMake(100, 13) font:self.tagLabel.font];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.bottom.mas_equalTo(-7.5);
        make.width.mas_equalTo(tagLabelSize.width + 8);
        make.height.mas_equalTo(tagLabelSize.height + 2);
    }];
    // 来源布局
    CGSize sourceLabelSize = [_model.source calculateSize:CGSizeMake(300, 12) font:self.sourceLabel.font];
    [self.sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.tagLabel.mas_right);
        make.top.mas_equalTo(weakSelf.imageViewOne.mas_bottom).offset(10);
        make.width.mas_equalTo(sourceLabelSize.width);
        make.height.mas_equalTo(sourceLabelSize.height + 1);
    }];
    // 时钟布局
    [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.sourceLabel.mas_right).offset(20);
        make.centerY.mas_equalTo(weakSelf.sourceLabel.mas_centerY);
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(11);
    }];
    // 时间布局
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.timeView.mas_right).offset(5);
        make.centerY.mas_equalTo(weakSelf.sourceLabel.mas_centerY);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(13);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    __weak typeof(self) weakSelf = self;
    
    // 标题布局
    CGSize titleLabelSize = [_model.title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:self.titleLabel.font];
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(titleLabelSize.width);
        make.height.mas_equalTo(titleLabelSize.height);
    }];
    // 图片1布局
    [self.imageViewOne mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).offset(10);
    }];
    // 图片2布局
    [self.imageViewTwo mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.imageViewOne.mas_right).offset(5);
        make.top.mas_equalTo(weakSelf.imageViewOne.mas_top);
        make.width.mas_equalTo(weakSelf.imageViewOne.mas_width);
    }];
    // 图片3布局
    [self.imageViewThree mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.imageViewTwo.mas_right).offset(5);
        make.top.mas_equalTo(weakSelf.imageViewOne.mas_top);
        make.width.mas_equalTo(weakSelf.imageViewOne.mas_width);
    }];
    if (_model.tag.length > 0) {
        self.tagLabel.hidden = NO;
        // 标签布局
        CGSize tagLabelSize = [_model.tag calculateSize:CGSizeMake(100, 13) font:self.tagLabel.font];
        [self.tagLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
            make.bottom.mas_equalTo(-7.5);
            make.width.mas_equalTo(tagLabelSize.width + 8);
            make.height.mas_equalTo(tagLabelSize.height + 2);
        }];
        // 来源布局
        CGSize sourceLabelSize = [_model.source calculateSize:CGSizeMake(200, 12) font:self.sourceLabel.font];
        [self.sourceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.tagLabel.mas_right).offset(8);
            make.top.mas_equalTo(weakSelf.imageViewOne.mas_bottom).offset(10);
            make.width.mas_equalTo(sourceLabelSize.width);
            make.height.mas_equalTo(sourceLabelSize.height);
        }];
    } else {
        self.tagLabel.hidden = YES;
        // 标签布局
        [self.tagLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
            make.bottom.mas_equalTo(-7.5);
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
        // 来源布局
        CGSize sourceLabelSize = [_model.source calculateSize:CGSizeMake(200, 12) font:self.sourceLabel.font];
        [self.sourceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.tagLabel.mas_right);
            make.top.mas_equalTo(weakSelf.imageViewOne.mas_bottom).offset(10);
            make.width.mas_equalTo(sourceLabelSize.width);
            make.height.mas_equalTo(sourceLabelSize.height);
        }];
    }
    // 时钟布局
    [self.timeView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.sourceLabel.mas_right).offset(20);
        make.centerY.mas_equalTo(weakSelf.sourceLabel.mas_centerY);
    }];
    // 时间布局
    NSString *timeString = nil;
    if (_bgColor == [UIColor whiteColor]) {
        timeString = [TimeStampToString getNewsStringWhitTimeStamp:[_model.public_time longLongValue]];
    } else {
        timeString = [TimeStampToString getRecommendedNewsStringWhitTimeStamp:[_model.public_time longLongValue]];
    }
    CGSize timeLabelSize = [timeString calculateSize:CGSizeMake(80, 13) font:self.timeLabel.font];
    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(timeLabelSize.width);
        make.height.mas_equalTo(timeLabelSize.height);
        make.left.mas_equalTo(weakSelf.timeView.mas_right).offset(5);
        make.centerY.mas_equalTo(weakSelf.sourceLabel.mas_centerY);
    }];
    [super updateConstraints];
    
    self.titleLabel.text = _model.title;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([[appDelegate.checkDic valueForKey:_model.news_id] isEqualToNumber:@1]) {
        self.titleLabel.textColor = kGrayColor;
    } else {
        if (_bgColor == [UIColor whiteColor]) {
            _titleLabel.textColor = kBlackColor;
        } else {
            _titleLabel.textColor = SSColor(68, 68, 68);
        }
    }
    self.tagLabel.text = _model.tag;
    self.sourceLabel.text = _model.source;
    self.timeLabel.text = timeString;
    
    NSNumber *textOnlyMode = DEF_PERSISTENT_GET_OBJECT(SS_textOnlyMode);
    if ([textOnlyMode integerValue] == 1) {
        self.imageViewOne.contentMode = UIViewContentModeCenter;
        self.imageViewTwo.contentMode = UIViewContentModeCenter;
        self.imageViewThree.contentMode = UIViewContentModeCenter;
        self.imageViewOne.image = [UIImage imageNamed:@"holderImage"];
        self.imageViewTwo.image = [UIImage imageNamed:@"holderImage"];
        self.imageViewThree.image = [UIImage imageNamed:@"holderImage"];
        return;
    }
    NSArray *images = _model.imgs;
    for (int i = 0; i < 3; i++) {
        ImageModel *imageModel = images[i];
        NSString *imageUrl = [imageModel.pattern stringByReplacingOccurrencesOfString:@"{w}" withString:[NSString stringWithFormat:@"%d",(int)((kScreenWidth - 22 - 10) / 3.0 * 2)]];
        imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{h}" withString:[NSString stringWithFormat:@"%d",68 * 2]];
        imageUrl = [imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        switch (i) {
            case 0:
            {
                [self.imageViewOne sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"holderImage"] options:SDWebImageLowPriority | SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (!image) {
                        _imageViewOne.image = [UIImage imageNamed:@"holderImage"];
                    }
                }];
            }
                break;
            case 1:
            {
                [self.imageViewTwo sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"holderImage"] options:SDWebImageLowPriority | SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (!image) {
                        _imageViewTwo.image = [UIImage imageNamed:@"holderImage"];
                    }
                }];
            }
                break;
            case 2:
            {
                [self.imageViewThree sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"holderImage"] options:SDWebImageLowPriority | SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (!image) {
                        _imageViewThree.image = [UIImage imageNamed:@"holderImage"];
                    }
                }];
            }
                break;
            default:
                break;
        }
    }
}

- (UILabel *)titleLabel
{
    if (_titleLabel ==  nil) {
        _titleLabel = [[UILabel alloc] init];
        switch ([DEF_PERSISTENT_GET_OBJECT(SS_FontSize) integerValue]) {
            case 0:
                _titleLabel.font = titleFont_Normal;
                break;
            case 1:
                _titleLabel.font = titleFont_ExtraLarge;
                break;
            case 2:
                _titleLabel.font = titleFont_Large;
                break;
            case 3:
                _titleLabel.font = titleFont_Small;
                break;
            default:
                _titleLabel.font = titleFont_Normal;
                break;
        }
        if (_bgColor == [UIColor whiteColor]) {
            _titleLabel.textColor = kBlackColor;
        } else {
            _titleLabel.textColor = SSColor(68, 68, 68);
        }
        _titleLabel.backgroundColor = _bgColor;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UIImageView *)imageViewOne
{
    if (_imageViewOne == nil) {
        _imageViewOne = [[UIImageView alloc] init];
        _imageViewOne.backgroundColor = SSColor(235, 235, 235);
        _imageViewOne.contentMode = UIViewContentModeScaleAspectFit;
        _imageViewOne.clipsToBounds = YES;
        _imageViewOne.image = [UIImage imageNamed:@"holderImage"];
    }
    return _imageViewOne;
}

- (UIImageView *)imageViewTwo
{
    if (_imageViewTwo == nil) {
        _imageViewTwo = [[UIImageView alloc] init];
        _imageViewTwo.backgroundColor = SSColor(235, 235, 235);
        _imageViewTwo.contentMode = UIViewContentModeScaleAspectFit;
        _imageViewTwo.clipsToBounds = YES;
        _imageViewTwo.image = [UIImage imageNamed:@"holderImage"];
    }
    return _imageViewTwo;
}

- (UIImageView *)imageViewThree
{
    if (_imageViewThree == nil) {
        _imageViewThree = [[UIImageView alloc] init];
        _imageViewThree.backgroundColor = SSColor(235, 235, 235);
        _imageViewThree.contentMode = UIViewContentModeScaleAspectFit;
        _imageViewThree.clipsToBounds = YES;
        _imageViewThree.image = [UIImage imageNamed:@"holderImage"];
    }
    return _imageViewThree;
}

- (UILabel *)tagLabel
{
    if (_tagLabel == nil) {
        _tagLabel = [[UILabel alloc] init];
        _tagLabel.font = [UIFont systemFontOfSize:11];
        _tagLabel.backgroundColor = _bgColor;
        _tagLabel.textColor = kOrangeColor;
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        _tagLabel.layer.borderColor = kOrangeColor.CGColor;
        _tagLabel.layer.borderWidth = 1;
        _tagLabel.layer.cornerRadius = 2;
        _tagLabel.hidden = YES;
    }
    return _tagLabel;
}

- (UILabel *)sourceLabel
{
    if (_sourceLabel == nil) {
        _sourceLabel = [[UILabel alloc] init];
        _sourceLabel.font = [UIFont systemFontOfSize:12];
        _sourceLabel.backgroundColor = _bgColor;
        _sourceLabel.textColor = kGrayColor;
    }
    return _sourceLabel;
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
        _timeLabel.backgroundColor = _bgColor;
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = kGrayColor;
    }
    return _timeLabel;
}

- (void)fontChange
{
    switch ([DEF_PERSISTENT_GET_OBJECT(SS_FontSize) integerValue]) {
        case 0:
            _titleLabel.font = titleFont_Normal;
            break;
        case 1:
            _titleLabel.font = titleFont_ExtraLarge;
            break;
        case 2:
            _titleLabel.font = titleFont_Large;
            break;
        case 3:
            _titleLabel.font = titleFont_Small;
            break;
        default:
            _titleLabel.font = titleFont_Normal;
            break;
    }
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
