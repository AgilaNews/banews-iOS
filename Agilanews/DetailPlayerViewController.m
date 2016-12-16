//
//  DetailPlayerViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/10/25.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "DetailPlayerViewController.h"
#import "HomeViewController.h"

@interface DetailPlayerViewController ()

@end

@implementation DetailPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    CGFloat height = (_height.floatValue * .5) * (kScreenWidth / (_width.floatValue * .5));
    _playerView = [[YTPlayerView alloc] initWithFrame:CGRectMake(0, (kScreenHeight - height) * .5, kScreenWidth, height)];
    _playerView.webView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_playerView];
    NSDictionary *playerVars = @{@"autohide" : @2,          // 参数设为1，则视频进度条和播放器控件将会在视频开始播放几秒钟后退出播放界面。
                                 // 仅在用户将鼠标移动到视频播放器上方或按键盘上的某个键时，进度条和控件才会重新显示。
                                 // 参数设为0，则视频进度条和视频播放器控件在视频播放全程和全屏状态下均会显示。
                                 @"iv_load_policy" : @3,    // 将此值设为1会在默认情况下显示视频注释，而将其设为3则默认不显示。
                                 @"playsinline" : @1,       // 以内嵌方式播放还是以全屏形式播放。  1:内嵌模式  0:全屏模式
                                 @"loop" : @1,              // 是否循环播放。  0:不循环  1:循环
                                 @"rel" : @0,               // 视频播放结束时，播放器是否应显示相关视频。  0:不显示  1:显示
                                 @"autoplay" : @1,          // 自动播放
                                 @"modestbranding" : @1,    // 将参数值设为1可以阻止YouTube徽标显示在控件栏中。
                                 @"origin" : @"http://www.youtube.com",
                                 @"showinfo" : @0};         // 播放器是否显示视频标题和上传者等信息。  0:不显示  1:显示
    if (_videoid && playerVars) {
        [self.playerView loadWithVideoId:_videoid playerVars:playerVars];
    }
    self.playerView.delegate = self;
    
    _holderView = [[UIImageView alloc] initWithFrame:self.playerView.bounds];
    _holderView.contentMode = UIViewContentModeScaleAspectFill;
    _holderView.backgroundColor = [UIColor clearColor];
    [self.playerView addSubview:_holderView];
    NSString *imageUrl = [_pattern stringByReplacingOccurrencesOfString:@"{w}" withString:[NSString stringWithFormat:@"%f",(kScreenWidth * 2)]];
    imageUrl = [imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [_holderView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    
    [_holderView addSubview:self.loadingView];
    __weak typeof(self) weakSelf = self;
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.holderView.mas_centerX);
        make.centerY.mas_equalTo(weakSelf.holderView.mas_centerY);
        make.width.mas_equalTo(45);
        make.height.mas_equalTo(45);
    }];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(10, 10, 44, 44);
    [closeButton setImage:[UIImage imageNamed:@"icon_cancel"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.loadingView startAnimation];
    self.loadingView.percent = @"";
}

#pragma mark - YTPlayerViewDelegate
- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.loadingView stopAnimation];
        _holderView.hidden = YES;
        [self.playerView playVideo];
        
        // 服务器打点-详情页播放视频-020206
        NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
        [eventDic setObject:@"020206" forKey:@"id"];
        [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
        [eventDic setObject:_model.news_id forKey:@"news_id"];
        [eventDic setObject:_videoid forKey:@"video_id"];
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
    });
}
- (void)playerView:(nonnull YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{
    switch (state) {
        case kYTPlayerStatePlaying:
            SSLog(@"Started playback");
            break;
        case kYTPlayerStatePaused:
            SSLog(@"Paused playback");
            break;
        default:
            break;
    }
}
- (void)playerView:(YTPlayerView *)playerView receivedError:(YTPlayerError)error
{
    if (error) {
        // 打点-播放失败-010227
        JTNavigationController *navCtrl = (JTNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        HomeViewController *homeVC = navCtrl.jt_viewControllers.firstObject;
        NSString *channelName = homeVC.segmentVC.titleArray[homeVC.segmentVC.selectIndex - 10000];
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       channelName, @"channel",
                                       _model.news_id, @"article",
                                       [NetType getNetType], @"network",
                                       nil];
        [Flurry logEvent:@"Article_Play_Failure" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Article_Play_Failure:%@",articleParams],nil];
#endif
    }
}

#pragma mark - setter/getter
- (LoadingView *)loadingView
{
    if (_loadingView == nil) {
        _loadingView = [[LoadingView alloc] init];
    }
    return _loadingView;
}

#pragma mark - backAction关闭按钮点击事件
- (void)closeAction:(UIButton *)button
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
