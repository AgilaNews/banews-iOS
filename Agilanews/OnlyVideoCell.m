//
//  OnlyVideoCell.m
//  Agilanews
//
//  Created by 张思思 on 16/10/24.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "OnlyVideoCell.h"
#import "ImageModel.h"
#import "VideoModel.h"
#import "AppDelegate.h"

#define titleFont_Normal        [UIFont systemFontOfSize:17]
#define titleFont_ExtraLarge    [UIFont systemFontOfSize:21]
#define titleFont_Large         [UIFont systemFontOfSize:19]
#define titleFont_Small         [UIFont systemFontOfSize:15]
#define videoHeight 180 * kScreenWidth / 320.0

@implementation OnlyVideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier bgColor:(UIColor *)bgColor
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgColor = bgColor;
        self.backgroundColor = bgColor;
        _playerVars = @{@"autohide" : @2,          // 参数设为1，则视频进度条和播放器控件将会在视频开始播放几秒钟后退出播放界面。
                                                   // 仅在用户将鼠标移动到视频播放器上方或按键盘上的某个键时，进度条和控件才会重新显示。
                                                   // 参数设为0，则视频进度条和视频播放器控件在视频播放全程和全屏状态下均会显示。
                        @"iv_load_policy" : @3,    // 将此值设为1会在默认情况下显示视频注释，而将其设为3则默认不显示。
                        @"playsinline" : @1,       // 以内嵌方式播放还是以全屏形式播放。  1:内嵌模式  0:全屏模式
                        @"loop" : @1,              // 是否循环播放。  0:不循环  1:循环
                        @"rel" : @0,               // 视频播放结束时，播放器是否应显示相关视频。  0:不显示  1:显示
                        @"autoplay" : @1,          // 自动播放
                        @"modestbranding" : @1,    // 将参数值设为1可以阻止YouTube徽标显示在控件栏中。
                        @"origin" : @"http://www.youtube.com",
                        @"enablejsapi" : @1,
                        @"showinfo" : @0};         // 播放器是否显示视频标题和上传者等信息。  0:不显示  1:显示
        // 初始化子视图
        [self _initSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fontChange)
                                                     name:KNOTIFICATION_FontSize_Change
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pausedVideo:)
                                                     name:KNOTIFICATION_PausedVideo
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
    [self.contentView addSubview:self.playerView];
    [self.contentView addSubview:self.titleImageView];
    [self.titleImageView addSubview:self.shadowView];
    [self.titleImageView addSubview:self.titleLabel];
    [self.titleImageView addSubview:self.durationLabel];
    [self.titleImageView addSubview:self.playButton];
    [self.contentView addSubview:self.holderView];
    [self.contentView addSubview:self.watchView];
    [self.contentView addSubview:self.watchLabel];
    [self.contentView addSubview:self.commentView];
    [self.contentView addSubview:self.commentLabel];
    [self.contentView addSubview:self.shareButton];
    
    __weak typeof(self) weakSelf = self;
    // 视频布局
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(videoHeight);
    }];
    // 标题图片布局
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(videoHeight);
    }];
    // 占位图片布局
    [self.holderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(videoHeight);
    }];
    // 遮罩布局
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(42);
    }];
    // 标题布局
    CGSize titleLabelSize = [_model.title calculateSize:CGSizeMake(kScreenWidth - 22, 50) font:self.titleLabel.font];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.top.mas_equalTo(6);
        make.width.mas_equalTo(titleLabelSize.width);
        make.height.mas_equalTo(titleLabelSize.height);
    }];
    // 时长布局
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-6);
        make.bottom.mas_equalTo(-5);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(0);
    }];
    // 播放按钮布局
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
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
    
    VideoModel *model = _model.videos.firstObject;
    __weak typeof(self) weakSelf = self;
    // 视频布局
    [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(videoHeight);
    }];
    // 标题图片布局
    [self.titleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(videoHeight);
    }];
    // 占位图片布局
    [self.holderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(videoHeight);
    }];
    // 遮罩布局
    [self.shadowView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(42);
    }];
    // 标题布局
    CGSize titleLabelSize = [_model.title calculateSize:CGSizeMake(kScreenWidth - 22, 50) font:self.titleLabel.font];
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(11);
        make.top.mas_equalTo(6);
        make.width.mas_equalTo(titleLabelSize.width);
        make.height.mas_equalTo(titleLabelSize.height);
    }];
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
        make.right.mas_equalTo(-6);
        make.bottom.mas_equalTo(-5);
        make.width.mas_equalTo(durationLabelSize.width + 6);
        make.height.mas_equalTo(durationLabelSize.height);
    }];
    // 播放按钮布局
    [self.playButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.titleImageView.mas_centerX);
        make.centerY.mas_equalTo(weakSelf.titleImageView.mas_centerY);
        make.width.mas_equalTo(45);
        make.height.mas_equalTo(45);
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

    self.titleLabel.text = _model.title;
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
        self.titleImageView.image = nil;
        return;
    }
    self.titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    ImageModel *imageModel = _model.imgs.firstObject;
    NSString *imageUrl = [imageModel.pattern stringByReplacingOccurrencesOfString:@"{w}" withString:[NSString stringWithFormat:@"%d",((int)kScreenWidth * 2)]];
    imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{h}" withString:[NSString stringWithFormat:@"%d",(int)(videoHeight * 2)]];
    imageUrl = [imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.titleImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            _titleImageView.image = image;
        }
    }];
}

