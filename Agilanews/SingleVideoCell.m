//
//  SingleVideoCell.m
//  Agilanews
//
//  Created by 张思思 on 16/11/3.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "SingleVideoCell.h"
#import "ImageModel.h"
#import "VideoModel.h"
#import "AppDelegate.h"

#define titleFont_Normal        [UIFont systemFontOfSize:16]
#define titleFont_ExtraLarge    [UIFont systemFontOfSize:20]
#define titleFont_Large         [UIFont systemFontOfSize:18]
#define titleFont_Small         [UIFont systemFontOfSize:14]

@implementation SingleVideoCell

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
    [self.contentView addSubview:self.titleImageView];
    [self.titleImageView addSubview:self.playView];
    [self.titleImageView addSubview:self.durationLabel];
    [self.contentView addSubview:self.tagLabel];
    [self.contentView addSubview:self.watchView];
    [self.contentView addSubview:self.watchLabel];
    [self.contentView addSubview:self.commentView];
    [self.contentView addSubview:self.commentLabel];
    
    __weak typeof(self) weakSelf = self;
    // 标题布局
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.top.mas_equalTo(9);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(60);
    }];
    // 标题图片布局
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(-11);
        make.top.mas_equalTo(12);
        make.width.mas_equalTo(108);
        make.height.mas_equalTo(68);
    }];
    // 播放按钮
    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.titleImageView.mas_centerX);
        make.centerY.mas_equalTo(weakSelf.titleImageView.mas_centerY);
        make.width.mas_equalTo(27);
        make.height.mas_equalTo(27);
    }];
    // 时长布局
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-2);
        make.bottom.mas_equalTo(-2);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(20);
    }];
    // 标签布局
    CGSize tagLabelSize = [_model.tag calculateSize:CGSizeMake(100, 13) font:self.tagLabel.font];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.bottom.mas_equalTo(-14);
        make.width.mas_equalTo(tagLabelSize.width + 9);
        make.height.mas_equalTo(15);
    }];
    // 观看视图布局
    [self.watchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-7);
        make.left.mas_equalTo(weakSelf.tagLabel.mas_right);
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(11);
    }];
    // 观看量布局
    [self.watchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.watchView.mas_right).offset(5);
        make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(14);
    }];
    // 评论视图布局
    [self.commentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.watchLabel.mas_right).offset(15);
        make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(11);
    }];
    // 评论数布局
    [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.commentView.mas_right).offset(5);
        make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(13);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    __weak typeof(self) weakSelf = self;
    // 标题布局
    CGSize titleLabelSize = [_model.title calculateSize:CGSizeMake(kScreenWidth - 22 - 108 - 9, 60) font:self.titleLabel.font];
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(titleLabelSize.width);
        make.height.mas_equalTo(titleLabelSize.height);
    }];
    // 标题图片布局
    [self.titleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(-11);
    }];
    // 播放按钮
    [self.playView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.titleImageView.mas_centerX);
        make.centerY.mas_equalTo(weakSelf.titleImageView.mas_centerY);
    }];
    // 时长布局
    VideoModel *model = _model.videos.firstObject;
    // 时长布局
    NSInteger hour;
    NSInteger minute = model.duration.integerValue / 60;
    NSInteger second = model.duration.integerValue % 60;
    NSString *dateString = nil;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSString *durationString = nil;
    if (minute > 60) {
        hour = minute / 60;
        minute = minute - hour * 60;
        dateString = [NSString stringWithFormat:@"%ld:%ld:%ld",(long)hour,(long)minute,(long)second];
        [dateFormat setDateFormat:@"h:m:s"];
        NSDate *date = [dateFormat dateFromString:dateString];
        [dateFormat setDateFormat:@"hh:mm:ss"];
        durationString = [dateFormat stringFromDate:date];
    } else {
        dateString = [NSString stringWithFormat:@"%ld:%ld",(long)minute,(long)second];
        [dateFormat setDateFormat:@"m:s"];
        NSDate *date = [dateFormat dateFromString:dateString];
        [dateFormat setDateFormat:@"mm:ss"];
        durationString = [dateFormat stringFromDate:date];
    }
    CGSize durationLabelSize = [durationString calculateSize:CGSizeMake(80, 20) font:self.durationLabel.font];
    [self.durationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(durationLabelSize.width + 4);
        make.height.mas_equalTo(durationLabelSize.height);
    }];
    // 标签布局
    if (_model.tag.length > 0 && _bgColor == [UIColor whiteColor]) {
        self.tagLabel.hidden = NO;
        CGSize tagLabelSize = [_model.tag calculateSize:CGSizeMake(100, 13) font:self.tagLabel.font];
        [self.tagLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
            make.bottom.mas_equalTo(-14);
            make.width.mas_equalTo(tagLabelSize.width + 9);
            make.height.mas_equalTo(15);
        }];
        [self.watchView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-7);
            make.left.mas_equalTo(weakSelf.tagLabel.mas_right);
            make.width.mas_equalTo(11);
            make.height.mas_equalTo(11);
        }];
    } else {
        self.tagLabel.hidden = YES;
        [self.tagLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
            make.bottom.mas_equalTo(-14);
            make.width.mas_equalTo(0);
        }];
        [self.watchView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-7);
            make.left.mas_equalTo(weakSelf.tagLabel.mas_right);
            make.width.mas_equalTo(11);
            make.height.mas_equalTo(11);
        }];
    }
    // 观看量布局
    NSString *views = [TimeStampToString getViewsStringWithNumber:_model.views];
    CGSize watchLabelSize = [views calculateSize:CGSizeMake(100, 14) font:self.watchLabel.font];
    [self.watchLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.watchView.mas_right).offset(5);
        make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
        make.width.mas_equalTo(watchLabelSize.width);
        make.height.mas_equalTo(watchLabelSize.height);
    }];
    // 评论视图布局
    [self.commentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.watchLabel.mas_right).offset(15);
        make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(11);
    }];
    // 评论数布局
    CGSize commentLabelSize = [_model.commentCount.stringValue calculateSize:CGSizeMake(100, 13) font:self.commentLabel.font];
    [self.commentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.commentView.mas_right).offset(5);
        make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
        make.width.mas_equalTo(commentLabelSize.width);
        make.height.mas_equalTo(commentLabelSize.height);
    }];
    [super updateConstraints];

    // 设置内容
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
    self.durationLabel.text = durationString;
    self.watchLabel.text = views;
    if (_model.commentCount.integerValue > 0) {
        self.commentLabel.text = _model.commentCount.stringValue;
    } else {
        self.commentLabel.text = @"";
    }
    
    NSNumber *textOnlyMode = DEF_PERSISTENT_GET_OBJECT(SS_textOnlyMode);
    if ([textOnlyMode integerValue] == 1) {
        self.titleImageView.contentMode = UIViewContentModeCenter;
        self.titleImageView.image = [UIImage imageNamed:@"holderImage"];
        return;
    }
    ImageModel *imageModel = _model.imgs.firstObject;
    NSString *imageUrl = [imageModel.pattern stringByReplacingOccurrencesOfString:@"{w}" withString:[NSString stringWithFormat:@"%d",(108 * 2)]];
    imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{h}" withString:[NSString stringWithFormat:@"%d",68 * 2]];
    imageUrl = [imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            _titleImageView.image = image;
        }
    }];
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

