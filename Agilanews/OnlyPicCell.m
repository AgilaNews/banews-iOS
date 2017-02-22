//
//  OnlyPicCell.m
//  Agilanews
//
//  Created by 张思思 on 16/7/15.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "OnlyPicCell.h"
#import "ImageModel.h"
#import "AppDelegate.h"
#import "HomeTableViewController.h"

#define titleFont_Normal        [UIFont systemFontOfSize:16]
#define titleFont_ExtraLarge    [UIFont systemFontOfSize:20]
#define titleFont_Large         [UIFont systemFontOfSize:18]
#define titleFont_Small         [UIFont systemFontOfSize:14]

@implementation OnlyPicCell 

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
//    [self.contentView addSubview:self.watchView];
//    [self.contentView addSubview:self.watchLabel];
    [self.contentView addSubview:self.likeButton];
    [self.contentView addSubview:self.commentView];
    [self.contentView addSubview:self.commentLabel];
    [self.contentView addSubview:self.shareButton];

    __weak typeof(self) weakSelf = self;
    // 标题布局
    CGSize titleLabelSize = [_model.title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:self.titleLabel.font];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.top.mas_equalTo(11);
        make.width.mas_equalTo(kScreenWidth - 22);
        make.height.mas_equalTo(titleLabelSize.height);
    }];
    // 标题图片布局
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(kScreenWidth - 22);
        make.height.mas_equalTo(500);
    }];
//    // 观看视图布局
//    [self.watchView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(weakSelf.titleImageView.mas_bottom).offset(15.5);
//        make.left.mas_equalTo(11);
//        make.width.mas_equalTo(11);
//        make.height.mas_equalTo(11);
//    }];
//    // 观看量布局
//    [self.watchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(weakSelf.watchView.mas_right).offset(5);
//        make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
//        make.width.mas_equalTo(0);
//        make.height.mas_equalTo(0);
//    }];
    // 点赞按钮布局
    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.top.mas_equalTo(weakSelf.titleImageView.mas_bottom).offset(1);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(40);
    }];
    // 分享按钮布局
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(weakSelf.likeButton.mas_centerY);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
    }];
    // 评论数布局
    [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.shareButton.mas_left).offset(-27);
        make.centerY.mas_equalTo(weakSelf.likeButton.mas_centerY);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(0);
    }];
    // 评论视图布局
    [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.commentLabel.mas_left).offset(-6);
        make.centerY.mas_equalTo(weakSelf.likeButton.mas_centerY);
        make.width.mas_equalTo(18);
        make.height.mas_equalTo(18);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    __weak typeof(self) weakSelf = self;
    
    // 标题布局
    CGSize titleLabelSize = [_model.title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:self.titleLabel.font];
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenWidth - 22);
        make.height.mas_equalTo(titleLabelSize.height);
    }];
    // 标题图片布局
    ImageModel *imageModel = _model.imgs.firstObject;
    CGFloat height = imageModel.height.floatValue / 2.0;
    [self.titleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(kScreenWidth - 22);
        make.height.mas_equalTo(height);
    }];