#pragma makr - tapAction
- (void)tapAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_PausedVideo object:_model.news_id];
    // 打点-点击视频列表的视频播放按钮-010130
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   @"Video", @"channel",
                                   _model.news_id, @"article",
                                   [NetType getNetType], @"network",
                                   nil];
    [Flurry logEvent:@"Home_Videolist_Play_Click" withParameters:articleParams];
#if DEBUG
    [iConsole info:[NSString stringWithFormat:@"Home_Videolist_Play_Click:%@",articleParams],nil];
#endif
    VideoModel *model = _model.videos.firstObject;
    __weak typeof(self) weakSelf = self;
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    if (manager.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
        if (model.youtube_id) {
            self.isPlay = YES;
            [self.playerView loadWithVideoId:model.youtube_id playerVars:_playerVars];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.playerView.playerState == kYTPlayerStateQueued) {
                    [self.playerView playVideo];
                    self.holderView.hidden = YES;
                }
            });
        }
    } else {
        NSString *message = @"You are playing video using traffic, whether to continue playing?";
        UIAlertController *playingAlert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *stopAction = [UIAlertAction actionWithTitle:@"Stop" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            // 打点-点击无图模式提醒对话框No选项-010011
//            [Flurry logEvent:@"LowDataTips_No_Click"];
//#if DEBUG
//            [iConsole info:@"LowDataTips_No_Click",nil];
//#endif
        }];
        UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//            // 打点-点击无图模式提醒对话框中YES选项-010010
//            [Flurry logEvent:@"LowDataTips_YES_Click"];
//#if DEBUG
//            [iConsole info:@"LowDataTips_YES_Click",nil];
//#endif
            weakSelf.isPlay = YES;
            [weakSelf.playerView loadWithVideoId:model.youtube_id playerVars:_playerVars];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (weakSelf.playerView.playerState == kYTPlayerStateQueued) {
                    [weakSelf.playerView playVideo];
                    weakSelf.holderView.hidden = YES;
                }
            });
        }];
        [playingAlert addAction:stopAction];
        [playingAlert addAction:continueAction];
        [self.window.rootViewController presentViewController:playingAlert animated:YES completion:nil];
    }
}

