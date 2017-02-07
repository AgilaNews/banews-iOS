//
//  VideoDetailCell.m
//  Agilanews
//
//  Created by 张思思 on 16/10/31.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "VideoDetailCell.h"
#import "AppDelegate.h"
#import "VideoModel.h"

@implementation VideoDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier bgColor:(UIColor *)bgColor
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgColor = bgColor;
        self.backgroundColor = bgColor;

        [self _initSubviews];
    }
    return self;
}

- (void)_initSubviews
{
    [self addSubview:self.titleLabel];
    [self addSubview:self.sourceLabel];
    [self addSubview:self.watchView];
    [self addSubview:self.watchLabel];
    [self addSubview:self.contentLabel];
    [self addSubview:self.openButton];
    [self addSubview:self.likeButton];
    [self addSubview:self.facebookShare];
    
    __weak typeof(self) weakSelf = self;
    CGSize titleLabelSize = [_model.title calculateSize:CGSizeMake(kScreenWidth - 22, 80) font:self.titleLabel.font];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.top.mas_equalTo(11);
        make.width.mas_equalTo(titleLabelSize.width);
        make.height.mas_equalTo(titleLabelSize.height);
    }];
    CGSize sourceLabelSize = [_model.source calculateSize:CGSizeMake(kScreenWidth - 22 - 50 - 100, 13) font:self.sourceLabel.font];
    [self.sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).offset(6);
        make.width.mas_equalTo(sourceLabelSize.width);
        make.height.mas_equalTo(sourceLabelSize.height);
    }];
    [self.watchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.sourceLabel.mas_right).offset(20);
        make.centerY.mas_equalTo(weakSelf.sourceLabel.mas_centerY);
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(11);
    }];
    CGSize watchLabelSize = [_model.source calculateSize:CGSizeMake(100, 13) font:self.watchLabel.font];
    [self.watchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.watchView.mas_right).offset(5);
        make.centerY.mas_equalTo(weakSelf.sourceLabel.mas_centerY);
        make.width.mas_equalTo(watchLabelSize.width);
        make.height.mas_equalTo(watchLabelSize.height);
    }];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.top.mas_equalTo(weakSelf.sourceLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    [self.openButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(4);
        make.top.mas_equalTo(weakSelf.contentLabel.mas_top).offset(-6);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
    }];
    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo((kScreenWidth - 105 - 10 - 50) * .5);
        make.top.mas_equalTo(weakSelf.contentLabel.mas_bottom).offset(30);
        make.width.mas_equalTo(105);
        make.height.mas_equalTo(34);
    }];
    [self.facebookShare mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.likeButton.mas_right).offset(10);
        make.top.mas_equalTo(weakSelf.likeButton.mas_top);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(34);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    __weak typeof(self) weakSelf = self;
    NSString *titleString = [_model.title stringByReplacingOccurrencesOfString:@"<font>" withString:@""];
    titleString = [titleString stringByReplacingOccurrencesOfString:@"</font>" withString:@""];

    CGSize titleLabelSize = [titleString calculateSize:CGSizeMake(kScreenWidth - 22, 80) font:self.titleLabel.font];
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.top.mas_equalTo(11);
        make.width.mas_equalTo(titleLabelSize.width);
        make.height.mas_equalTo(titleLabelSize.height);
    }];
    CGSize sourceLabelSize = [_model.source calculateSize:CGSizeMake(kScreenWidth - 22 - 50 - 100, 13) font:self.sourceLabel.font];
    [self.sourceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).offset(6);
        make.width.mas_equalTo(sourceLabelSize.width);
        make.height.mas_equalTo(sourceLabelSize.height);
    }];
    [self.watchView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.sourceLabel.mas_right).offset(20);
        make.centerY.mas_equalTo(weakSelf.sourceLabel.mas_centerY);
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(11);
    }];
    NSString *views = [TimeStampToString getViewsStringWithNumber:_model.views];
    CGSize watchLabelSize = [views calculateSize:CGSizeMake(100, 13) font:self.watchLabel.font];
    [self.watchLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.watchView.mas_right).offset(5);
        make.centerY.mas_equalTo(weakSelf.sourceLabel.mas_centerY);
        make.width.mas_equalTo(watchLabelSize.width);
        make.height.mas_equalTo(watchLabelSize.height);
    }];
    VideoModel *model = _model.videos.firstObject;
    CGSize contentLabelSize = CGSizeZero;
    if (self.openButton.selected) {
        contentLabelSize = [model.content calculateSize:CGSizeMake(kScreenWidth - 22 - 20, 1500) font:self.contentLabel.font];
    } else {
        contentLabelSize = [model.content calculateSize:CGSizeMake(kScreenWidth - 22 - 20, 30) font:self.contentLabel.font];
    }
    [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.top.mas_equalTo(weakSelf.sourceLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(contentLabelSize.width);
        make.height.mas_equalTo(contentLabelSize.height);
    }];
    [self.openButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(4);
        make.top.mas_equalTo(weakSelf.contentLabel.mas_top).offset(-6);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
    }];
    [self.likeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo((kScreenWidth - 105 - 10 - 50) * .5);
        make.top.mas_equalTo(weakSelf.contentLabel.mas_bottom).offset(30);
        make.width.mas_equalTo(105);
        make.height.mas_equalTo(34);
    }];
    [self.facebookShare mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.likeButton.mas_right).offset(10);
        make.top.mas_equalTo(weakSelf.likeButton.mas_top);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(34);
    }];
    [super updateConstraints];

    self.titleLabel.text = titleString;
    self.sourceLabel.text = _model.source;
    self.watchLabel.text = views;
    self.contentLabel.text = model.content;
    if (_model.likedCount.integerValue > 0) {
        _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        NSString *buttonTitle = [NSString stringWithFormat:@"%@",_model.likedCount];
        switch (buttonTitle.length) {
            case 1:
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -4);
                [_likeButton setTitle:buttonTitle forState:UIControlStateNormal];
                break;
            case 2:
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -8);
                [_likeButton setTitle:buttonTitle forState:UIControlStateNormal];
                break;
            case 3:
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -12);
                [_likeButton setTitle:buttonTitle forState:UIControlStateNormal];
                break;
            default:
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -12);
                [_likeButton setTitle:@"999+" forState:UIControlStateNormal];
                break;
        }
    } else {
        _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
        [_likeButton setTitle:@"" forState:UIControlStateNormal];
    }
}

