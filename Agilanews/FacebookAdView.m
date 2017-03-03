//
//  FacebookAdView.m
//  Agilanews
//
//  Created by 张思思 on 16/11/22.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "FacebookAdView.h"
#import "AppDelegate.h"

#define titleFont_Normal        [UIFont systemFontOfSize:16]
#define titleFont_ExtraLarge    [UIFont systemFontOfSize:20]
#define titleFont_Large         [UIFont systemFontOfSize:18]
#define titleFont_Small         [UIFont systemFontOfSize:14]
#define imageHeight 155 * kScreenWidth / 320.0

#if DEBUG
#define kListPlacementID    @"1188655531159250_1397507120274089"
#define kDetailPlacementID  @"YOUR_PLACEMENT_ID"
#else
#define kListPlacementID    @"1188655531159250_1397507120274089"
#define kDetailPlacementID  @"1188655531159250_1397507606940707"
#endif

@implementation FacebookAdView

- (instancetype)initWithNativeAd:(FBNativeAd *)nativeAd AdId:(NSNumber *)ad_id
{
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, 83 + imageHeight)];
    if (self) {
        if (nativeAd == nil) {
            nativeAd = [[FacebookAdManager sharedInstance] getFBNativeAdFromListADArray];
        }
        self.ad_id = ad_id;
        self.nativeAd = nativeAd;
        self.nativeAd.delegate = self;
        [self.nativeAd registerViewForInteraction:self withViewController:self.ViewController];
        
        // 服务器打点-广告填充-060101
        NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
        [eventDic setObject:@"060101" forKey:@"id"];
        [eventDic setObject:@5001 forKey:@"AD style"];
        [eventDic setObject:nativeAd.coverImage.url.absoluteString forKey:@"ImageUrl"];
        [eventDic setObject:@"native" forKey:@"Facebook Native AD Style"];
        [eventDic setObject:@"" forKey:@"Advertiser"];
        [eventDic setObject:kDetailPlacementID forKey:@"Facebook AD Placement ID"];
        [eventDic setObject:nativeAd.callToAction forKey:@"CallToAction"];
        [eventDic setObject:ad_id forKey:@"AD_ID"];
        [eventDic setObject:nativeAd.body forKey:@"Body"];
        [eventDic setObject:nativeAd.icon.url.absoluteString forKey:@"IconUrl"];
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
        
        [self _initSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChange) name:KNOTIFICATION_FontSize_Change object:nil];
    }
    return self;
}

- (void)dealloc
{
    [self.nativeAd unregisterView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_initSubviews
{
    self.userInteractionEnabled = YES;
    self.backgroundColor = SSColor_RGB(235);
    [self addSubview:self.bgView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.titleImageView];
    [self addSubview:self.contentLabel];
    [self addSubview:self.sourceLabel];
    [self addSubview:self.learnButton];
    __weak typeof(self) weakSelf = self;
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(8);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(83 + imageHeight - 8);
    }];
    // 标题布局
    CGSize titleLabelSize = [self.nativeAd.title calculateSize:CGSizeMake(kScreenWidth - 22 - 50, 30) font:self.titleLabel.font];
    /*
     张思思
     */
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.top.mas_equalTo(9 + 8);
        make.width.mas_equalTo(titleLabelSize.width);
        make.height.mas_equalTo(titleLabelSize.height);
    }];
    // 标题图片布局
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).offset(6);
        make.width.mas_equalTo(kScreenWidth - 22);
        make.height.mas_equalTo(imageHeight);
    }];
    // 来源布局
    CGSize sourceLabelSize = [@"Ad" calculateSize:CGSizeMake(50, 12) font:self.sourceLabel.font];
    [self.sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-11);
        make.centerY.mas_equalTo(weakSelf.titleLabel.mas_centerY);
        make.width.mas_equalTo(sourceLabelSize.width);
        make.height.mas_equalTo(sourceLabelSize.height);
    }];
    // 更多按钮布局
    CGSize learnButtonSize = [self.nativeAd.callToAction calculateSize:CGSizeMake(100, 15) font:self.learnButton.titleLabel.font];
    [self.learnButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.titleImageView.mas_right);
        make.top.mas_equalTo(weakSelf.titleImageView.mas_bottom).offset(11);
        make.width.mas_equalTo(learnButtonSize.width + 8);
        make.height.mas_equalTo(learnButtonSize.height + 2);
    }];
    // 内容布局
    CGSize contentLabelSize = [self.nativeAd.body calculateSize:CGSizeMake(kScreenWidth - 22 - 100, 40) font:self.contentLabel.font];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.centerY.mas_equalTo(weakSelf.learnButton.mas_centerY);
        make.width.mas_equalTo(contentLabelSize.width);
        make.height.mas_equalTo(contentLabelSize.height);
    }];
    
    self.titleLabel.text = self.nativeAd.title;
    self.contentLabel.text = self.nativeAd.body;
    [self.learnButton setTitle:self.nativeAd.callToAction forState:UIControlStateNormal];
    [self.nativeAd.coverImage loadImageAsyncWithBlock:^(UIImage *image) {
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
    [eventDic setObject:@5001 forKey:@"AD style"];
    [eventDic setObject:self.nativeAd.coverImage.url.absoluteString forKey:@"ImageUrl"];
    [eventDic setObject:@"native" forKey:@"Facebook Native AD Style"];
    [eventDic setObject:@"" forKey:@"Advertiser"];
    [eventDic setObject:kDetailPlacementID forKey:@"Facebook AD Placement ID"];
    [eventDic setObject:self.nativeAd.callToAction forKey:@"CallToAction"];
    [eventDic setObject:self.ad_id forKey:@"AD_ID"];
    [eventDic setObject:self.nativeAd.body forKey:@"Body"];
    [eventDic setObject:self.nativeAd.icon.url.absoluteString forKey:@"IconUrl"];
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
    [eventDic setObject:@5001 forKey:@"AD style"];
    [eventDic setObject:self.nativeAd.coverImage.url.absoluteString forKey:@"ImageUrl"];
    [eventDic setObject:@"native" forKey:@"Facebook Native AD Style"];
    [eventDic setObject:@"" forKey:@"Advertiser"];
    [eventDic setObject:kDetailPlacementID forKey:@"Facebook AD Placement ID"];
    [eventDic setObject:self.nativeAd.callToAction forKey:@"CallToAction"];
    [eventDic setObject:self.ad_id forKey:@"AD_ID"];
    [eventDic setObject:self.nativeAd.body forKey:@"Body"];
    [eventDic setObject:self.nativeAd.icon.url.absoluteString forKey:@"IconUrl"];
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
- (UIView *)bgView
{
    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = kWhiteBgColor;
    }
    return _bgView;
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


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