#pragma mark - YTPlayerViewDelegate
- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    self.holderView.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.playerView playVideo];
    });
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{
    switch (state) {
        case kYTPlayerStatePlaying:
        {
            _playStartTime = [[NSDate date] timeIntervalSince1970] * 1000;
            if (_playTimeCount == 0) {
                // 服务器打点-视频播放-020301
                NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
                [eventDic setObject:@"020301" forKey:@"id"];
                [eventDic setObject:[NSNumber numberWithLongLong:_playStartTime] forKey:@"time"];
                [eventDic setObject:_model.news_id forKey:@"news_id"];
                VideoModel *model = _model.videos.firstObject;
                [eventDic setObject:model.youtube_id forKey:@"youtube_video_id"];
                [eventDic setObject:@"0" forKey:@"play_type"];
                [eventDic setObject:[NetType getNetType] forKey:@"net"];
                if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
                    [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
                    [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
                } else {
                    [eventDic setObject:@"" forKey:@"lng"];
                    [eventDic setObject:@"" forKey:@"lat"];
                }
                NSDictionary *sessionDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                            DEF_PERSISTENT_GET_OBJECT(@"UUID"), @"id",
                                            [NSArray arrayWithObject:eventDic], @"events",
                                            nil];
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[NSArray arrayWithObject:sessionDic] forKey:@"sessions"];
                [[SSHttpRequest sharedInstance] post:@"" params:params contentType:JsonType serverType:NetServer_Log success:^(id responseObj) {
                    // 打点成功
                } failure:^(NSError *error) {
                    // 打点失败
                    [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(@"UUID") forKey:@"session"];
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [appDelegate.eventArray addObject:eventDic];
                } isShowHUD:NO];
            }
            break;
        }
        case kYTPlayerStatePaused:
        {
            _playTimeCount += [[NSDate date] timeIntervalSince1970] * 1000 - _playStartTime;
            break;
        }
        case kYTPlayerStateEnded:
        {
            self.isPlay = NO;
        }
        default:
            break;
    }
}

- (void)playerView:(YTPlayerView *)playerView receivedError:(YTPlayerError)error
{
    if (error) {
        self.isPlay = NO;
    }
}

#pragma mark - setter/getter
- (void)setModel:(NewsModel *)model
{
    if (_model != model) {
        _model = model;
        self.isPlay = NO;
    }
}

- (void)setIsPlay:(BOOL)isPlay
{
    if (_isPlay != isPlay) {
        _isPlay = isPlay;
        if (isPlay) {
            self.shadowView.hidden = YES;
            self.titleLabel.hidden = YES;
            self.durationLabel.hidden = YES;
            self.playButton.hidden = YES;
            self.titleImageView.hidden = YES;
            self.holderView.hidden = NO;
        } else {
            [self.playerView stopVideo];
            self.shadowView.hidden = NO;
            self.titleLabel.hidden = NO;
            self.durationLabel.hidden = NO;
            self.playButton.hidden = NO;
            self.titleImageView.hidden = NO;
            self.holderView.hidden = YES;
            if (_playStartTime > 0) {
                long long duration = 0;
                if (self.playerView.playerState == kYTPlayerStatePlaying) {
                    duration = ([[NSDate date] timeIntervalSince1970] * 1000 - _playStartTime + _playTimeCount) / 1000;
                } else {
                    duration = _playTimeCount / 1000;
                }
                _playStartTime = 0;
                _playTimeCount = 0;
                if (duration > 0 && duration < 7200) {
                    // 服务器打点-视频播放完毕-020302
                    NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
                    [eventDic setObject:@"020302" forKey:@"id"];
                    [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
                    [eventDic setObject:_model.news_id forKey:@"news_id"];
                    VideoModel *model = _model.videos.firstObject;
                    [eventDic setObject:model.youtube_id forKey:@"youtube_video_id"];
                    [eventDic setObject:@"0" forKey:@"play_type"];
                    [eventDic setObject:[NSString stringWithFormat:@"%lld",duration] forKey:@"duration"];
                    [eventDic setObject:[NetType getNetType] forKey:@"net"];
                    if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
                        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
                        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
                    } else {
                        [eventDic setObject:@"" forKey:@"lng"];
                        [eventDic setObject:@"" forKey:@"lat"];
                    }
                    NSDictionary *sessionDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                                DEF_PERSISTENT_GET_OBJECT(@"UUID"), @"id",
                                                [NSArray arrayWithObject:eventDic], @"events",
                                                nil];
                    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:[NSArray arrayWithObject:sessionDic] forKey:@"sessions"];
                    [[SSHttpRequest sharedInstance] post:@"" params:params contentType:JsonType serverType:NetServer_Log success:^(id responseObj) {
                        // 打点成功
                    } failure:^(NSError *error) {
                        // 打点失败
                        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(@"UUID") forKey:@"session"];
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.eventArray addObject:eventDic];
                    } isShowHUD:NO];
                }
            }
        }
    }
}