#pragma mark - setter/getter
- (UILabel *)titleLabel
{
    if (_titleLabel ==  nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = kWhiteBgColor;
        _titleLabel.textColor = kBlackColor;
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont boldSystemFontOfSize:20];
    }
    return _titleLabel;
}

- (UILabel *)sourceLabel
{
    if (_sourceLabel == nil) {
        _sourceLabel = [[UILabel alloc] init];
        _sourceLabel.font = [UIFont systemFontOfSize:12];
        _sourceLabel.backgroundColor = kWhiteBgColor;
        _sourceLabel.textColor = SSColor(102, 102, 102);
    }
    return _sourceLabel;
}

- (UIImageView *)watchView
{
    if (_watchView == nil) {
        _watchView = [[UIImageView alloc] init];
        _watchView.backgroundColor = kWhiteBgColor;
        _watchView.contentMode = UIViewContentModeScaleAspectFit;
        _watchView.image = [UIImage imageNamed:@"icon_video"];
    }
    return _watchView;
}

- (UILabel *)watchLabel
{
    if (_watchLabel == nil) {
        _watchLabel = [[UILabel alloc] init];
        _watchLabel.backgroundColor = kWhiteBgColor;
        _watchLabel.font = [UIFont systemFontOfSize:12];
        _watchLabel.textColor = SSColor(102, 102, 102);
    }
    return _watchLabel;
}

