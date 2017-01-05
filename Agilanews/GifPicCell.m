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
//    [self removeObserverFromPlayerItem:self.player.currentItem];
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
    [self.contentView addSubview:self.watchView];
    [self.contentView addSubview:self.watchLabel];
    [self.contentView addSubview:self.commentView];
    [self.contentView addSubview:self.commentLabel];
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
    // 观看视图布局
    [self.watchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.titleImageView.mas_bottom).offset(15.5);
        make.left.mas_equalTo(11);
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(11);
    }];
    // 观看量布局
    [self.watchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.watchView.mas_right).offset(5);
        make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(0);
    }];
    // 分享按钮布局
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
    }];
    // 评论数布局
    [self.commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.shareButton.mas_left).offset(-27);
        make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(0);
    }];
    // 评论视图布局
    [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.commentLabel.mas_left).offset(-6);
        make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
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
    // 观看视图布局
    [self.watchView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.titleImageView.mas_bottom).offset(15.5);
        make.left.mas_equalTo(11);
        make.width.mas_equalTo(11);
        make.height.mas_equalTo(11);
    }];
    // 观看量布局
    NSString *views = [TimeStampToString getViewsStringWithNumber:_model.views];
    CGSize watchLabelSize = [views calculateSize:CGSizeMake(100, 14) font:self.watchLabel.font];
    [self.watchLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.watchView.mas_right).offset(5);
        make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
        make.width.mas_equalTo(watchLabelSize.width);
        make.height.mas_equalTo(watchLabelSize.height);
    }];
    // 分享按钮布局
    [self.shareButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
    }];
    // 评论数布局
    if (_model.commentCount.integerValue > 0) {
        CGSize commentLabelSize = [_model.commentCount.stringValue calculateSize:CGSizeMake(100, 13) font:self.commentLabel.font];
        [self.commentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf.shareButton.mas_left).offset(-27);
            make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
            make.width.mas_equalTo(commentLabelSize.width);
            make.height.mas_equalTo(commentLabelSize.height);
        }];
    } else {
        [self.commentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf.shareButton.mas_left).offset(-27);
            make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
    }
    // 评论视图布局
    [self.commentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.commentLabel.mas_left).offset(-6);
        make.centerY.mas_equalTo(weakSelf.watchView.mas_centerY);
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
    self.watchLabel.text = views;
    if (_model.commentCount.integerValue > 0) {
        self.commentLabel.text = _model.commentCount.stringValue;
    } else {
        self.commentLabel.text = @"";
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

- (UIImageView *)watchView
{
    if (_watchView == nil) {
        _watchView = [[UIImageView alloc] init];
        _watchView.contentMode = UIViewContentModeScaleAspectFit;
        _watchView.image = [UIImage imageNamed:@"icon_video"];
    }
    return _watchView;
}

- (UILabel *)watchLabel
{
    if (_watchLabel == nil) {
        _watchLabel = [[UILabel alloc] init];
        _watchLabel.font = [UIFont systemFontOfSize:13];
        _watchLabel.textColor = kBlackColor;
    }
    return _watchLabel;
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
        [_shareButton setImage:[UIImage imageNamed:@"icon_video_facebook"] forState:UIControlStateNormal];
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
    [self stop];
}
- (void)setModel:(NewsModel *)model
{
    if (_model != model) {
        _model = model;
        [self stop];
        [self setNeedsLayout];
    }
}
- (void)stop
{
    [_downloadTask cancel];
    [self.playerLayer removeFromSuperlayer];
//    [self removeObserverFromPlayerItem:self.player.currentItem];
    _isPlay = NO;
    [self.player pause];
    self.player = nil;
    self.playButton.hidden = NO;
    [self.loadingView stopAnimation];
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
//#if DEBUG
//    [iConsole info:[NSString stringWithFormat:@"Home_List_Play_Click:%@",articleParams],nil];
//#endif
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

//    AVAsset *asset = [AVAsset assetWithURL:url];
//    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
//    NSMutableArray *allAudioParams = [NSMutableArray array];
//    for (AVAssetTrack *track in audioTracks) {
//        AVMutableAudioMixInputParameters *audioInputParams =
//        [AVMutableAudioMixInputParameters audioMixInputParameters];
//        [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
//        [audioInputParams setTrackID:[track trackID]];
//        [allAudioParams addObject:audioInputParams];
//    }
//    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
//    [audioMix setInputParameters:allAudioParams];
//    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
//    [item setAudioMix:audioMix];
    
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
//#if DEBUG
//    [iConsole info:[NSString stringWithFormat:@"Home_List_Play_End:%@",articleParams],nil];
//#endif
    [self.playerLayer removeFromSuperlayer];
    _isPlay = NO;
//    [self removeObserverFromPlayerItem:self.player.currentItem];
    VideoModel *videoModel = _model.videos.firstObject;
    NSString *urlString = [videoModel.src stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *md5String = [NSString encryptPassword:urlString];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *mp4FilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"ImageFolder/%@.mp4",md5String]];
    [self playVideoWithUrl:mp4FilePath];
}

//- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
//    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
//    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//    //监控网络加载情况属性
//    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
//    //监听播放的区域缓存是否为空
//    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
//    //缓存可以播放的时候调用
//    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
//}
//- (void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
//    [playerItem removeObserver:self forKeyPath:@"status"];
//    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
//    [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
//    [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
//}
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    AVPlayerItem *playerItem = object;
//    if ([keyPath isEqualToString:@"status"]) {
//        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
//        if(status == AVPlayerStatusReadyToPlay){
//            NSLog(@"开始播放,视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
//        }else if(status == AVPlayerStatusUnknown){
//            NSLog(@"%@",@"AVPlayerStatusUnknown");
//        }else if (status == AVPlayerStatusFailed){
//            NSLog(@"%@",@"AVPlayerStatusFailed");
//        }
//    }
//}

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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (editing) {
        [self stop];
        self.playButton.hidden = NO;
        self.playButton.enabled = NO;
    } else {
        self.playButton.enabled = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
