//
//  FacebookAdCell.m
//  Agilanews
//
//  Created by 张思思 on 16/11/18.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "FacebookAdCell.h"
#import "AppDelegate.h"

#define titleFont_Normal        [UIFont systemFontOfSize:16]
#define titleFont_ExtraLarge    [UIFont systemFontOfSize:20]
#define titleFont_Large         [UIFont systemFontOfSize:18]
#define titleFont_Small         [UIFont systemFontOfSize:14]
#if DEBUG
#define kListPlacementID    @"1188655531159250_1397507120274089"
#define kDetailPlacementID  @"YOUR_PLACEMENT_ID"
#else
#define kListPlacementID    @"1188655531159250_1397507120274089"
#define kDetailPlacementID  @"1188655531159250_1397507606940707"
#endif

@implementation FacebookAdCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _initSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChange) name:KNOTIFICATION_FontSize_Change object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_initSubviews
{
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.titleImageView];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.sourceLabel];
    [self.contentView addSubview:self.learnButton];
    __weak typeof(self) weakSelf = self;
    // 标题布局
    CGSize titleLabelSize = [_model.nativeAd.title calculateSize:CGSizeMake(kScreenWidth - 22 - 108 - 9, 30) font:self.titleLabel.font];
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
    // 内容布局
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).offset(2);
        make.width.mas_equalTo(kScreenWidth - 22 - 108 - 9);
        make.height.mas_equalTo(30);
    }];
    // 来源布局
    [self.sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.bottom.mas_equalTo(-7);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(14);
    }];
    // 更多按钮布局
    CGSize learnButtonSize = [@"Learn more" calculateSize:CGSizeMake(100, 15) font:self.learnButton.titleLabel.font];
    [self.learnButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.titleImageView.mas_left).offset(-15);
        make.bottom.mas_equalTo(weakSelf.sourceLabel.mas_bottom);
        make.width.mas_equalTo(learnButtonSize.width + 8);
        make.height.mas_equalTo(learnButtonSize.height + 2);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    __weak typeof(self) weakSelf = self;
    // 标题布局
    CGSize titleLabelSize = [_model.nativeAd.title calculateSize:CGSizeMake(kScreenWidth - 22 - 108 - 9, 30) font:self.titleLabel.font];
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.top.mas_equalTo(9);
        make.width.mas_equalTo(titleLabelSize.width);
        make.height.mas_equalTo(titleLabelSize.height);
    }];
    // 标题图片布局
    [self.titleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.contentView.mas_right).offset(-11);
        make.top.mas_equalTo(12);
        make.width.mas_equalTo(108);
        make.height.mas_equalTo(68);
    }];
    // 内容布局
    CGSize contentLabelSize = [_model.nativeAd.body calculateSize:CGSizeMake(kScreenWidth - 22 - 108 - 9, 40) font:self.contentLabel.font];
    [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).offset(2);
        make.width.mas_equalTo(contentLabelSize.width);
        make.height.mas_equalTo(contentLabelSize.height);
    }];
    // 来源布局
    CGSize sourceLabelSize = [@"Ad" calculateSize:CGSizeMake(50, 12) font:self.sourceLabel.font];
    [self.sourceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.bottom.mas_equalTo(-8);
        make.width.mas_equalTo(sourceLabelSize.width);
        make.height.mas_equalTo(sourceLabelSize.height);
    }];
    // 更多按钮布局
    CGSize learnButtonSize = [_model.nativeAd.callToAction calculateSize:CGSizeMake(100, 15) font:self.learnButton.titleLabel.font];
    [self.learnButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.titleImageView.mas_left).offset(-15);
        make.bottom.mas_equalTo(weakSelf.sourceLabel.mas_bottom);
        make.width.mas_equalTo(learnButtonSize.width + 8);
        make.height.mas_equalTo(learnButtonSize.height + 2);
    }];
    [super updateConstraints];
    
    self.titleLabel.text = _model.nativeAd.title;
    self.contentLabel.text = _model.nativeAd.body;
    [self.learnButton setTitle:_model.nativeAd.callToAction forState:UIControlStateNormal];
    [_model.nativeAd.coverImage loadImageAsyncWithBlock:^(UIImage *image) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.titleImageView.image = image;
    }];
}