//    // 观看视图布局
//    [self.watchView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(weakSelf.titleImageView.mas_bottom).offset(15.5);
//        make.left.mas_equalTo(11);
//        make.width.mas_equalTo(11);
//        make.height.mas_equalTo(11);
//    }];
//    // 观看量布局
//    NSString *views = [TimeStampToString getViewsStringWithNumber:_model.views];
//    CGSize watchLabelSize = [views calculateSize:CGSizeMake(100, 14) font:self.watchLabel.font];
//    [self.watchLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(weakSelf.watchView.mas_right).offset(5);
//        make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
//        make.width.mas_equalTo(watchLabelSize.width);
//        make.height.mas_equalTo(watchLabelSize.height);
//    }];
    // 点赞按钮布局
    [self.likeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.top.mas_equalTo(weakSelf.titleImageView.mas_bottom).offset(1);
    }];
    // 分享按钮布局
    [self.shareButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(weakSelf.likeButton.mas_centerY);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
    }];
    // 评论数布局
    if (_model.commentCount.integerValue > 0) {
        CGSize commentLabelSize = [_model.commentCount.stringValue calculateSize:CGSizeMake(100, 13) font:self.commentLabel.font];
        [self.commentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf.shareButton.mas_left).offset(-27);
            make.centerY.mas_equalTo(weakSelf.likeButton.mas_centerY);
            make.width.mas_equalTo(commentLabelSize.width);
            make.height.mas_equalTo(commentLabelSize.height);
        }];
    } else {
        [self.commentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf.shareButton.mas_left).offset(-27);
            make.centerY.mas_equalTo(weakSelf.likeButton.mas_centerY);
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
    }
    // 评论视图布局
    [self.commentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.commentLabel.mas_left).offset(-6);
        make.centerY.mas_equalTo(weakSelf.likeButton.mas_centerY);
        make.width.mas_equalTo(18);
        make.height.mas_equalTo(18);
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
//    if (_model.views.integerValue > 0) {
//        self.watchLabel.text = views;
//    } else {
//        self.watchLabel.text = @"";
//    }
    if (_model.commentCount.integerValue > 0) {
        self.commentLabel.text = _model.commentCount.stringValue;
    } else {
        self.commentLabel.text = @"";
    }
    
    self.titleImageView.contentMode = UIViewContentModeCenter;
    NSNumber *textOnlyMode = DEF_PERSISTENT_GET_OBJECT(SS_textOnlyMode);
    if ([textOnlyMode integerValue] == 1) {
        self.titleImageView.image = [UIImage imageNamed:@"holderImage"];
        return;
    }
    NSString *imageUrl = [imageModel.pattern stringByReplacingOccurrencesOfString:@"{w}" withString:[NSString stringWithFormat:@"%d",(int)((kScreenWidth - 22) * 2)]];
    imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{h}" withString:[NSString stringWithFormat:@"%d",(int)(height * 2)]];
    imageUrl = [imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"holderImage"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) {
            _titleImageView.image = [UIImage imageNamed:@"holderImage"];
        } else {
            _titleImageView.contentMode = UIViewContentModeScaleAspectFit;
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
        _titleImageView.contentMode = UIViewContentModeCenter;
        _titleImageView.clipsToBounds = YES;
        _titleImageView.image = [UIImage imageNamed:@"holderImage"];
        _titleImageView.userInteractionEnabled = YES;
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
//        [_titleImageView addGestureRecognizer:tap];
    }
    return _titleImageView;
}

//- (UIImageView *)watchView
//{
//    if (_watchView == nil) {
//        _watchView = [[UIImageView alloc] init];
//        _watchView.contentMode = UIViewContentModeScaleAspectFit;
//        _watchView.image = [UIImage imageNamed:@"icon_video"];
//    }
//    return _watchView;
//}

//- (UILabel *)watchLabel
//{
//    if (_watchLabel == nil) {
//        _watchLabel = [[UILabel alloc] init];
//        _watchLabel.font = [UIFont systemFontOfSize:13];
//        _watchLabel.textColor = kBlackColor;
//    }
//    return _watchLabel;
//}

