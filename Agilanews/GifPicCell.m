//
//  GifPicCell.m
//  Agilanews
//
//  Created by 张思思 on 16/7/15.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "GifPicCell.h"
#import "ImageModel.h"
#import "VideoModel.h"
#import "AppDelegate.h"
#import "HomeTableViewController.h"

#define titleFont_Normal        [UIFont systemFontOfSize:16]
#define titleFont_ExtraLarge    [UIFont systemFontOfSize:20]
#define titleFont_Large         [UIFont systemFontOfSize:18]
#define titleFont_Small         [UIFont systemFontOfSize:14]

@implementation GifPicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier bgColor:(UIColor *)bgColor
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgColor = bgColor;
        self.backgroundColor = bgColor;
        // 初始化子视图
        [self _initSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fontChange)
                                                     name:KNOTIFICATION_FontSize_Change
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopVideoNotif)
                                                     name:KNOTIFICATION_Secect_Channel
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopVideoNotif)
                                                     name:KNOTIFICATION_Scroll_Channel
                                                   object:nil];
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
    [self.contentView addSubview:self.likeButton];
    [self.contentView addSubview:self.shareButton];
    
    __weak typeof(self) weakSelf = self;
    // 标题布局
    CGSize titleLabelSize = [_model.title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:self.titleLabel.font];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.top.mas_equalTo(11);
        make.width.mas_equalTo(titleLabelSize.width);
        make.height.mas_equalTo(titleLabelSize.height);
    }];
    // 标题图片布局
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(kScreenWidth - 22);
        make.height.mas_equalTo(500);
    }];
    // 点赞按钮布局
    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.top.mas_equalTo(weakSelf.titleImageView.mas_bottom).offset(1);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(40);
    }];
    // 分享按钮布局
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.titleImageView.mas_right);
        make.top.mas_equalTo(weakSelf.likeButton.mas_top);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
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
    // 标题图片布局
    ImageModel *imageModel = _model.imgs.firstObject;
    CGFloat width = imageModel.height.floatValue / 2.0;
    [self.titleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(kScreenWidth - 22);
        make.height.mas_equalTo(width);
    }];
    // 点赞按钮布局
    [self.likeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.top.mas_equalTo(weakSelf.titleImageView.mas_bottom).offset(1);
    }];
    // 分享按钮布局
    [self.shareButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.titleImageView.mas_right);
        make.top.mas_equalTo(weakSelf.likeButton.mas_top);
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
    self.likeButton.hidden = NO;
    
    NSNumber *textOnlyMode = DEF_PERSISTENT_GET_OBJECT(SS_textOnlyMode);
    if ([textOnlyMode integerValue] == 1) {
        self.titleImageView.image = nil;
        return;
    }
    NSString *imageUrl = [imageModel.src stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"holderImage"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) {
            _titleImageView.image = [UIImage imageNamed:@"holderImage"];
        } else {
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
        _titleImageView.image = [UIImage imageNamed:@"holderImage"];
        _titleImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_titleImageView addGestureRecognizer:tap];
    }
    return _titleImageView;
}

- (UIButton *)likeButton
{
    if (_likeButton == nil) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeButton.imageView.backgroundColor = [UIColor whiteColor];
        _likeButton.titleLabel.backgroundColor = [UIColor whiteColor];
        _likeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _likeButton.adjustsImageWhenHighlighted = NO;
        _likeButton.hidden = YES;
        [_likeButton setTitleColor:SSColor(102, 102, 102) forState:UIControlStateNormal];
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

- (UIButton *)shareButton
{
    if (_shareButton == nil) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareButton.imageView.backgroundColor = [UIColor whiteColor];
        _shareButton.adjustsImageWhenHighlighted = NO;
        _shareButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [_shareButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_shareButton setImage:[UIImage imageNamed:@"icon_share_d"] forState:UIControlStateNormal];
        [_shareButton setImage:[UIImage imageNamed:@"icon_share_s"] forState:UIControlStateHighlighted];
    }
    return _shareButton;
}

#pragma mark - Notification
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

- (void)stopVideoNotif
{
    [_downloadTask cancel];
    [_playerLayer removeFromSuperlayer];
    [_player pause];
    _player = nil;
    _isPlay = NO;
}

- (void)setModel:(NewsModel *)model
{
    if (_model != model) {
        _model = model;
        
        [_downloadTask cancel];
        [_playerLayer removeFromSuperlayer];
        [_player pause];
        _player = nil;
        _isPlay = NO;
    }
}

- (void)tapAction
{
    if (_isPlay) {
        return;
    }
    _isPlay = YES;
    VideoModel *videoModel = _model.videos.firstObject;
    NSString *urlString = [videoModel.src stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *md5String = [NSString encryptPassword:urlString];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *mp4FilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"ImageFolder/%@.mp4",md5String]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:mp4FilePath]) {
        [self playVideoWithUrl:mp4FilePath];
    } else {
        __weak typeof(self) weakSelf = self;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        _downloadTask = [[SSHttpRequest sharedInstance] downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return [NSURL URLWithString:[NSString stringWithFormat:@"file://%@/",mp4FilePath]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if (error) {
                if ([error code] == NSURLErrorCancelled)
                {
                    SSLog(@"\n------网络请求取消------\n%@",error);
                    return;
                }
                if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
                {
                    [SVProgressHUD showErrorWithStatus:@"Please check your network connection"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                } else {
                    [SVProgressHUD showErrorWithStatus:@"Fetching failed, please try again"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                }
            } else {
                [weakSelf playVideoWithUrl:mp4FilePath];
            }
        }];
        [_downloadTask resume];
    }
}
// 播放视频
- (void)playVideoWithUrl:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@/",urlString]];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    _player = [AVPlayer playerWithPlayerItem:item];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = self.titleImageView.bounds;
    [self.titleImageView.layer addSublayer:_playerLayer];
    [_player play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}
- (void)playbackFinished:(NSNotification *)notification
{
    SSLog(@"视频播放完成.");
    [_playerLayer removeFromSuperlayer];
    _isPlay = NO;
    VideoModel *videoModel = _model.videos.firstObject;
    NSString *urlString = [videoModel.src stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *md5String = [NSString encryptPassword:urlString];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *mp4FilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"ImageFolder/%@.mp4",md5String]];
    _isPlay = YES;
    [self playVideoWithUrl:mp4FilePath];
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