#pragma mark - FBNativeAdDelegate
- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd
{
    SSLog(@"广告展示");
    // 服务器打点-广告show-060102
    NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
    [eventDic setObject:@"060102" forKey:@"id"];
    [eventDic setObject:_model.tpl forKey:@"AD style"];
    [eventDic setObject:_model.nativeAd.coverImage.url.absoluteString forKey:@"ImageUrl"];
    [eventDic setObject:@"native" forKey:@"Facebook Native AD Style"];
    [eventDic setObject:@"" forKey:@"Advertiser"];
    [eventDic setObject:kListPlacementID forKey:@"Facebook AD Placement ID"];
    [eventDic setObject:_model.nativeAd.callToAction forKey:@"CallToAction"];
    [eventDic setObject:_model.ad_id forKey:@"AD_ID"];
    [eventDic setObject:_model.nativeAd.body forKey:@"Body"];
    [eventDic setObject:_model.nativeAd.icon.url.absoluteString forKey:@"IconUrl"];
    [eventDic setObject:@"facebook" forKey:@"AD Type"];
    [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
    [eventDic setObject:[NetType getNetType] forKey:@"net"];
    if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
    } else {
        [eventDic setObject:@"" forKey:@"lng"];
        [eventDic setObject:@"" forKey:@"lat"];
    }
    NSString *abflag = DEF_PERSISTENT_GET_OBJECT(@"abflag");
    if (abflag && abflag.length > 0) {
        [eventDic setObject:abflag forKey:@"abflag"];
    }
    [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(@"UUID") forKey:@"session"];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.eventArray addObject:eventDic];
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd
{
    SSLog(@"广告点击");
    // 服务器打点-广告click-060103
    NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
    [eventDic setObject:@"060103" forKey:@"id"];
    [eventDic setObject:_model.tpl forKey:@"AD style"];
    [eventDic setObject:_model.nativeAd.coverImage.url.absoluteString forKey:@"ImageUrl"];
    [eventDic setObject:@"native" forKey:@"Facebook Native AD Style"];
    [eventDic setObject:@"" forKey:@"Advertiser"];
    [eventDic setObject:kListPlacementID forKey:@"Facebook AD Placement ID"];
    [eventDic setObject:_model.nativeAd.callToAction forKey:@"CallToAction"];
    [eventDic setObject:_model.ad_id forKey:@"AD_ID"];
    [eventDic setObject:_model.nativeAd.body forKey:@"Body"];
    [eventDic setObject:_model.nativeAd.icon.url.absoluteString forKey:@"IconUrl"];
    [eventDic setObject:@"facebook" forKey:@"AD Type"];
    [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
    [eventDic setObject:[NetType getNetType] forKey:@"net"];
    if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
    } else {
        [eventDic setObject:@"" forKey:@"lng"];
        [eventDic setObject:@"" forKey:@"lat"];
    }
    NSString *abflag = DEF_PERSISTENT_GET_OBJECT(@"abflag");
    if (abflag && abflag.length > 0) {
        [eventDic setObject:abflag forKey:@"abflag"];
    }
    [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(@"UUID") forKey:@"session"];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.eventArray addObject:eventDic];
}

- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd
{
    SSLog(@"广告点击完成");
}

#pragma mark - setter/getter
- (void)setModel:(NewsModel *)model
{
    if (_model != model) {
        [self.model.nativeAd unregisterView];
        if (model.nativeAd == nil) {
            model.nativeAd = [[FacebookAdManager sharedInstance] getFBNativeAdFromListADArray];
        }
        _model = model;
        model.nativeAd.delegate = self;
        [model.nativeAd registerViewForInteraction:self.contentView withViewController:self.ViewController];
        // 服务器打点-广告填充-060101
        NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
        [eventDic setObject:@"060101" forKey:@"id"];
        [eventDic setObject:model.tpl forKey:@"AD style"];
        [eventDic setObject:model.nativeAd.coverImage.url.absoluteString forKey:@"ImageUrl"];
        [eventDic setObject:@"native" forKey:@"Facebook Native AD Style"];
        [eventDic setObject:@"" forKey:@"Advertiser"];
        [eventDic setObject:kListPlacementID forKey:@"Facebook AD Placement ID"];
        [eventDic setObject:model.nativeAd.callToAction forKey:@"CallToAction"];
        [eventDic setObject:model.ad_id forKey:@"AD_ID"];
        [eventDic setObject:model.nativeAd.body forKey:@"Body"];
        [eventDic setObject:model.nativeAd.icon.url.absoluteString forKey:@"IconUrl"];
        [eventDic setObject:@"facebook" forKey:@"AD Type"];
        [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
        [eventDic setObject:[NetType getNetType] forKey:@"net"];
        if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
            [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
            [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
        } else {
            [eventDic setObject:@"" forKey:@"lng"];
            [eventDic setObject:@"" forKey:@"lat"];
        }
        NSString *abflag = DEF_PERSISTENT_GET_OBJECT(@"abflag");
        if (abflag && abflag.length > 0) {
            [eventDic setObject:abflag forKey:@"abflag"];
        }
        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(@"UUID") forKey:@"session"];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.eventArray addObject:eventDic];
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
        _titleLabel.textColor = kBlackColor;
    }
    return _titleLabel;
}

- (UIImageView *)titleImageView
{
    if (_titleImageView == nil) {
        _titleImageView = [[UIImageView alloc] init];
//        _titleImageView.backgroundColor = SSColor(235, 235, 235);
        _titleImageView.contentMode = UIViewContentModeScaleAspectFill;
        _titleImageView.clipsToBounds = YES;
    }
    return _titleImageView;
}

- (UILabel *)contentLabel
{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:13];
        _contentLabel.textColor = kGrayColor;
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UILabel *)sourceLabel
{
    if (_sourceLabel == nil) {
        _sourceLabel = [[UILabel alloc] init];
        _sourceLabel.font = [UIFont systemFontOfSize:12];
        _sourceLabel.textColor = kGrayColor;
        _sourceLabel.text = @"Ad";
    }
    return _sourceLabel;
}

- (UIButton *)learnButton
{
    if (_learnButton == nil) {
        _learnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_learnButton setTitleColor:kOrangeColor forState:UIControlStateNormal];
        _learnButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _learnButton.layer.cornerRadius = 4;
        _learnButton.layer.masksToBounds = YES;
        _learnButton.layer.borderWidth = 1;
        _learnButton.layer.borderColor = kOrangeColor.CGColor;
    }
    return _learnButton;
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