- (UIButton *)likeButton
{
    if (_likeButton == nil) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeButton.imageView.backgroundColor = [UIColor whiteColor];
        _likeButton.titleLabel.backgroundColor = [UIColor whiteColor];
        _likeButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _likeButton.adjustsImageWhenHighlighted = NO;
        [_likeButton setTitleColor:SSColor(102, 102, 102) forState:UIControlStateNormal];
        [_likeButton setTitleColor:kOrangeColor forState:UIControlStateSelected];
        [_likeButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_likeButton setImage:[UIImage imageNamed:@"icon_like_d"] forState:UIControlStateNormal];
        [_likeButton setImage:[UIImage imageNamed:@"icon_like_s"] forState:UIControlStateSelected];
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSNumber *likeNum = appDelegate.likedDic[_model.news_id];
    if (likeNum != nil && [likeNum isEqualToNumber:@1]) {
        _likeButton.selected = YES;
    } else {
        _likeButton.selected = NO;
    }
    if (_model.likedCount.integerValue > 0) {
        NSString *buttonTitle = [NSString stringWithFormat:@"%@",_model.likedCount];
        switch (buttonTitle.length) {
            case 1:
                _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -12, 0, 0);
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -4);
                [_likeButton setTitle:buttonTitle forState:UIControlStateNormal];
                break;
            case 2:
                _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 0);
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -8);
                [_likeButton setTitle:buttonTitle forState:UIControlStateNormal];
                break;
            case 3:
                _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 0);
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -12);
                [_likeButton setTitle:buttonTitle forState:UIControlStateNormal];
                break;
            case 4:
                _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -16);
                [_likeButton setTitle:buttonTitle forState:UIControlStateNormal];
                break;
            case 5:
                _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
                [_likeButton setTitle:@"9999+" forState:UIControlStateNormal];
                break;
            default:
                _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -12, 0, 0);
                _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -4);
                [_likeButton setTitle:buttonTitle forState:UIControlStateNormal];
                break;
        }
    } else {
        _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        [_likeButton setTitle:@"" forState:UIControlStateNormal];
    }
    return _likeButton;
}

- (UIImageView *)commentView
{
    if (_commentView == nil) {
        _commentView = [[UIImageView alloc] init];
        _commentView.contentMode = UIViewContentModeScaleAspectFit;
        _commentView.image = [UIImage imageNamed:@"icon_video_comment"];
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

- (UIButton *)shareButton
{
    if (_shareButton == nil) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareButton.imageView.backgroundColor = [UIColor whiteColor];
        _shareButton.adjustsImageWhenHighlighted = NO;
        //        [_shareButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_shareButton setImage:[UIImage imageNamed:@"icon_share_d"] forState:UIControlStateNormal];
        [_shareButton setImage:[UIImage imageNamed:@"icon_share_s"] forState:UIControlStateHighlighted];
    }
    return _shareButton;
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

- (void)tapAction
{
    // 无图模式点击图片不进入全屏显示状态
    NSNumber *textOnlyMode = DEF_PERSISTENT_GET_OBJECT(SS_textOnlyMode);
    // 打点-点击版本更新对话框中立即更新选项-010006
    if ([self.ViewController isKindOfClass:[HomeTableViewController class]]) {
        HomeTableViewController *homeTBC = (HomeTableViewController *)self.ViewController;
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       homeTBC.model.name, @"channel",
                                       _model.news_id, @"article",
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       [NetType getNetType], @"network",
                                       textOnlyMode.integerValue ? @"YES" : @"NO", @"state",
                                       nil];
        [Flurry logEvent:@"Home_PhotoList_Click" withParameters:articleParams];
    }
    if ([textOnlyMode integerValue] == 1) {
        return;
    }
    HZPhotoBrowser *browserVc = [[HZPhotoBrowser alloc] init];
    browserVc.model = _model;
    browserVc.sourceImagesContainerView = self.titleImageView; // 原图的父控件
    browserVc.imageCount = _model.imgs.count; // 图片总数
    browserVc.currentImageIndex = 0;
    browserVc.delegate = self;
    browserVc.cell = self;
    [browserVc show];
}

#pragma mark - photobrowser代理方法
- (UIImage *)photoBrowser:(HZPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    return self.titleImageView.image;
}

- (NSURL *)photoBrowser:(HZPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    ImageModel *imageModel = _model.imgs.firstObject;
    NSString *imageUrl = [imageModel.src stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:imageUrl];
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