- (YTPlayerView *)playerView
{
    if (_playerView == nil) {
        _playerView = [[YTPlayerView alloc] init];
        _playerView.backgroundColor = [UIColor blackColor];
        _playerView.delegate = self;
    }
    return _playerView;
}

- (UIImageView *)titleImageView
{
    if (_titleImageView == nil) {
        _titleImageView = [[UIImageView alloc] init];
        _titleImageView.userInteractionEnabled = YES;
        _titleImageView.backgroundColor = SSColor(235, 235, 235);
        _titleImageView.contentMode = UIViewContentModeScaleAspectFit;
        _titleImageView.clipsToBounds = YES;
    }
    return _titleImageView;
}

- (UIView *)holderView
{
    if (_holderView == nil) {
        _holderView = [[UIView alloc] init];
        _holderView.backgroundColor = [UIColor blackColor];
        _holderView.hidden = YES;
    }
    return _holderView;
}

- (UIImageView *)shadowView
{
    if (_shadowView == nil) {
        _shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 42)];
        _shadowView.contentMode = UIViewContentModeScaleToFill;
        // 拉伸图片
        UIImage *image = [UIImage imageNamed:@"bg_black"];
        NSInteger leftCapWidth = image.size.width * 0.5;
        NSInteger topCapWidth = image.size.height * 0.5;
        // 设置端盖的值
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(topCapWidth, leftCapWidth, topCapWidth, leftCapWidth);
        // 拉伸图片
        UIImage *newImage = [image resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
        self.shadowView.image = newImage;
    }
    return _shadowView;
}

- (UILabel *)titleLabel
{
    if (_titleLabel ==  nil) {
        _titleLabel = [[UILabel alloc] init];
        switch ([DEF_PERSISTENT_GET_OBJECT(SS_FontSize) integerValue]) {
            case 0:
                if (iPhone4 || iPhone5) {
                    _titleLabel.font = [UIFont systemFontOfSize:15];
                } else {
                    _titleLabel.font = titleFont_Normal;
                }
                break;
            case 1:
                if (iPhone4 || iPhone5) {
                    _titleLabel.font = [UIFont systemFontOfSize:19];
                } else {
                    _titleLabel.font = titleFont_ExtraLarge;
                }
                break;
            case 2:
                if (iPhone4 || iPhone5) {
                    _titleLabel.font = [UIFont systemFontOfSize:17];
                } else {
                    _titleLabel.font = titleFont_Large;
                }
                break;
            case 3:
                if (iPhone4 || iPhone5) {
                    _titleLabel.font = [UIFont systemFontOfSize:13];
                } else {
                    _titleLabel.font = titleFont_Small;
                }
                break;
            default:
                if (iPhone4 || iPhone5) {
                    _titleLabel.font = [UIFont systemFontOfSize:15];
                } else {
                    _titleLabel.font = titleFont_Normal;
                }
                break;
        }
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)durationLabel
{
    if (_durationLabel == nil) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
        _durationLabel.font = [UIFont systemFontOfSize:11];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        _durationLabel.layer.cornerRadius = 2;
        _durationLabel.layer.masksToBounds = YES;
    }
    return _durationLabel;
}

- (UIButton *)playButton
{
    if (_playButton == nil) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"icon_video_play"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
        _playButton.adjustsImageWhenHighlighted = NO;
//        _playButton.hidden = YES;
    }
    return _playButton;
}

- (UIImageView *)watchView
{
    if (_watchView == nil) {
        _watchView = [[UIImageView alloc] init];
        _watchView.backgroundColor = [UIColor whiteColor];
        _watchView.contentMode = UIViewContentModeScaleAspectFit;
        _watchView.image = [UIImage imageNamed:@"icon_video"];
    }
    return _watchView;
}

- (UILabel *)watchLabel
{
    if (_watchLabel == nil) {
        _watchLabel = [[UILabel alloc] init];
        _watchLabel.backgroundColor = [UIColor whiteColor];
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
        [_shareButton setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
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

- (void)pausedVideo:(NSNotification *)notif
{
    NSString *newsID = notif.object;
    if (![_model.news_id isEqualToString:newsID]) {
        self.isPlay = NO;
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