- (UIImageView *)titleImageView
{
    if (_titleImageView == nil) {
        _titleImageView = [[UIImageView alloc] init];
        _titleImageView.backgroundColor = SSColor(235, 235, 235);
        _titleImageView.contentMode = UIViewContentModeScaleAspectFit;
        _titleImageView.clipsToBounds = YES;
    }
    return _titleImageView;
}

- (UIImageView *)playView
{
    if (_playView == nil) {
        _playView = [[UIImageView alloc] init];
        _playView.contentMode = UIViewContentModeScaleAspectFit;
        _playView.image = [UIImage imageNamed:@"icon_video_play"];
    }
    return _playView;
}

- (UILabel *)durationLabel
{
    if (_durationLabel == nil) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
        _durationLabel.font = [UIFont systemFontOfSize:10];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        _durationLabel.layer.cornerRadius = 2;
        _durationLabel.layer.masksToBounds = YES;
    }
    return _durationLabel;
}

- (UILabel *)tagLabel
{
    if (_tagLabel == nil) {
        _tagLabel = [[UILabel alloc] init];
        _tagLabel.font = [UIFont systemFontOfSize:10];
        _tagLabel.backgroundColor = SSColor(255, 91, 54);
        _tagLabel.textColor = [UIColor whiteColor];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        _tagLabel.layer.cornerRadius = 7.5;
        _tagLabel.layer.masksToBounds = YES;
        _tagLabel.hidden = YES;
    }
    return _tagLabel;
}

- (UIImageView *)watchView
{
    if (_watchView == nil) {
        _watchView = [[UIImageView alloc] init];
        _watchView.backgroundColor = _bgColor;
        _watchView.contentMode = UIViewContentModeScaleAspectFit;
        _watchView.image = [UIImage imageNamed:@"icon_video_recommendplay"];
    }
    return _watchView;
}

- (UILabel *)watchLabel
{
    if (_watchLabel == nil) {
        _watchLabel = [[UILabel alloc] init];
        _watchLabel.backgroundColor = _bgColor;
        _watchLabel.font = [UIFont systemFontOfSize:12];
        _watchLabel.textColor = kGrayColor;
    }
    return _watchLabel;
}

- (UIImageView *)commentView
{
    if (_commentView == nil) {
        _commentView = [[UIImageView alloc] init];
        _commentView.backgroundColor = _bgColor;
        _commentView.contentMode = UIViewContentModeScaleAspectFit;
        _commentView.image = [UIImage imageNamed:@"comment"];
    }
    return _commentView;
}

- (UILabel *)commentLabel
{
    if (_commentLabel == nil) {
        _commentLabel = [[UILabel alloc] init];
        _commentLabel.backgroundColor = _bgColor;
        _commentLabel.font = [UIFont systemFontOfSize:12];
        _commentLabel.textColor = kGrayColor;
    }
    return _commentLabel;
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
