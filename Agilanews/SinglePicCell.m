//
//  SinglePicCell.m
//  Agilanews
//
//  Created by 张思思 on 16/7/15.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "SinglePicCell.h"
#import "ImageModel.h"
#import "AppDelegate.h"
#import "FavoritesViewController.h"

#define titleFont_Normal        [UIFont systemFontOfSize:16]
#define titleFont_ExtraLarge    [UIFont systemFontOfSize:20]
#define titleFont_Large         [UIFont systemFontOfSize:18]
#define titleFont_Small         [UIFont systemFontOfSize:14]

@implementation SinglePicCell

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
    [self.contentView addSubview:self.commentView];
    [self.contentView addSubview:self.commentLabel];
    [self.contentView addSubview:self.titleImageView];
    [self.contentView addSubview:self.haveVideoView];
    [self.contentView addSubview:self.dislikeButton];
    
    __weak typeof(self) weakSelf = self;
    // 标题布局
    CGSize titleLabelSize = [_model.title calculateSize:CGSizeMake(kScreenWidth - 22 - 108 - 9, 60) font:self.titleLabel.font];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.top.mas_equalTo(9);
        make.width.mas_equalTo(titleLabelSize.width);
        make.height.mas_equalTo(titleLabelSize.height);
    }];
    // 标题图片布局
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(-11);
        make.top.mas_equalTo(12);
        make.width.mas_equalTo(108);
        make.height.mas_equalTo(68);
    }];
    // 标签布局
    CGSize tagLabelSize = [_model.tag calculateSize:CGSizeMake(100, 13) font:self.tagLabel.font];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.bottom.mas_equalTo(-6);
        make.width.mas_equalTo(tagLabelSize.width + 9);
        make.height.mas_equalTo(15);
    }];
    // 来源布局
    CGSize sourceLabelSize = [_model.source calculateSize:CGSizeMake(kScreenWidth - 22 - 9 - 108 - 60, 12) font:self.sourceLabel.font];
    [self.sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.tagLabel.mas_right);
        make.bottom.mas_equalTo(-7);
        make.width.mas_equalTo(sourceLabelSize.width);
        make.height.mas_equalTo(sourceLabelSize.height + 1);
    }];
    // 时钟布局
    [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.sourceLabel.mas_right).offset(15);
        make.centerY.mas_equalTo(weakSelf.sourceLabel.mas_centerY);
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(11);
    }];
    // 时间布局
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.timeView.mas_right).offset(6);
        make.centerY.mas_equalTo(weakSelf.sourceLabel.mas_centerY);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(13);
    }];
    // 评论布局
    [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.timeLabel.mas_right).offset(15);
        make.centerY.mas_equalTo(weakSelf.sourceLabel.mas_centerY);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(11);
    }];
    // 评论数布局
    [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.commentView.mas_right).offset(5);
        make.centerY.mas_equalTo(weakSelf.sourceLabel.mas_centerY);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(13);
    }];
    // 播放按钮
    [self.haveVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.titleImageView.mas_centerX);
        make.centerY.mas_equalTo(weakSelf.titleImageView.mas_centerY);
        make.width.mas_equalTo(27);
        make.height.mas_equalTo(27);
    }];
    // 不喜欢布局
    [self.dislikeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.titleImageView.mas_left).offset(5);
        make.bottom.mas_equalTo(weakSelf.titleImageView.mas_bottom).offset(12);
        make.width.mas_equalTo(34);
        make.height.mas_equalTo(34);
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
    float sourceLabelMinWidth = 0;
    if (_model.commentCount.integerValue > 0) {
        sourceLabelMinWidth = kScreenWidth - 22 - 9 - 108 - 50 - 22 - 50 - (_bgColor == [UIColor whiteColor] ? 5 : 0);
    } else {
        sourceLabelMinWidth = kScreenWidth - 22 - 9 - 108 - 50 - 22 - (_bgColor == [UIColor whiteColor] ? 5 : 0);
    }
    if (_model.tag.length > 0 && _bgColor == [UIColor whiteColor]) {
        self.tagLabel.hidden = NO;
        // 标签布局
        CGSize tagLabelSize = [_model.tag calculateSize:CGSizeMake(100, 13) font:self.tagLabel.font];
        [self.tagLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
            make.bottom.mas_equalTo(-6);
            make.width.mas_equalTo(tagLabelSize.width + 9);
            make.height.mas_equalTo(15);
        }];
        // 来源布局
        CGSize sourceLabelSize = [_model.source calculateSize:CGSizeMake(kScreenWidth - 22 - 9 - 108 - 60, 12) font:self.sourceLabel.font];
        [self.sourceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.tagLabel.mas_right).offset(8);
            make.bottom.mas_equalTo(-7);
            make.width.mas_equalTo(MIN(sourceLabelSize.width, sourceLabelMinWidth - tagLabelSize.width - 26));
            make.height.mas_equalTo(sourceLabelSize.height);
        }];
    } else {
        self.tagLabel.hidden = YES;
        // 标签布局
        [self.tagLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
            make.bottom.mas_equalTo(-6);
            make.width.mas_equalTo(0);
        }];
        // 来源布局
        CGSize sourceLabelSize = [_model.source calculateSize:CGSizeMake(kScreenWidth - 22 - 9 - 108 - 60, 12) font:self.sourceLabel.font];
        [self.sourceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.tagLabel.mas_right);
            make.bottom.mas_equalTo(-7);
            make.width.mas_equalTo(MIN(sourceLabelSize.width, sourceLabelMinWidth));
            make.height.mas_equalTo(sourceLabelSize.height);
        }];
    }
    // 时钟布局
    [self.timeView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.sourceLabel.mas_right).offset(15);
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
    
    // 获取tableView
    id tableView = self.superview;
    do {
        if ([tableView isKindOfClass:[UITableView class]]) {
            break;
        }
        tableView = ((UIView *)tableView).superview;
    } while (tableView != nil);
    if (((UITableView *)tableView).editing == YES && self.editingStyle != UITableViewCellEditingStyleDelete) {
        // 标题图片布局
        [self.titleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(-11 + 38);
        }];
    } else {
        // 标题图片布局
        [self.titleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(-11);
        }];
    }
    // 播放按钮
    [self.haveVideoView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.titleImageView.mas_centerX);
        make.centerY.mas_equalTo(weakSelf.titleImageView.mas_centerY);
    }];
    // 评论布局
    if (_model.commentCount.integerValue > 0) {
        [self.commentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.timeLabel.mas_right).offset(15);
            make.centerY.mas_equalTo(weakSelf.sourceLabel.mas_centerY);
            make.width.mas_equalTo(12);
            make.height.mas_equalTo(11);
        }];
        CGSize commentLabelSize = [_model.commentCount.stringValue calculateSize:CGSizeMake(80, 13) font:self.commentLabel.font];
        [self.commentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.commentView.mas_right).offset(5);
            make.centerY.mas_equalTo(weakSelf.sourceLabel.mas_centerY);
            make.width.mas_equalTo(commentLabelSize.width);
            make.height.mas_equalTo(commentLabelSize.height);
        }];
        self.commentView.hidden = NO;
        self.commentLabel.hidden = NO;
        self.commentLabel.text = _model.commentCount.stringValue;
    } else {
        self.commentView.hidden = YES;
        self.commentLabel.hidden = YES;
    }
    // 不喜欢布局
    [self.dislikeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.titleImageView.mas_left).offset(5);
        make.bottom.mas_equalTo(weakSelf.titleImageView.mas_bottom).offset(12);
        make.width.mas_equalTo(34);
        make.height.mas_equalTo(34);
    }];
    [super updateConstraints];

    // 设置内容
    self.titleLabel.text = _model.title;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([[appDelegate.checkDic valueForKey:_model.news_id] isEqualToNumber:@1] && ![self.ViewController isKindOfClass:[FavoritesViewController class]]) {
        self.titleLabel.textColor = kGrayColor;
    } else {
        if (_bgColor == [UIColor whiteColor]) {
            _titleLabel.textColor = kBlackColor;
        } else {
            _titleLabel.textColor = SSColor(68, 68, 68);
        }
    }
    if (_bgColor == [UIColor whiteColor]) {
        self.dislikeButton.hidden = NO;
    } else {
        self.dislikeButton.hidden = YES;
    }
    self.tagLabel.text = _model.tag;
    self.sourceLabel.text = _model.source;
    self.timeLabel.text = timeString;
    
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
    [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"holderImage"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) {
            _titleImageView.image = [UIImage imageNamed:@"holderImage"];
        } else {
            _titleImageView.image = image;
        }
    }];
    if (self.isHaveVideo) {
        self.haveVideoView.hidden = NO;
    } else {
        self.haveVideoView.hidden = YES;
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

- (UIImageView *)haveVideoView
{
    if (_haveVideoView == nil) {
        _haveVideoView = [[UIImageView alloc] init];
        _haveVideoView.contentMode = UIViewContentModeScaleAspectFit;
        _haveVideoView.image = [UIImage imageNamed:@"play_small"];
        _haveVideoView.hidden = YES;
    }
    return _haveVideoView;
}

- (UIImageView *)commentView
{
    if (_commentView == nil) {
        _commentView = [[UIImageView alloc] init];
        _commentView.contentMode = UIViewContentModeScaleAspectFit;
        _commentView.image = [UIImage imageNamed:@"comment"];
        _commentView.hidden = YES;
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
        _commentLabel.hidden = YES;
    }
    return _commentLabel;
}

- (UIButton *)dislikeButton
{
    if (_dislikeButton == nil) {
        _dislikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dislikeButton setImage:[UIImage imageNamed:@"icon_dislike"] forState:UIControlStateNormal];
        [_dislikeButton setAdjustsImageWhenHighlighted:NO];
    }
    return _dislikeButton;
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
