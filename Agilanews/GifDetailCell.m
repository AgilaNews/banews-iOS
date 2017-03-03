//
//  GifDetailCell.m
//  Agilanews
//
//  Created by 张思思 on 16/12/28.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "GifDetailCell.h"
#import "ImageModel.h"
#import "VideoModel.h"
#import "AppDelegate.h"

@implementation GifDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kWhiteBgColor;
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
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.titleImageView];
    [self.contentView addSubview:self.playButton];
    [self.contentView addSubview:self.loadingView];
    [self.contentView addSubview:self.likeButton];
    [self.contentView addSubview:self.facebookShare];
    
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
    // 播放按钮布局
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.titleImageView.mas_centerX);
        make.centerY.mas_equalTo(weakSelf.titleImageView.mas_centerY);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(60);
    }];
    // loading布局
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.titleImageView.mas_centerX);
        make.centerY.mas_equalTo(weakSelf.titleImageView.mas_centerY);
        make.width.mas_equalTo(45);
        make.height.mas_equalTo(45);
    }];
    // 点赞布局
    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo((kScreenWidth - 105 - 10 - 50) * .5);
        make.top.mas_equalTo(weakSelf.titleImageView.mas_bottom).offset(30);
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
        /*
         张思思
         */
        make.width.mas_equalTo(kScreenWidth - 22);
        make.height.mas_equalTo(width);
    }];
    // 播放按钮布局
    [self.playButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.titleImageView.mas_centerX);
        make.centerY.mas_equalTo(weakSelf.titleImageView.mas_centerY);
    }];
    // loading布局
    [self.loadingView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.titleImageView.mas_centerX);
        make.centerY.mas_equalTo(weakSelf.titleImageView.mas_centerY);
    }];
    [self.likeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo((kScreenWidth - 105 - 10 - 50) * .5);
        make.top.mas_equalTo(weakSelf.titleImageView.mas_bottom).offset(30);
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
    
    // 设置内容
    self.titleLabel.text = _model.title;
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
    self.titleImageView.contentMode = UIViewContentModeCenter;
    NSNumber *textOnlyMode = DEF_PERSISTENT_GET_OBJECT(SS_textOnlyMode);
    if ([textOnlyMode integerValue] == 1) {
        self.titleImageView.image = nil;
        self.playButton.hidden = NO;
        return;
    }
    self.playButton.hidden = YES;
    NSString *imageUrl = [imageModel.src stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"holderImage"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (weakSelf.loadingView.hidden && _isPlay == NO) {
            weakSelf.playButton.hidden = NO;
        }
        if (!image) {
            weakSelf.playButton.hidden = YES;
            _titleImageView.image = [UIImage imageNamed:@"holderImage"];
        } else {
            _titleImageView.contentMode = UIViewContentModeScaleAspectFit;
            _titleImageView.image = image;
        }
    }];
}

- (void)tapAction
{
    if (self.playButton.hidden) {
        return;
    }
    // 打点-点击播放-010122
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   @"GIFs", @"channel",
                                   _model.news_id, @"article",
                                   [NetType getNetType], @"network",
                                   nil];
    [Flurry logEvent:@"Home_List_Play_Click" withParameters:articleParams];

    [self createImageFolderAtPath];
    self.playButton.hidden = YES;
    VideoModel *videoModel = _model.videos.firstObject;
    NSString *urlString = [videoModel.src stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *md5String = [NSString encryptPassword:urlString];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *mp4FilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"ImageFolder/%@.mp4",md5String]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:mp4FilePath]) {
        [self playVideoWithUrl:mp4FilePath];
    } else {
        [self.loadingView startAnimation];
        __weak typeof(self) weakSelf = self;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        _downloadTask = [[SSHttpRequest sharedInstance] downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.loadingView.percent = [NSString stringWithFormat:@"%.f%%",(float)downloadProgress.completedUnitCount / (float)downloadProgress.totalUnitCount * 100];
            });
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return [NSURL URLWithString:[NSString stringWithFormat:@"file://%@/",mp4FilePath]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            [weakSelf.loadingView stopAnimation];
            if (error) {
                if ([error code] == NSURLErrorCancelled)
                {
                    SSLog(@"\n------网络请求取消------\n%@",error);
                    return;
                }
                // 打点-播放失败-010123
                NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                               @"GIFs", @"channel",
                                               _model.news_id, @"article",
                                               [NetType getNetType], @"network",
                                               nil];
                [Flurry logEvent:@"Home_List_Play_Failure" withParameters:articleParams];
                //#if DEBUG
                //                [iConsole info:[NSString stringWithFormat:@"Home_List_Play_Failure:%@",articleParams],nil];
                //#endif
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
                weakSelf.playButton.hidden = NO;
                [fileManager removeItemAtPath:mp4FilePath error:nil];
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
    // 允许其他APP播放音乐
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    _player = [AVPlayer playerWithPlayerItem:item];
    _player.volume = 0.0;
    _player.muted = YES;
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = self.titleImageView.bounds;
    //    [self addObserverToPlayerItem:item];
    [self.titleImageView.layer addSublayer:_playerLayer];
    [self.player play];
    _isPlay = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}
- (void)playbackFinished:(NSNotification *)notification
{
    SSLog(@"视频播放完成");
    // 打点-播放结束-010124
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   @"GIFs", @"channel",
                                   _model.news_id, @"article",
                                   [NetType getNetType], @"network",
                                   nil];
    [Flurry logEvent:@"Home_List_Play_End" withParameters:articleParams];
    [self.playerLayer removeFromSuperlayer];
    _isPlay = NO;
    VideoModel *videoModel = _model.videos.firstObject;
    NSString *urlString = [videoModel.src stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *md5String = [NSString encryptPassword:urlString];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *mp4FilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"ImageFolder/%@.mp4",md5String]];
    [self playVideoWithUrl:mp4FilePath];
}

// 创建图片文件夹
- (void)createImageFolderAtPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageFolder"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:filePath];
    if (!existed) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
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
        _titleLabel.font = [UIFont systemFontOfSize:16];
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
    }
    return _titleImageView;
}

- (UIButton *)playButton
{
    if (_playButton == nil) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
        _playButton.adjustsImageWhenHighlighted = NO;
        _playButton.hidden = YES;
    }
    return _playButton;
}

- (LoadingView *)loadingView
{
    if (_loadingView == nil) {
        _loadingView = [[LoadingView alloc] init];
        _loadingView.hidden = YES;
    }
    return _loadingView;
}

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