- (UILabel *)contentLabel
{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = kWhiteBgColor;
        _contentLabel.font = [UIFont systemFontOfSize:12];
        _contentLabel.textColor = kGrayColor;
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UIButton *)openButton
{
    if (_openButton == nil) {
        _openButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _openButton.imageView.backgroundColor = kWhiteBgColor;
        _openButton.titleLabel.backgroundColor = kWhiteBgColor;
        [_openButton setAdjustsImageWhenHighlighted:NO];
        [_openButton setImage:[UIImage imageNamed:@"icon_arrowdown"] forState:UIControlStateNormal];
        UIImage *closeImage = [UIImage imageWithCGImage:[UIImage imageNamed:@"icon_arrowdown"].CGImage scale:2 orientation:UIImageOrientationDown];
        [_openButton setImage:closeImage forState:UIControlStateSelected];
    }
    return _openButton;
}

// 点赞按钮
- (UIButton *)likeButton
{
    if (_likeButton == nil) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeButton.imageView.backgroundColor = kWhiteBgColor;
        _likeButton.titleLabel.backgroundColor = kWhiteBgColor;
        _likeButton.layer.cornerRadius = 17;
        _likeButton.layer.masksToBounds = YES;
        _likeButton.layer.borderWidth = 1;
        _likeButton.layer.borderColor = SSColor_RGB(204).CGColor;
        _likeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        [_likeButton setAdjustsImageWhenHighlighted:NO];
        [_likeButton setTitleColor:SSColor(102, 102, 102) forState:UIControlStateNormal];
        [_likeButton setTitleColor:kOrangeColor forState:UIControlStateSelected];
        [_likeButton setBackgroundColor:kWhiteBgColor forState:UIControlStateNormal];
        [_likeButton setImage:[UIImage imageNamed:@"icon_article_like_default"] forState:UIControlStateNormal];
        [_likeButton setImage:[UIImage imageNamed:@"icon_article_like_select"] forState:UIControlStateSelected];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if ([appDelegate.likedDic[_model.news_id] isEqual:@1]) {
            self.likeButton.selected = YES;
        } else {
            self.likeButton.selected = NO;
        }
    }
    if (_model.likedCount.integerValue > 0) {
        _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        NSString *buttonTitle = [NSString stringWithFormat:@"%@",_model.likedCount];
        switch (buttonTitle.length) {
            case 1:
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -4);
                [_likeButton setTitle:buttonTitle forState:UIControlStateNormal];
                break;
            case 2:
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -8);
                [_likeButton setTitle:buttonTitle forState:UIControlStateNormal];
                break;
            case 3:
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -12);
                [_likeButton setTitle:buttonTitle forState:UIControlStateNormal];
                break;
            default:
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -12);
                [_likeButton setTitle:@"999+" forState:UIControlStateNormal];
                break;
        }
    } else {
        _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
        [_likeButton setTitle:@"" forState:UIControlStateNormal];
    }
    return _likeButton;
}

// Facebook按钮
- (UIButton *)facebookShare
{
    if (_facebookShare == nil) {
        _facebookShare = [UIButton buttonWithType:UIButtonTypeCustom];
        _facebookShare.imageView.backgroundColor = kWhiteBgColor;
        _facebookShare.layer.cornerRadius = 17;
        _facebookShare.layer.masksToBounds = YES;
        _facebookShare.layer.borderWidth = 1;
        _facebookShare.layer.borderColor = SSColor_RGB(204).CGColor;
        [_facebookShare setAdjustsImageWhenHighlighted:NO];
        [_facebookShare setBackgroundColor:kWhiteBgColor forState:UIControlStateNormal];
        [_facebookShare setImage:[UIImage imageNamed:@"icon_article_facebook_default"] forState:UIControlStateNormal];
    }
    return _facebookShare;
}

- (void)setModel:(NewsModel *)model
{
    if (_model != model) {
        _model = model;
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if ([appDelegate.likedDic[_model.news_id] isEqual:@1]) {
            self.likeButton.selected = YES;
        } else {
            self.likeButton.selected = NO;
        }
    }
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
