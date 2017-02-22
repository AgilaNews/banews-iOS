//
//  NewsDetailViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/7/19.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "ImageModel.h"
#import "VideoModel.h"
#import "ManyPicCell.h"
#import "SinglePicCell.h"
#import "NoPicCell.h"
#import "RecommendedView.h"
#import "CommentModel.h"
#import "CommentCell.h"
#import "CommentTextField.h"
#import "GuideFavoritesView.h"
#import "DetailPlayerViewController.h"
#import "BaseNavigationController.h"
#import "HomeViewController.h"
#import "SearchViewController.h"
#import "LoginView.h"
#import "SNSModel.h"

#define titleFont_Normal        [UIFont systemFontOfSize:16]
#define titleFont_ExtraLarge    [UIFont systemFontOfSize:20]
#define titleFont_Large         [UIFont systemFontOfSize:18]
#define titleFont_Small         [UIFont systemFontOfSize:14]
#define imageHeight 155 * kScreenWidth / 320.0

@import SafariServices;
@interface NewsDetailViewController ()

@end

@implementation NewsDetailViewController

#pragma mark - 视图生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.isBackButton = YES;
    _commentArray = [NSMutableArray array];
    _pullupCount = 0;
    
    // 添加导航栏右侧按钮
//    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    shareBtn.backgroundColor = kOrangeColor;
//    shareBtn.frame = CGRectMake(0, 0, 40, 40);
//    shareBtn.imageView.backgroundColor = kOrangeColor;
//    [shareBtn setImage:[UIImage imageNamed:@"icon_article_share_default"] forState:UIControlStateNormal];
//    [shareBtn addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc]initWithCustomView:shareBtn];
//    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    moreBtn.backgroundColor = kOrangeColor;
//    moreBtn.frame = CGRectMake(0, 0, 40, 38);
//    moreBtn.imageView.backgroundColor = kOrangeColor;
//    [moreBtn setImage:[UIImage imageNamed:@"icon_article_font"] forState:UIControlStateNormal];
//    [moreBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc]initWithCustomView:moreBtn];
//    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    negativeSpacer.width = -10;
//    self.navigationItem.rightBarButtonItems = @[negativeSpacer, moreItem];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = kWhiteBgColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.sectionHeaderHeight = 0;
    _tableView.sectionFooterHeight = 0;
    _tableView.separatorColor = SSColor(235, 235, 235);
    [self.view addSubview:_tableView];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64)];
    _webView.backgroundColor = kWhiteBgColor;
    _webView.delegate = self;
    _webView.scrollView.delegate = self;
    _webView.scrollView.scrollsToTop = NO;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    
    __weak typeof(self) weakSelf = self;
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_webView];
    [_bridge setWebViewDelegate:self];
    [_bridge registerHandler:@"ObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback)
     {
         [weakSelf createImageFolderAtPath];
         NSString *type = data[@"type"];
         if ([type isEqualToString:@"video"]) {
             // 打点-点击播放-010226
             UIViewController *viewCtrl = (JTNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
             if ([viewCtrl isKindOfClass:[UITabBarController class]]) {
                 UITabBarController *tabBarVC = (UITabBarController *)viewCtrl;
                 JTNavigationController *navCtrl = tabBarVC.viewControllers.firstObject;
                 HomeViewController *homeVC = navCtrl.jt_viewControllers.firstObject;
                 NSString *channelName = homeVC.segmentVC.titleArray[homeVC.segmentVC.selectIndex - 10000];
                 NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                                channelName, @"channel",
                                                weakSelf.model.news_id, @"article",
                                                [NetType getNetType], @"network",
                                                nil];
                 [Flurry logEvent:@"Article_Play_Click" withParameters:articleParams];
             }
             // 视频
             NSString *videoid = data[@"videoid"];
             DetailPlayerViewController *detailPlayerVC = [[DetailPlayerViewController alloc] init];
             NSNumber *index = data[@"index"];
             VideoModel *model = weakSelf.detailModel.youtube_videos[index.intValue];
             detailPlayerVC.width = model.width;
             detailPlayerVC.height = model.height;
             detailPlayerVC.pattern = model.pattern;
             detailPlayerVC.videoid = videoid;
             detailPlayerVC.model = weakSelf.model;
             [[UIApplication sharedApplication] setStatusBarHidden:YES];
             detailPlayerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
             [weakSelf presentViewController:detailPlayerVC animated:YES completion:nil];
         } else {
             // 图片
             NSString *urlString = data[@"url"];
             NSNumber *callbackId = data[@"id"];
             urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
             NSString *md5String = [NSString encryptPassword:urlString];
             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
             NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"ImageFolder/%@.jpg", md5String]];
             NSFileManager *fileManager = [NSFileManager defaultManager];
             if ([fileManager fileExistsAtPath:filePath]) {
                 NSString *imagePath = [NSString stringWithFormat:@"file://%@/",filePath];
                 responseCallback(@{
                                    @"path": imagePath,
                                    @"id": callbackId
                                    });
             } else {
                 SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
                 [downloader downloadImageWithURL:[NSURL URLWithString:urlString]
                                          options:0
                                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                             // progression tracking code
                                         }
                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                            if (image && finished) {
                                                if ([data writeToFile:filePath atomically:YES]) {
                                                    NSString *imagePath = [NSString stringWithFormat:@"file://%@/",filePath];
                                                    responseCallback(@{
                                                                       @"path": imagePath,
                                                                       @"id": callbackId
                                                                       });
                                                }
                                            }
                                        }];
             }
         }
     }];
    // 检查是否有新广告
    [[FacebookAdManager sharedInstance] checkNewAdNumWithType:DetailAd];
    // 请求新闻详情
    [self requestDataWithNewsID:_model.news_id ShowHUD:YES];
    
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginSuccess)
                                                 name:KNOTIFICATION_Login_Success
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHidden)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fontChange)
                                                 name:KNOTIFICATION_FontSize_Change
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(touchFavorite)
                                                 name:KNOTIFICATION_TouchFavorite
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _enterTime = [[NSDate date] timeIntervalSince1970];
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:_enterTime], @"time",
                                   _channelName, @"channel",
                                   _model.news_id, @"article",
                                   [NetType getNetType], @"network",
                                   nil];
    if (_isPushEnter) {
        // 打点-推送新闻详情页进入-010007
        [Flurry logEvent:@"PushArticle_Enter" withParameters:articleParams];
//#if DEBUG
//        [iConsole info:[NSString stringWithFormat:@"PushArticle_Enter:%@",articleParams],nil];
//#endif
    } else {
        // 打点-页面进入-010201
        [Flurry logEvent:@"Article_Enter" withParameters:articleParams];
//#if DEBUG
//        [iConsole info:[NSString stringWithFormat:@"Article_Enter:%@",articleParams],nil];
//#endif
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    // 打点-文章页退出-010225
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   _channelName, @"channel",
                                   _model.news_id, @"article",
                                   [NetType getNetType], @"network",
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] - _enterTime], @"residence_time",
                                   nil];
    [Flurry logEvent:@"Article_Exit" withParameters:articleParams];
//#if DEBUG
//    [iConsole info:[NSString stringWithFormat:@"Article_Exit:%@",articleParams],nil];
//#endif
    if (_isPushEnter) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_PushExit object:nil];
    }
}

- (void)dealloc
{
    [_task cancel];
    [SVProgressHUD dismiss];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_model.news_id.length <= 0) {
        return;
    }
    // 服务器打点-详情页返回-020201
    NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
    [eventDic setObject:@"020201" forKey:@"id"];
    [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
    [eventDic setObject:_model.news_id forKey:@"news_id"];
    float pagePos = (_tableView.contentOffset.y + kScreenHeight - 64 - 50) / _tableView.contentSize.height;
    [eventDic setObject:[NSString stringWithFormat:@"%.1f",MAX(pagePos, 1)] forKey:@"page_pos"];
    float duration = ([[NSDate date] timeIntervalSince1970] * 1000 - _enterTime * 1000) / 1000.0;
    [eventDic setObject:[NSString stringWithFormat:@"%.1f",duration] forKey:@"duration"];
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
    
    // 检查是否有新通知
    NSInteger num = arc4random() % 10;
    if (num / 2 == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CheckNewNotif object:nil];
    }
}

#pragma mark - Network
/**
 *  请求新闻详情
 *
 *  @param newID 新闻ID
 */
- (void)requestDataWithNewsID:(NSString *)newsID ShowHUD:(BOOL)showHUD
{
    __weak typeof(self) weakSelf = self;
    if (showHUD) {
        SVProgressHUD.defaultStyle = SVProgressHUDStyleCustom;
        [SVProgressHUD show];
    }
    if (!newsID) {
        [SVProgressHUD dismiss];
        if (!_blankView) {
            _blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, weakSelf.view.width, weakSelf.view.height)];
            _blankView.backgroundColor = [UIColor whiteColor];
            _blankView.userInteractionEnabled = YES;
            [weakSelf.view addSubview:_blankView];
            _failureView = [[UIImageView alloc] initWithFrame:CGRectMake((_blankView.width - 28) * .5, 200 / kScreenHeight * 568 + 64, 28, 26)];
            _failureView.image = [UIImage imageNamed:@"icon_common_netoff"];
            [_blankView addSubview:_failureView];
            _blankLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 300) * .5, _failureView.bottom + 13, 300, 20)];
            _blankLabel.backgroundColor = [UIColor whiteColor];
            _blankLabel.textAlignment = NSTextAlignmentCenter;
            _blankLabel.textColor = SSColor(177, 177, 177);
            _blankLabel.font = [UIFont systemFontOfSize:16];
            [_blankView addSubview:_blankLabel];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(requestData)];
            [_blankView addGestureRecognizer:tap];
        }
        weakSelf.blankLabel.text = @"Sorry,please try again";
        weakSelf.failureView.image = [UIImage imageNamed:@"icon_common_failed"];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:newsID forKey:@"news_id"];
//    [params setObject:@"1l+ULtd4zog=" forKey:@"news_id"];
    _task = [[SSHttpRequest sharedInstance] get:kHomeUrl_NewsDetail params:params contentType:UrlencodedType serverType:NetServer_Home success:^(id responseObj) {
        if (_blankView) {
            [_blankView removeFromSuperview];
            [_blankLabel removeFromSuperview];
            _blankView = nil;
            _blankLabel = nil;
        }
        _adInfo = responseObj[@"ad"];
        if (_adInfo && _adInfo.count > 0) {
            FBNativeAd *nativeAd = [[FacebookAdManager sharedInstance] getFBNativeAdFromDetailADArray];
            if (nativeAd) {
                _isHaveAd = YES;
                _facebookAdView = [[FacebookAdView alloc] initWithNativeAd:nativeAd AdId:_adInfo[@"ad_id"]];
            }
        }
        weakSelf.detailModel = [NewsDetailModel mj_objectWithKeyValues:responseObj];
        // css文件路径
        NSString *cssFilePath = [[NSBundle mainBundle] pathForResource:@"webView" ofType:@"css"];
//        NSString *cssFilePath = @"http://192.168.31.131/detail/css/detail.css";
        
        NSString *jsFilePath = [[NSBundle mainBundle] pathForResource:@"webView" ofType:@"js"];
        // 格式化日期
        NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:[weakSelf.detailModel.public_time longLongValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [dateFormatter stringFromDate:currentDate];
        // 替换图片url
        @autoreleasepool {
            for (int i = 0; i < weakSelf.detailModel.imgs.count; i++) {
                if ([DEF_PERSISTENT_GET_OBJECT(SS_textOnlyMode) isEqualToNumber:@1]) {
                    NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"textonly" ofType:@"png"];
                    NSString *imageUrl = [NSString stringWithFormat:@"<img src=file:///%@/>",imageFilePath];
                    weakSelf.detailModel.body = [weakSelf.detailModel.body stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<!--IMG%d-->",i] withString:imageUrl];
                } else {
                    ImageModel *imageModel = weakSelf.detailModel.imgs[i];
                    NSString *imageUrl = [NSString stringWithFormat:@"<img src=\"\" data-src=\"%@\" height=\"%fpx\" width=\"%fpx\" img-type=\"image\" class=\"ready-to-load\"/>",imageModel.src, imageModel.height.integerValue / 2.0, imageModel.width.integerValue / 2.0];
                    weakSelf.detailModel.body = [weakSelf.detailModel.body stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<!--IMG%d-->",i] withString:imageUrl];
                }
            }
            for (int i = 0; i < weakSelf.detailModel.youtube_videos.count; i++) {
                if ([DEF_PERSISTENT_GET_OBJECT(SS_textOnlyMode) isEqualToNumber:@1]) {
                    NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"textonly" ofType:@"png"];
                    NSString *imageUrl = [NSString stringWithFormat:@"<img src=file:///%@/>",imageFilePath];
                    weakSelf.detailModel.body = [weakSelf.detailModel.body stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<!--YOUTUBE%d-->",i] withString:imageUrl];
                } else {
                    VideoModel *videoModel = weakSelf.detailModel.youtube_videos[i];
                    NSString *imageUrl = [NSString stringWithFormat:@"<img src=\"\" data-src=\"%@\" height=\"%dpx\" width=\"%dpx\" img-type=\"video\" videoid=\"%@\" index=\"%d\" class=\"ready-to-load\"/>", videoModel.video_pattern, (int)(videoModel.height.integerValue * 0.5), (int)(videoModel.width.integerValue * 0.5), videoModel.youtube_id, i];
                    imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{w}" withString:[NSString stringWithFormat:@"%d",(int)(videoModel.width.integerValue * 0.5)]];
                    weakSelf.detailModel.body = [weakSelf.detailModel.body stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<!--YOUTUBE%d-->",i] withString:imageUrl];
                }
            }
            for (int i = 0; i < weakSelf.detailModel.sns_widgets.count; i++) {
                SNSModel *snsModel = weakSelf.detailModel.sns_widgets[i];
                NSString *snsString = @"<section class=\"sns-container\"><div class=\"sns-info\">";
                snsString = [snsString stringByAppendingFormat:@"<img src=\"%@\" class=\"sns-avatar\"/>", snsModel.sns_icon];
                snsString = [snsString stringByAppendingFormat:@"<div class=\"sns-name\">%@</div>", snsModel.sns_name];
                switch (snsModel.sns_type.integerValue) {
                    case 1:
                    {
                        snsString = [snsString stringByAppendingString:@"<div class=\"sns-logo embed-facebook\"></div></div>"];
                        break;
                    }
                    case 2:
                    {
                        snsString = [snsString stringByAppendingString:@"<div class=\"sns-logo embed-twitter\"></div></div>"];
                        break;
                    }
                    case 3:
                    {
                        snsString = [snsString stringByAppendingString:@"<div class=\"sns-logo embed-instagram\"></div></div>"];
                        break;
                    }
                    default:
                        break;
                }
                NSString *imageUrl = nil;
                if ([DEF_PERSISTENT_GET_OBJECT(SS_textOnlyMode) isEqualToNumber:@1]) {
                    NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"textonly" ofType:@"png"];
                    imageUrl = [NSString stringWithFormat:@"<img src=file:///%@/>",imageFilePath];
                } else {
                    imageUrl = [NSString stringWithFormat:@"<img src=\"\" data-src=\"%@\" height=\"%fpx\" width=\"%fpx\" img-type=\"image\" class=\"ready-to-load\"/>",snsModel.pattern, snsModel.height.integerValue / 2.0, snsModel.width.integerValue / 2.0];
                    imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"{w}" withString:[NSString stringWithFormat:@"%ld",snsModel.width.integerValue / 2]];
                }
                snsString = [snsString stringByAppendingString:imageUrl];
                snsString = [snsString stringByAppendingFormat:@"<div class=\"sns-content\">%@</div></section>", snsModel.sns_content];
                weakSelf.detailModel.body = [weakSelf.detailModel.body stringByReplacingOccurrencesOfString:snsModel.name withString:snsString];
            }
        }
        // 拼接HTML
        NSString *htmlString = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"file:///%@\"/><script src=\"file://%@\"></script></head><body><div class=\"title\">%@</div><div class=\"sourcetime\">%@&nbsp;&nbsp;&nbsp;%@<a class=\"source\" href=\"%@\"> /View source</a></div>%@",cssFilePath,jsFilePath,weakSelf.detailModel.title,dateString,weakSelf.detailModel.source,weakSelf.detailModel.source_url,weakSelf.detailModel.body];
        htmlString = [htmlString stringByAppendingString:@"</body></html>"];
        [_webView loadHTMLString:htmlString baseURL:nil];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (!_blankView) {
            _blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, weakSelf.view.width, weakSelf.view.height)];
            _blankView.backgroundColor = [UIColor whiteColor];
            _blankView.userInteractionEnabled = YES;
            [weakSelf.view addSubview:_blankView];
            _failureView = [[UIImageView alloc] initWithFrame:CGRectMake((_blankView.width - 28) * .5, 200 / kScreenHeight * 568 + 64, 28, 26)];
            _failureView.image = [UIImage imageNamed:@"icon_common_netoff"];
            [_blankView addSubview:_failureView];
            _blankLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 300) * .5, _failureView.bottom + 13, 300, 20)];
            _blankLabel.backgroundColor = [UIColor whiteColor];
            _blankLabel.textAlignment = NSTextAlignmentCenter;
            _blankLabel.textColor = SSColor(177, 177, 177);
            _blankLabel.font = [UIFont systemFontOfSize:16];
            [_blankView addSubview:_blankLabel];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(requestData)];
            [_blankView addGestureRecognizer:tap];
        }
        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
            weakSelf.blankLabel.text = @"Network unavailable";
            weakSelf.failureView.image = [UIImage imageNamed:@"icon_common_netoff"];
        } else {
            weakSelf.blankLabel.text = @"Sorry,please try again";
            weakSelf.failureView.image = [UIImage imageNamed:@"icon_common_failed"];
        }
    } isShowHUD:NO];
}

/**
 *  失败页面请求网络
 */
- (void)requestData
{
    if (self.blankView) {
        [self.blankView removeFromSuperview];
        self.blankView = nil;
        SVProgressHUD.defaultStyle = SVProgressHUDStyleCustom;
        [SVProgressHUD show];
    }
    [self requestDataWithNewsID:_model.news_id ShowHUD:NO];
}

/**
 *  上拉加载评论
 */
- (void)tableViewDidTriggerFooterRefresh
{
    _pullupCount++;
    if (_pullupCount > 1) {
        // 打点-页面进入-010301
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _channelName, @"channel",
                                       _model.news_id, @"article",
                                       [NetType getNetType], @"network",
                                       nil];
        [Flurry logEvent:@"Comments_Enter" withParameters:articleParams];
//#if DEBUG
//        [iConsole info:[NSString stringWithFormat:@"Comments_Enter:%@",articleParams],nil];
//#endif
    } else {
        // 打点-上拉加载-010302
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _channelName, @"channel",
                                       _model.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Comments_List_UpLoad" withParameters:articleParams];
//#if DEBUG
//        [iConsole info:[NSString stringWithFormat:@"Comments_List_UpLoad:%@",articleParams],nil];
//#endif
    }
    
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_model.news_id forKey:@"news_id"];
    [params setObject:@"later" forKey:@"prefer"];
    CommentModel *commentModel = _commentArray.lastObject;
    [params setObject:commentModel.commentID forKey:@"last_id"];
    [[SSHttpRequest sharedInstance] get:kHomeUrl_Comment params:params contentType:UrlencodedType serverType:NetServer_Home success:^(id responseObj) {
        [_tableView.footer endRefreshing];
        NSArray *array = responseObj[@"new"];
        if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
            NSMutableArray *models = [NSMutableArray array];
            @autoreleasepool {
                for (NSDictionary *dic in array) {
                    CommentModel *model = [CommentModel mj_objectWithKeyValues:dic];
                    [models addObject:model];
                }
            }
            [weakSelf.commentArray addObjectsFromArray:models];
            [weakSelf.tableView reloadData];
        } else {
            _tableView.footer.state = MJRefreshFooterStateNoMoreData;
        }
        if (_pullupCount > 1) {
            // 打点-上拉加载成功-010303
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _channelName, @"channel",
                                           _model.news_id, @"article",
                                           nil];
            [Flurry logEvent:@"Comments_List_UpLoad_Y" withParameters:articleParams];
//#if DEBUG
//            [iConsole info:[NSString stringWithFormat:@"Comments_List_UpLoad_Y:%@",articleParams],nil];
//#endif
        }
    } failure:^(NSError *error) {
        [_tableView.footer endRefreshing];
        if (_pullupCount > 1) {
            // 打点-上拉加载失败-010304
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _channelName, @"channel",
                                           _model.news_id, @"article",
                                           nil];
            [Flurry logEvent:@"Comments_List_UpLoad_N" withParameters:articleParams];
//#if DEBUG
//            [iConsole info:[NSString stringWithFormat:@"Comments_List_UpLoad_N:%@",articleParams],nil];
//#endif
        }
    } isShowHUD:NO];
}

/**
 *  点赞按钮网络请求
 *
 *  @param appDelegate
 *  @param button      点赞按钮
 */
- (void)likedNewsWithAppDelegate:(AppDelegate *)appDelegate button:(UIButton *)button
{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_model.news_id forKey:@"news_id"];
    [[SSHttpRequest sharedInstance] post:kHomeUrl_Like params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        [appDelegate.likedDic setValue:@1 forKey:_model.news_id];
        _detailModel.likedCount = responseObj[@"liked"];
        [button setTitle:[NSString stringWithFormat:@"%@",responseObj[@"liked"]] forState:UIControlStateNormal];
        weakSelf.likeButton.selected = YES;
    } failure:^(NSError *error) {
//        [button setTitle:[NSString stringWithFormat:@"%d",button.titleLabel.text.intValue - 1] forState:UIControlStateNormal];
//        weakSelf.likeButton.selected = NO;
    } isShowHUD:NO];
}

/**
 *  收藏新闻网络请求
 *
 *  @param button 收藏按钮
 */
- (void)collectNewsWithButton:(UIButton *)button
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.model) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:_model.news_id forKey:@"news_id"];
        [params setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] forKey:@"ctime"];
        NSArray *paramsArray = [NSArray arrayWithObject:params];
        __weak typeof(self) weakSelf = self;
        [[SSHttpRequest sharedInstance] post:kHomeUrl_Collect params:paramsArray contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
            NSArray *result = responseObj;
            if (result) {
                weakSelf.collectID = result.firstObject[@"collect_id"];
                button.selected = YES;
                [SVProgressHUD showSuccessWithStatus:@"Save the news and read it later by entering 'Favorites'"];
                [[CoreDataManager sharedInstance] addAccountFavoriteWithCollectID:weakSelf.collectID DetailModel:_detailModel];

                // 打点-收藏成功-010215
                NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                               _channelName, @"channel",
                                               _model.news_id, @"article",
                                               nil];
                [Flurry logEvent:@"Article_Favorite_Click_Y" withParameters:articleParams];
//#if DEBUG
//                [iConsole info:[NSString stringWithFormat:@"Article_Favorite_Click_Y:%@",articleParams],nil];
//#endif
            }
        } failure:^(NSError *error) {
            button.selected = NO;
            // 打点-收藏失败-010216
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _channelName, @"channel",
                                           _model.news_id, @"article",
                                           nil];
            [Flurry logEvent:@"Article_Favorite_Click_N" withParameters:articleParams];
//#if DEBUG
//            [iConsole info:[NSString stringWithFormat:@"Article_Favorite_Click_N:%@",articleParams],nil];
//#endif
        } isShowHUD:YES];
    } else if (_detailModel && _model) {
        // 新闻详情本地缓存
        NSString *time = [NSString stringWithFormat:@"%@",[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]];
        if (_isPushEnter) {
            _model = [[NewsModel alloc] init];
            _model.imgs = _detailModel.imgs;
            _model.news_id = _detailModel.news_id;
            _model.public_time = _detailModel.public_time;
            _model.source = _detailModel.source;
            _model.title = _detailModel.title;
        }
        [[CoreDataManager sharedInstance] addLocalFavoriteWithNewsID:_model.news_id DetailModel:_detailModel CollectTime:time NewsModel:_model];
        button.selected = YES;
        [SVProgressHUD showSuccessWithStatus:@"Save the news and read it later by entering 'Favorites'"];
        // 打点-收藏成功-010215
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _channelName, @"channel",
                                       _model.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Article_Favorite_Click_Y" withParameters:articleParams];
//#if DEBUG
//        [iConsole info:[NSString stringWithFormat:@"Article_Favorite_Click_Y:%@",articleParams],nil];
//#endif
    }
}

/**
 *  删除收藏网络请求
 *
 *  @param button 收藏按钮
 */
- (void)deleteCollectNewsWithButton:(UIButton *)button
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.model && _collectID) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:@[_collectID] forKey:@"ids"];
        [[SSHttpRequest sharedInstance] DELETE:kHomeUrl_Collect params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
            button.selected = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_RemoveFavorite object:_model.news_id];
        } failure:^(NSError *error) {
            
        } isShowHUD:NO];
    } else {
        [[CoreDataManager sharedInstance] removeLocalFavoriteModelWithNewsIDs:[NSArray arrayWithObject:_model.news_id]];
        button.selected = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_RemoveFavorite object:_model.news_id];
    }
}

/**
 *  发布评论网络请求
 */
- (void)postComment
{
    _commentTextView.sendButton.enabled = NO;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_model.news_id forKey:@"news_id"];
    [params setObject:_commentTextView.textView.text forKey:@"comment_detail"];
    if (_commentID) {
        [params setObject:_commentID forKey:@"ref_id"];
    }
    [[SSHttpRequest sharedInstance] post:kHomeUrl_Comment params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        _commentTextView.sendButton.enabled = YES;
        NSNumber *animation = responseObj[@"Animation"];
        if (animation && [animation isEqualToNumber:@1]) {
            if (!self.emojiFlay) {
                self.emojiFlay = [LSEmojiFly emojiFly];
                NSArray *imageNames = @[@"ChristmasTrees",@"donut",@"FatherChristmas",@"socks",@"wapiti"];
                NSInteger imageIndex = arc4random() % 5;
                [self.emojiFlay startFlyWithEmojiImage:[UIImage imageNamed:imageNames[imageIndex]] onView:self.view];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.emojiFlay endFly];
                self.emojiFlay = nil;
            });
        }
        CommentModel *model = [CommentModel mj_objectWithKeyValues:responseObj];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        model.user_id = appDelegate.model.user_id;
        model.user_name = appDelegate.model.name;
        model.user_portrait_url = appDelegate.model.portrait;
        model.comment = _commentTextView.textView.text;
        for (CommentModel *commentModel in _commentArray) {
            if (_commentID && [commentModel.commentID isEqualToNumber:_commentID]) {
                model.reply = commentModel;
                _commentID = nil;
                break;
            }
        }
        if (model) {
            [weakSelf.commentArray insertObject:model atIndex:0];
            weakSelf.commentArray = weakSelf.commentArray;
            _commentsLabel.hidden = NO;
            if (_model) {
                _model.commentCount = [NSNumber numberWithInteger:_model.commentCount.integerValue + 1];
            }
            _detailModel.commentCount = [NSNumber numberWithInteger:_detailModel.commentCount.integerValue + 1];
            if (_detailModel.commentCount.integerValue < 1000) {
                _commentsLabel.text = _detailModel.commentCount.stringValue;
            } else {
                _commentsLabel.text = @"999+";
            }
            CGSize commentSize = [_detailModel.commentCount.stringValue calculateSize:CGSizeMake(40, 10) font:_commentsLabel.font];
            _commentsLabel.width = MAX(commentSize.width + 5, 10);
        }
        [_tableView reloadData];
        [_commentTextView.textView resignFirstResponder];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        [UIView animateWithDuration:0.3 animations:^{
            _commentTextView.shadowView.alpha = 0;
            _commentTextView.bgView.alpha = 0;
        } completion:^(BOOL finished) {
            [_commentTextView removeFromSuperview];
            _commentTextView = nil;
        }];
        [SVProgressHUD showSuccessWithStatus:@"Successful"];
        // 打点-评论成功-010210
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _channelName, @"channel",
                                       _model.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Article_Comments_Send_Y" withParameters:articleParams];
//#if DEBUG
//        [iConsole info:[NSString stringWithFormat:@"Article_Comments_Send_Y:%@",articleParams],nil];
//#endif
    } failure:^(NSError *error) {
        _commentTextView.sendButton.enabled = YES;
        // 打点-评论失败-010211
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _channelName, @"channel",
                                       _model.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Article_Comments_Send_N" withParameters:articleParams];
//#if DEBUG
//        [iConsole info:[NSString stringWithFormat:@"Article_Comments_Send_N:%@",articleParams],nil];
//#endif
    } isShowHUD:YES];
}

/**
 评论点赞网络请求
 
 @param button
 */
- (void)commentLike:(UIButton *)button
{
    // 打点-点击评论点赞按钮-010228
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   _model.channel_id, @"channel",
                                   _model.news_id, @"article",
                                   [NetType getNetType], @"network",
                                   nil];
    [Flurry logEvent:@"Article_CommentsLike_Click" withParameters:articleParams];
//#if DEBUG
//    [iConsole info:[NSString stringWithFormat:@"Article_CommentsLike_Click:%@",articleParams],nil];
//#endif
    if (button.selected == YES) {
        return;
    }
    if ([button.superview.superview isKindOfClass:[CommentCell class]]) {
        CommentCell *cell = (CommentCell *)button.superview.superview;
        NSNumber *likeNum = [NSNumber numberWithInteger:cell.model.liked.integerValue + 1];
        cell.model.liked = likeNum;
        cell.model.device_liked = @1;
        [button setTitle:[NSString stringWithFormat:@"%@",likeNum] forState:UIControlStateNormal];
        button.selected = YES;
        [cell setNeedsLayout];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:cell.model.commentID forKey:@"comment_id"];
        [[SSHttpRequest sharedInstance] post:kHomeUrl_CommentLike params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
            NSNumber *likeNum = responseObj[@"liked"];
            if (likeNum.integerValue > 0) {
                cell.model.liked = likeNum;
                cell.model.device_liked = @1;
                [button setTitle:[NSString stringWithFormat:@"%@",likeNum] forState:UIControlStateNormal];
                button.selected = YES;
                [cell setNeedsLayout];
            }
        } failure:^(NSError *error) {
            //        [button setTitle:[NSString stringWithFormat:@"%d",button.titleLabel.text.intValue - 1] forState:UIControlStateNormal];
            //        weakSelf.likeButton.selected = NO;
        } isShowHUD:NO];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_webView.isLoading || !_detailModel) {
        return 1;
    } else if (_detailModel.hotComments.count > 0){
        return 4;
    } else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            return MIN(_detailModel.recommend_news.count + 1, 4);
        case 2:
            if (_detailModel.hotComments.count > 0) {
                return _hotCommentArray.count + 1;
            }
            if (_commentArray.count > 0) {
                return _commentArray.count + 1;
            } else {
                return 2;
            }
        case 3:
            if (_commentArray.count > 0) {
                return _commentArray.count + 1;
            } else {
                return 2;
            }
        default:
            return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 8)];
        view.backgroundColor = SSColor(235, 235, 235);
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1 || section == 2) {
        return 8;
    } else {
        return 0.00001f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            if (_detailModel == nil) {
                return kScreenHeight;
            } else {
                BOOL isHaveTag = self.detailModel.tags.count;
                if (_isHaveAd) {
                    return _webViewHeight + (isHaveTag ? self.tagView.height + 26 : 0) + 34 + 25 + 83 + imageHeight;
                } else {
                    return _webViewHeight + (isHaveTag ? self.tagView.height + 26 : 0) + 34 + 25;
                }
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    return 30;
                    break;
                default:
                {
                    NewsModel *model = _detailModel.recommend_news[indexPath.row - 1];
                    UIFont *titleFont = nil;
                    switch ([DEF_PERSISTENT_GET_OBJECT(SS_FontSize) integerValue]) {
                        case 0:
                            titleFont = titleFont_Normal;
                            break;
                        case 1:
                            titleFont = titleFont_ExtraLarge;
                            break;
                        case 2:
                            titleFont = titleFont_Large;
                            break;
                        case 3:
                            titleFont = titleFont_Small;
                            break;
                        default:
                            titleFont = titleFont_Normal;
                            break;
                    }
                    switch ([model.tpl integerValue])
                    {
                        case NEWS_ManyPic:
                        {
                            return 12 + 68 + 12;
                        }
                        case NEWS_SinglePic:
                        {
                            return 12 + 68 + 12;
                        }
                        case NEWS_NoPic:
                        {
                            CGSize titleLabelSize = [model.title calculateSize:CGSizeMake(kScreenWidth - 22, 60) font:titleFont];
                            return 11 + titleLabelSize.height + 15 + 11 + 11;
                        }
                        case NEWS_BigPic:
                        {
                            return 12 + 68 + 12;
                        }
                        case NEWS_HaveVideo:
                        {
                            return 12 + 68 + 12;
                        }
                        default:
                            return 50;
                    }
                    break;
                }
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    return 30;
                    break;
                default:
                {
                    if (_hotCommentArray.count > 0) {
                        CommentModel *model = _hotCommentArray[indexPath.row - 1];
                        CGSize commentLabelSize = [model.comment calculateSize:CGSizeMake(kScreenWidth - 55 - 11, 1000) font:[UIFont systemFontOfSize:15]];
                        CommentModel *commentModel = model.reply;
                        if (commentModel.comment) {
                            NSString *replyString = [NSString stringWithFormat:@"@%@: %@",commentModel.user_name,commentModel.comment];
                            CGSize replyLabelSize = [replyString calculateSize:CGSizeMake(kScreenWidth - 11 - 7 - 55, 1000) font:[UIFont systemFontOfSize:13]];
                            return 10 + 5 + 16 + 12 + commentLabelSize.height + 5 + 12 + 9 + replyLabelSize.height + 10;
                        }
                        return 10 + 5 + 16 + 12 + commentLabelSize.height + 5 + 12 + 9;
                    }
                    if (_commentArray.count > 0) {
                        CommentModel *model = _commentArray[indexPath.row - 1];
                        CGSize commentLabelSize = [model.comment calculateSize:CGSizeMake(kScreenWidth - 55 - 11, 1000) font:[UIFont systemFontOfSize:15]];
                        CommentModel *commentModel = model.reply;
                        if (commentModel.comment) {
                            NSString *replyString = [NSString stringWithFormat:@"@%@: %@",commentModel.user_name,commentModel.comment];
                            CGSize replyLabelSize = [replyString calculateSize:CGSizeMake(kScreenWidth - 11 - 7 - 55, 1000) font:[UIFont systemFontOfSize:13]];
                            return 10 + 5 + 16 + 12 + commentLabelSize.height + 5 + 12 + 9 + replyLabelSize.height + 10;
                        }
                        return 10 + 5 + 16 + 12 + commentLabelSize.height + 5 + 12 + 9;
                    } else {
                        return 90;
                    }
                }
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                    return 30;
                    break;
                default:
                {
                    if (_commentArray.count > 0) {
                        CommentModel *model = _commentArray[indexPath.row - 1];
                        CGSize commentLabelSize = [model.comment calculateSize:CGSizeMake(kScreenWidth - 55 - 11, 1000) font:[UIFont systemFontOfSize:15]];
                        CommentModel *commentModel = model.reply;
                        if (commentModel.comment) {
                            NSString *replyString = [NSString stringWithFormat:@"@%@: %@",commentModel.user_name,commentModel.comment];
                            CGSize replyLabelSize = [replyString calculateSize:CGSizeMake(kScreenWidth - 11 - 7 - 55, 1000) font:[UIFont systemFontOfSize:13]];
                            return 10 + 5 + 16 + 12 + commentLabelSize.height + 5 + 12 + 9 + replyLabelSize.height + 10;
                        }
                        return 10 + 5 + 16 + 12 + commentLabelSize.height + 5 + 12 + 9;
                    } else {
                        return 90;
                    }
                }
            }
            break;
        default:
            return 50;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

    switch (indexPath.section) {
        case 0:
        {
            // 新闻详情
            static NSString *cellID = @"webCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }
            [cell.contentView addSubview:_webView];
            BOOL isHaveTag = self.detailModel.tags.count;
            if (isHaveTag) {
                [cell.contentView addSubview:self.tagView];
                self.tagView.top = _webView.bottom;
            }
            [cell.contentView addSubview:self.likeButton];
            self.likeButton.top = isHaveTag ? self.tagView.bottom + 25 : _webView.bottom;
            [cell.contentView addSubview:self.facebookShare];
            self.facebookShare.top = self.likeButton.top;
            if (_isHaveAd) {
                [cell.contentView addSubview:self.facebookAdView];
                self.facebookAdView.top = self.likeButton.bottom + 25;
            }
            break;
        }
        case 1:
        {
            // 推荐新闻
            switch (indexPath.row) {
                case 0:
                {
                    static NSString *cellID = @"recommendedCellID";
                    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                    }
                    if (cell.contentView.subviews.count <= 0) {
                        RecommendedView *recommendedView = [[RecommendedView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30) titleImage:[UIImage imageNamed:@"icon_article_recommend_small"] titleText:@"Recommended for you" HaveLoading:NO];
                        [cell.contentView addSubview:recommendedView];
                    }
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    return cell;
                }
                default:
                {
                    NewsModel *model = _detailModel.recommend_news[indexPath.row - 1];
                    switch ([model.tpl integerValue])
                    {
                        case NEWS_ManyPic:
                        {
                            // 单图cell
                            static NSString *cellID = @"SinglePicCellID";
                            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                            if (cell == nil) {
                                cell = [[SinglePicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:kWhiteBgColor];
                            }
                            ((SinglePicCell *)cell).model = model;
                            [cell setNeedsLayout];
                            return cell;
                        }
                        case NEWS_SinglePic:
                        {
                            // 单图cell
                            static NSString *cellID = @"SinglePicCellID";
                            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                            if (cell == nil) {
                                cell = [[SinglePicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:kWhiteBgColor];
                            }
                            ((SinglePicCell *)cell).model = model;
                            ((SinglePicCell *)cell).isHaveVideo = NO;
                            [cell setNeedsLayout];
                            return cell;
                        }
                        case NEWS_NoPic:
                        {
                            // 无图cell
                            static NSString *cellID = @"NoPicCellID";
                            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                            if (cell == nil) {
                                cell = [[NoPicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:kWhiteBgColor];
                            }
                            ((NoPicCell *)cell).model = model;
                            [cell setNeedsLayout];
                            return cell;
                        }
                        case NEWS_BigPic:
                        {
                            // 单图cell
                            static NSString *cellID = @"SinglePicCellID";
                            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                            if (cell == nil) {
                                cell = [[SinglePicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:kWhiteBgColor];
                            }
                            ((SinglePicCell *)cell).model = model;
                            [cell setNeedsLayout];
                            return cell;
                        }
                        case NEWS_HaveVideo:
                        {
                            // 单图cell
                            static NSString *cellID = @"SinglePicCellID";
                            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                            if (cell == nil) {
                                cell = [[SinglePicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:kWhiteBgColor];
                            }
                            ((SinglePicCell *)cell).model = model;
                            ((SinglePicCell *)cell).isHaveVideo = YES;
                            [cell setNeedsLayout];
                            return cell;
                        }
                    }
                }
            }
            break;
        }
        case 2:
        {
            // 新闻评论
            if (_hotCommentArray.count > 0) {
                switch (indexPath.row) {
                    case 0:
                    {
                        static NSString *cellID = @"HotCommentsCellID";
                        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                        if (cell == nil) {
                            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                        }
                        if (cell.contentView.subviews.count <= 0) {
                            RecommendedView *recommendedView = [[RecommendedView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30) titleImage:[UIImage imageNamed:@"icon_hotcomment"] titleText:@"Hot Comments" HaveLoading:NO];
                            [cell.contentView addSubview:recommendedView];
                        }
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        return cell;
                    }
                    default:
                    {
                        // 评论cell
                        static NSString *cellID = @"commentID";
                        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                        if (cell == nil) {
                            cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                            [((CommentCell *)cell).likeButton addTarget:self action:@selector(commentLike:) forControlEvents:UIControlEventTouchUpInside];
                            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentAction:)];
                            [((CommentCell *)cell).replyLabel addGestureRecognizer:tap];
                        }
                        ((CommentCell *)cell).model = _hotCommentArray[indexPath.row - 1];
                        [cell setNeedsLayout];
                        return cell;
                    }
                }
            } else {
                switch (indexPath.row) {
                    case 0:
                    {
                        static NSString *cellID = @"commentsCellID";
                        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                        if (cell == nil) {
                            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                        }
                        if (cell.contentView.subviews.count <= 0) {
                            RecommendedView *recommendedView = [[RecommendedView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30) titleImage:[UIImage imageNamed:@"icon_newcomment"] titleText:@"Comments" HaveLoading:NO];
                            [cell.contentView addSubview:recommendedView];
                        }
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        return cell;
                    }
                    default:
                    {
                        // 评论cell
                        static NSString *cellID = @"commentID";
                        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                        if (cell == nil) {
                            cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                            [((CommentCell *)cell).likeButton addTarget:self action:@selector(commentLike:) forControlEvents:UIControlEventTouchUpInside];
                            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentAction:)];
                            [((CommentCell *)cell).replyLabel addGestureRecognizer:tap];
                        }
                        if (_commentArray.count > 0) {
                            [self.noCommentView removeFromSuperview];
                            ((CommentCell *)cell).model = _commentArray[indexPath.row - 1];
                        } else {
                            [cell.contentView addSubview:self.noCommentView];
                        }
                        [cell setNeedsLayout];
                        return cell;
                    }
                }
            }
        }
        case 3:
            switch (indexPath.row) {
                case 0:
                {
                    static NSString *cellID = @"commentsCellID";
                    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                    }
                    if (cell.contentView.subviews.count <= 0) {
                        RecommendedView *recommendedView = [[RecommendedView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30) titleImage:[UIImage imageNamed:@"icon_newcomment"] titleText:@"New Comments" HaveLoading:NO];
                        [cell.contentView addSubview:recommendedView];
                    }
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    return cell;
                }
                default:
                {
                    // 评论cell
                    static NSString *cellID = @"commentID";
                    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                    if (cell == nil) {
                        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                        [((CommentCell *)cell).likeButton addTarget:self action:@selector(commentLike:) forControlEvents:UIControlEventTouchUpInside];
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentAction:)];
                        [((CommentCell *)cell).replyLabel addGestureRecognizer:tap];
                    }
                    if (_commentArray.count > 0) {
                        [self.noCommentView removeFromSuperview];
                        ((CommentCell *)cell).model = _commentArray[indexPath.row - 1];
                    } else {
                        [cell.contentView addSubview:self.noCommentView];
                    }
                    [cell setNeedsLayout];
                    return cell;
                }
            }
        default:
            break;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.backgroundColor = kWhiteBgColor;
    [cell setNeedsLayout];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 1:
        {
            if (indexPath.row > 0) {
                NewsModel *model = _detailModel.recommend_news[indexPath.row - 1];
                NewsDetailViewController *newsDetailVC = [[NewsDetailViewController alloc] init];
                newsDetailVC.model = model;
                newsDetailVC.channelName = _channelName;
                if (model.news_id.length <= 0) {
                    return;
                }
                // 打点-推荐区文章点击-010218
                NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                               _channelName, @"channel",
                                               _model.news_id, @"article",
                                               nil];
                [Flurry logEvent:@"Article_ReArticle_Click" withParameters:articleParams];
//#if DEBUG
//                [iConsole info:[NSString stringWithFormat:@"Article_ReArticle_Click:%@",articleParams],nil];
//#endif
                // 服务器打点-详情页点击相关推荐-020202
                NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
                [eventDic setObject:@"020202" forKey:@"id"];
                [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
                [eventDic setObject:model.news_id forKey:@"news_id"];
                [eventDic setObject:_model.news_id forKey:@"refer"];
                [eventDic setObject:@"1" forKey:@"pos"];
                NSMutableArray *newslist = [NSMutableArray array];
                @autoreleasepool {
                    for (NewsModel *model in _detailModel.recommend_news) {
                        [newslist addObject:model.news_id];
                    }
                }
                [eventDic setObject:newslist forKey:@"newslist"];
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
                
                [self.navigationController pushViewController:newsDetailVC animated:YES];
            }
            break;
        }
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView.superview isKindOfClass:[UIWebView class]] && _webView.isLoading) {
        _webviewOffsetY = scrollView.contentOffset.y;
    }
    float page_pos = (scrollView.contentOffset.y + kScreenHeight - 170) / _webView.height;
    if (page_pos >= 1.0 && !_webView.loading) {
        // 推荐文章展示
        self.isRecommendShow = YES;
    }
//    if (![DEF_PERSISTENT_GET_OBJECT(SS_GuideFavKey) isEqualToNumber:@1]) {
//        if (scrollView.contentOffset.y + kScreenHeight - 64 - 50 >= _tableView.contentSize.height && _tableView.numberOfSections == 3) {
//            self.isShowGuide = YES;
//        }
//    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    [SVProgressHUD show];
    [SVProgressHUD dismiss];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SVProgressHUD.defaultStyle = SVProgressHUDStyleLight;
    });
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    _webView.height = 1;
    NSInteger textSize = 100;
    switch ([DEF_PERSISTENT_GET_OBJECT(SS_FontSize) integerValue]) {
        case 0:
            textSize = 100;
            break;
        case 1:
            textSize = 145;
            break;
        case 2:
            textSize = 125;
            break;
        case 3:
            textSize = 80;
            break;
        default:
            textSize = 100;
            break;
    }
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%ld%%'",(long)textSize]];
    _tableView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64 - 50);
    _webView.scrollView.scrollEnabled = NO;
    CGFloat height = [[_webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue] + 25;
    _webViewHeight = height;
    _webView.height = height;
    _webView.top = 0;
    _likeButton.hidden = NO;
    [self.view addSubview:self.commentsView];
    [_tableView reloadData];
    [_tableView setContentOffset:CGPointMake(_tableView.contentOffset.x, _webviewOffsetY) animated:NO];
//    [_bridge callHandler:@"testJavascriptHandler" data:@{@"123": @"456"} responseCallback:^(id response) {
//        NSLog(@"testJavascriptHandler responded: %@", response);
//    }];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        // 打点-页面进入-011001
        [Flurry logEvent:@"NetFailure_Enter"];
//#if DEBUG
//        [iConsole info:@"NetFailure_Enter",nil];
//#endif
        [SVProgressHUD showErrorWithStatus:@"Please check your network connection"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } else {
        // 打点-页面进入-011001
        [Flurry logEvent:@"NetFailure_Enter"];
//#if DEBUG
//        [iConsole info:@"NetFailure_Enter",nil];
//#endif
        [SVProgressHUD showErrorWithStatus:@"Fetching failed, please try again"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    NSURL *requestURL = [request URL];
    if (([[requestURL scheme] isEqualToString:@"http"] || [[requestURL scheme] isEqualToString:@"https"] || [[requestURL scheme] isEqualToString:@"mailto"])
        && (navigationType == UIWebViewNavigationTypeLinkClicked)) {
        return ![[UIApplication sharedApplication] openURL:requestURL];
    }
    return YES;
}

#pragma mark - setter/getter
// 评论视图
- (UIView *)commentsView
{
    if (_commentsView == nil) {
        _commentsView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 50, kScreenWidth, 50)];
        _commentsView.backgroundColor = [UIColor whiteColor];
        _commentsView.layer.borderWidth = 1;
        _commentsView.layer.borderColor = SSColor(235, 235, 235).CGColor;
        _commentsView.userInteractionEnabled = YES;
        
        CommentTextField *textField = [[CommentTextField alloc] initWithFrame:CGRectMake(11, 8, kScreenWidth - 22 - 19 * 3 - 24 * 3, 34)];
        [_commentsView addSubview:textField];
        UIView *view = [[UIView alloc] initWithFrame:textField.frame];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentAction:)];
        [view addGestureRecognizer:tap];
        [_commentsView addSubview:view];
        
        for (int i = 0; i < 3; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(textField.right + 10 + 43 * i, 0, 42, 50);
            button.tag = 300 + i;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            switch (i) {
                case 0:
                {
                    [button setImage:[UIImage imageNamed:@"icon_article_comments_default"] forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:@"icon_article_comments_select"] forState:UIControlStateHighlighted];
                    break;
                }
                case 1:
                    [button setImage:[UIImage imageNamed:@"icon_article_collect_default"] forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:@"icon_article_collect_select"] forState:UIControlStateSelected];
                    [button setImage:[UIImage imageNamed:@"icon_article_collect_select"] forState:UIControlStateHighlighted];
                    if (![_detailModel.collect_id isEqualToString:@"0"]) {
                        button.selected = YES;
                        _collectID = _detailModel.collect_id;
                    } else {
                        if ([[CoreDataManager sharedInstance] searchLocalFavoriteModelWithNewsID:_model.news_id]) {
                            button.selected = YES;
                        }
                    }
                    break;
                case 2:
                    [button setImage:[UIImage imageNamed:@"icon_article_share_gray"] forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:@"icon_article_share_slect"] forState:UIControlStateHighlighted];
                    break;
                default:
                    break;
            }
            [_commentsView addSubview:button];
            
            if (i == 0) {
                _commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
                _commentsLabel.center = CGPointMake(button.right - 10, button.top + 16);
                _commentsLabel.backgroundColor = SSColor(255, 0, 0);
                _commentsLabel.layer.cornerRadius = 5.0f;
                _commentsLabel.layer.masksToBounds = YES;
                _commentsLabel.textAlignment = NSTextAlignmentCenter;
                _commentsLabel.font = [UIFont systemFontOfSize:10];
                _commentsLabel.textColor = [UIColor whiteColor];
                _commentsLabel.hidden = YES;
                [_commentsView addSubview:_commentsLabel];
                if (_detailModel.commentCount.integerValue > 0) {
                    _commentsLabel.hidden = NO;
                    if (_detailModel.commentCount.integerValue < 1000) {
                        _commentsLabel.text = _detailModel.commentCount.stringValue;
                    } else {
                        _commentsLabel.text = @"999+";
                    }
                    CGSize commentSize = [_detailModel.commentCount.stringValue calculateSize:CGSizeMake(40, 10) font:_commentsLabel.font];
                    _commentsLabel.width = MAX(commentSize.width + 5, 10);
                }
            }
        }
    }
    return _commentsView;
}

// 点赞按钮
- (UIButton *)likeButton
{
    if (_likeButton == nil) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeButton.frame = CGRectMake((kScreenWidth - 105 - 10 - 50) * .5, 0, 105, 34);
        _likeButton.imageView.backgroundColor = kWhiteBgColor;
        _likeButton.titleLabel.backgroundColor = kWhiteBgColor;
        _likeButton.layer.cornerRadius = 17;
        _likeButton.layer.masksToBounds = YES;
        _likeButton.layer.borderWidth = 0.5;
        _likeButton.layer.borderColor = SSColor_RGB(204).CGColor;
        _likeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        _likeButton.hidden = YES;
        [_likeButton setAdjustsImageWhenHighlighted:NO];
        [_likeButton setTitleColor:SSColor(102, 102, 102) forState:UIControlStateNormal];
        [_likeButton setTitleColor:kOrangeColor forState:UIControlStateSelected];
        [_likeButton setBackgroundColor:kWhiteBgColor forState:UIControlStateNormal];
        [_likeButton setImage:[UIImage imageNamed:@"icon_article_like_default"] forState:UIControlStateNormal];
        [_likeButton setImage:[UIImage imageNamed:@"icon_article_like_select"] forState:UIControlStateSelected];
        [_likeButton addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if ([appDelegate.likedDic[_model.news_id] isEqual:@1]) {
            _likeButton.selected = YES;
        }
    }
    if (_detailModel.likedCount.integerValue > 0) {
        _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        NSString *buttonTitle = [NSString stringWithFormat:@"%@",_detailModel.likedCount];
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
        _facebookShare.frame = CGRectMake(_likeButton.right + 10, _likeButton.top, 50, 34);
        _facebookShare.imageView.backgroundColor = kWhiteBgColor;
        _facebookShare.layer.cornerRadius = 17;
        _facebookShare.layer.masksToBounds = YES;
        _facebookShare.layer.borderWidth = 0.5;
        _facebookShare.layer.borderColor = SSColor_RGB(204).CGColor;
        [_facebookShare setAdjustsImageWhenHighlighted:NO];
        [_facebookShare setBackgroundColor:kWhiteBgColor forState:UIControlStateNormal];
        [_facebookShare setImage:[UIImage imageNamed:@"icon_article_facebook_default"] forState:UIControlStateNormal];
        [_facebookShare addTarget:self action:@selector(shareToFacebook:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _facebookShare;
}

- (void)setDetailModel:(NewsDetailModel *)detailModel
{
    if (_detailModel != detailModel) {
        _detailModel = detailModel;
        
        if (_detailModel.comments.count > 0) {
            self.commentArray = [NSMutableArray arrayWithArray:_detailModel.comments];
        } else {
            self.commentArray = [NSMutableArray array];
        }
        if (_detailModel.hotComments.count > 0) {
            self.hotCommentArray = [NSMutableArray arrayWithArray:_detailModel.hotComments];
        } else {
            self.hotCommentArray = [NSMutableArray array];
        }
    }
}

- (void)setCommentArray:(NSMutableArray *)commentArray
{
    _commentArray = commentArray;
    
    if (commentArray.count > 0) {
        __weak NewsDetailViewController *weakSelf = self;
        [self.tableView addLegendFooterWithRefreshingBlock:^{
            [weakSelf tableViewDidTriggerFooterRefresh];
            [weakSelf.tableView.footer beginRefreshing];
        }];
        [self.tableView.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
        [self.tableView.footer setTitle:@"Loading..." forState:MJRefreshFooterStateRefreshing];
        [self.tableView.footer setTitle:@"No more comments" forState:MJRefreshFooterStateNoMoreData];
    } else {
        [self.tableView removeFooter];
    }
}

- (UIView *)noCommentView
{
    if (_noCommentView == nil) {
        _noCommentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 90)];
        _noCommentView.backgroundColor = kWhiteBgColor;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 33) * .5, 20, 33, 31)];
        imageView.backgroundColor = kWhiteBgColor;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageNamed:@"icon_nocomment"];
        [_noCommentView addSubview:imageView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 150) * .5, imageView.bottom + 5, 150, 15)];
        textLabel.backgroundColor = kWhiteBgColor;
        textLabel.textColor = kGrayColor;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = [UIFont systemFontOfSize:13];
        textLabel.text = @"No comments yet";
        [_noCommentView addSubview:textLabel];
    }
    return _noCommentView;
}

- (void)setIsShowGuide:(BOOL)isShowGuide
{
    if (_isShowGuide != isShowGuide) {
        _isShowGuide = isShowGuide;
        
        if (isShowGuide) {
            [[UIApplication sharedApplication].keyWindow addSubview:[GuideFavoritesView sharedInstance]];
        }
    }
}

- (void)setIsRecommendShow:(BOOL)isRecommendShow
{
    if (_isRecommendShow != isRecommendShow) {
        _isRecommendShow = isRecommendShow;
        
        if (isRecommendShow) {
            // 服务器打点-详情页相关推荐展示-020203
            NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
            [eventDic setObject:@"020203" forKey:@"id"];
            [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
            [eventDic setObject:_model.news_id forKey:@"news_id"];
            NSMutableArray *newslist = [NSMutableArray array];
            @autoreleasepool {
                for (NewsModel *model in _detailModel.recommend_news) {
                    [newslist addObject:model.news_id];
                }
            }
            [eventDic setObject:newslist forKey:@"newslist"];
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
        }
    }
}

- (UIView *)tagView
{
    if (!_tagView) {
        _tagView = [[UIView alloc] init];
        CGFloat keyword_Y = 2;
        CGFloat keyword_X = 11;
        for (int i = 0; i < self.detailModel.tags.count; i++) {
            NSString *tagString = self.detailModel.tags[i];
            CGSize buttonSize = [tagString calculateSize:CGSizeMake(kScreenWidth - 22 - 22, 14) font:[UIFont systemFontOfSize:14]];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            if (kScreenWidth - 11 - keyword_X - 10 < buttonSize.width + 22) {
                // 放在下一行
                keyword_X = 11;
                keyword_Y += (26 + 12);
            }
            button.frame = CGRectMake(keyword_X, keyword_Y, buttonSize.width + 22, 26);
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitle:tagString forState:UIControlStateNormal];
            [button setTitleColor:SSColor_RGB(102) forState:UIControlStateNormal];
            [button setTitleColor:kOrangeColor forState:UIControlStateHighlighted];
            [button setBackgroundColor:SSColor_RGB(240) forState:UIControlStateNormal];
            button.layer.borderColor = SSColor_RGB(223).CGColor;
            button.layer.borderWidth = 0.5;
            button.layer.cornerRadius = 4;
            [button addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
            [_tagView addSubview:button];
            if (kScreenWidth - 11 - keyword_X - 10 >= buttonSize.width + 22) {
                // 放在本行
                keyword_X += (buttonSize.width + 22 + 10);
            }
            if (i == self.detailModel.tags.count - 1) {
                _tagView.frame = CGRectMake(0, 2, kScreenWidth, button.bottom);
            }
        }
    }
    return _tagView;
}

#pragma mark - Notification
/**
 *  点击收藏/评论后登录成功
 */
- (void)loginSuccess
{
    // 评论
    _commentTextView = [[CommentTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _commentTextView.news_id = _model.news_id;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)];
    [_commentTextView.shadowView addGestureRecognizer:tap];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:_commentTextView];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    _commentTextView.textView.delegate = self;
    [_commentTextView.cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [_commentTextView.sendButton addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
}

/**
 *  键盘弹出后执行的操作
 *
 *  @param notif 键盘通知
 */
- (void)keyboardWillShow:(NSNotification *)notif
{
    // 获取到键盘的高度
    float keyboardHeight = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    // 登录界面随键盘上弹
    [UIView animateWithDuration:0.2 animations:^{
        _commentTextView.bgView.bottom = kScreenHeight - keyboardHeight;
    }];
}
- (void)keyboardWillHidden
{
    [UIView animateWithDuration:0.2 animations:^{
        _commentTextView.bgView.bottom = kScreenHeight;
    }];
}

/**
 *  字体改变通知
 */
- (void)fontChange
{
    _webView.height = 1;
    NSInteger textSize = 100;
    switch ([DEF_PERSISTENT_GET_OBJECT(SS_FontSize) integerValue]) {
        case 0:
            textSize = 100;
            break;
        case 1:
            textSize = 145;
            break;
        case 2:
            textSize = 125;
            break;
        case 3:
            textSize = 80;
            break;
        default:
            textSize = 100;
            break;
    }
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%ld%%'",(long)textSize]];
    CGFloat height = [[_webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue] + 25;
//    CGFloat height = _webView.scrollView.contentSize.height;
    _webViewHeight = height;
    _webView.height = height;
    [_tableView reloadData];
}

/**
 *  收藏通知
 */
- (void)touchFavorite
{
    UIButton *button = [_commentsView viewWithTag:301];
    // 点击收藏按钮
    if (button.selected) {
        [self deleteCollectNewsWithButton:button];
    } else {
        [self collectNewsWithButton:button];
    }
}

#pragma mark - 按钮点击事件
/**
 *  点赞按钮点击事件
 *
 *  @param button 点赞按钮
 */
- (void)likeAction:(UIButton *)button
{
    // 打点-点赞-010207
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   _channelName, @"channel",
                                   _model.news_id, @"article",
                                   nil];
    [Flurry logEvent:@"Article_Like_Click" withParameters:articleParams];

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (button.selected) {
        if (button.titleLabel.text.intValue > 1) {
            _detailModel.likedCount = [NSNumber numberWithInteger:_detailModel.likedCount.integerValue - 1];
        } else {
            [button setTitle:@"" forState:UIControlStateNormal];
            _detailModel.likedCount = @0;
        }
        [appDelegate.likedDic setValue:@0 forKey:_model.news_id];
    } else {
        _detailModel.likedCount = [NSNumber numberWithInteger:_detailModel.likedCount.integerValue + 1];
        if (appDelegate.likedDic[_model.news_id] == nil) {
            [self likedNewsWithAppDelegate:appDelegate button:button];
        } else {
            [appDelegate.likedDic setValue:@1 forKey:_model.news_id];
        }
    }
    self.likeButton.selected = !button.selected;
}

/**
 *  评论框点击事件
 */
- (void)commentAction:(UITapGestureRecognizer *)tap
{
    if ([tap.view isKindOfClass:[UILabel class]]) {
        CommentCell *cell = (CommentCell *)tap.view.superview.superview;
        if ([cell isKindOfClass:[CommentCell class]]) {
            _commentID = cell.model.commentID;
            // 打点-点击评论回复按钮-010229
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _model.channel_id, @"channel",
                                           _model.news_id, @"article",
                                           [NetType getNetType], @"network",
                                           nil];
            [Flurry logEvent:@"Article_CommentsReply_Click" withParameters:articleParams];
//#if DEBUG
//            [iConsole info:[NSString stringWithFormat:@"Article_CommentsReply_Click:%@",articleParams],nil];
//#endif
        }
    } else {
        _commentID = nil;
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.model) {
        // 评论
        _commentTextView = [[CommentTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)];
        [_commentTextView.shadowView addGestureRecognizer:tap];
        
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:_commentTextView];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        _commentTextView.textView.delegate = self;
        [_commentTextView.cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [_commentTextView.sendButton addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    } else {
        // 登录后评论
        LoginView *loginView = [[LoginView alloc] init];
        [[UIApplication sharedApplication].keyWindow addSubview:loginView];
    }
}

/**
 *  底部按钮点击事件
 *
 *  @param button 按钮
 */
- (void)buttonAction:(UIButton *)button
{
    switch (button.tag - 300) {
        case 0:
        {
            // 打点-点击评论详情页-010212
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _channelName, @"channel",
                                           _model.news_id, @"article",
                                           nil];
            [Flurry logEvent:@"Article_CommentsPage_Click" withParameters:articleParams];
//#if DEBUG
//            [iConsole info:[NSString stringWithFormat:@"Article_CommentsPage_Click:%@",articleParams],nil];
//#endif
            // 点击评论按钮
            CGRect commentRect = [_tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
            if (_tableView.contentOffset.y < commentRect.origin.y - (kScreenHeight - 64 - 50)) {
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            } else {
                [_tableView setContentOffset:CGPointMake(_tableView.contentOffset.x, commentRect.origin.y - kScreenHeight + 64 + 50) animated:YES];
            }
            break;
        }
        case 1:
        {
            // 打点-点击收藏-010214
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _channelName, @"channel",
                                           _model.news_id, @"article",
                                           nil];
            [Flurry logEvent:@"Article_Favorite_Click" withParameters:articleParams];
//#if DEBUG
//            [iConsole info:[NSString stringWithFormat:@"Article_Favorite_Click:%@",articleParams],nil];
//#endif
            
            // 点击收藏按钮
            if (button.selected) {
                [self deleteCollectNewsWithButton:button];
            } else {
                [self collectNewsWithButton:button];
            }
            break;
        }
        case 2:
        {
            [self shareAction];
            break;
        }
        default:
            break;
    }
}

/**
 *  分享按钮点击事件
 */
- (void)shareAction
{
    // 打点-点击右上方分享-010203
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   _channelName, @"channel",
                                   _model.news_id, @"article",
                                   nil];
    [Flurry logEvent:@"Article_UpShare_Click" withParameters:articleParams];
//#if DEBUG
//    [iConsole info:[NSString stringWithFormat:@"Article_UpShare_Click:%@",articleParams],nil];
//#endif
    __weak typeof(self) weakSelf = self;
    [SSUIShareActionSheetStyle setCancelButtonLabelColor:kGrayColor];
    [SSUIShareActionSheetStyle setItemNameFont:[UIFont systemFontOfSize:13]];
    [SSUIShareActionSheetStyle setItemNameColor:kBlackColor];
    
    // 分享到facebook
    SSUIShareActionSheetCustomItem *facebook = [SSUIShareActionSheetCustomItem itemWithIcon:[UIImage imageNamed:@"icon_share_facebook"] label:@"Facebook" onClick:^{
        // 打点-分享至facebook-010219
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _channelName, @"channel",
                                       _model.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Article_Share_Facebook_Click" withParameters:articleParams];
//#if DEBUG
//        [iConsole info:[NSString stringWithFormat:@"Article_Share_Facebook_Click:%@",articleParams],nil];
//#endif

        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        NSString *shareString = _detailModel.share_url;
        shareString = [shareString stringByReplacingOccurrencesOfString:@"{from}" withString:@"facebook"];
        content.contentURL = [NSURL URLWithString:shareString];
        content.contentTitle = _detailModel.title;
        ImageModel *imageModel = _detailModel.imgs.firstObject;
        content.imageURL = [NSURL URLWithString:imageModel.src];
        [FBSDKShareDialog showFromViewController:weakSelf
                                     withContent:content
                                        delegate:weakSelf];
    }];
    
    // 分享到twitter
    SSUIShareActionSheetCustomItem *twitter = [SSUIShareActionSheetCustomItem itemWithIcon:[UIImage imageNamed:@"icon_share_twitter"] label:@"Twitter" onClick:^{
        // 打点-分享至Twitter-010220
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _channelName, @"channel",
                                       _model.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Article_Share_Twitter_Click" withParameters:articleParams];
//#if DEBUG
//        [iConsole info:[NSString stringWithFormat:@"Article_Share_Twitter_Click:%@",articleParams],nil];
//#endif
        NSString *shareString = _detailModel.share_url;
        shareString = [shareString stringByReplacingOccurrencesOfString:@"{from}" withString:@"twitter"];
        TWTRComposer *composer = [[TWTRComposer alloc] init];
        [composer setText:_detailModel.title];
        [composer setURL:[NSURL URLWithString:shareString]];
        @try {
            [composer showFromViewController:weakSelf completion:^(TWTRComposerResult result) {
                if (result == TWTRComposerResultCancelled) {
                    // 取消分享
                    SSLog(@"Tweet composition cancelled");
                } else {
                    // 分享成功
                    SSLog(@"Sending Tweet!");
                }
            }];
        }
        @catch (NSException *exception) {
            SSLog(@"%s\n%@", __FUNCTION__, exception);
        }
    }];

    // 分享到google+
    SSUIShareActionSheetCustomItem *googleplus = [SSUIShareActionSheetCustomItem itemWithIcon:[UIImage imageNamed:@"icon_share_google"] label:@"Google+" onClick:^{
        // 打点-分享至google+-010221
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _channelName, @"channel",
                                       _model.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Article_Share_Google+_Click" withParameters:articleParams];
//#if DEBUG
//        [iConsole info:[NSString stringWithFormat:@"Article_Share_Google+_Click:%@",articleParams],nil];
//#endif
        NSString *shareString = _detailModel.share_url;
        shareString = [shareString stringByReplacingOccurrencesOfString:@"{from}" withString:@"googleplus"];
        NSURLComponents* urlComponents = [[NSURLComponents alloc]
                                          initWithString:@"https://plus.google.com/share"];
        urlComponents.queryItems = @[[[NSURLQueryItem alloc]
                                      initWithName:@"url"
                                      value:[[NSURL URLWithString:shareString] absoluteString]]];
        NSURL* url = [urlComponents URL];
        if ([SFSafariViewController class]) {
            // Open the URL in SFSafariViewController (iOS 9+)
            SFSafariViewController* controller = [[SFSafariViewController alloc]
                                                  initWithURL:url];
            //            controller.delegate = self;
            [weakSelf presentViewController:controller animated:YES completion:nil];
        } else {
            // Open the URL in the device's browser
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    
    [ShareSDK showShareActionSheet:self.view
                             items:@[facebook, twitter, googleplus]
                       shareParams:nil
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end)
    {
        switch (state)
        {
            case SSDKResponseStateCancel:
            {
                SSLog(@"取消分享");
                break;
            }
            default:
                break;
        }
    }];
}

/**
 分享到Facebook
 
 param button
 */
- (void)shareToFacebook:(UIButton *)button
{
    __weak typeof(self) weakSelf = self;
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    NSString *shareString = _model.share_url;
    shareString = [shareString stringByReplacingOccurrencesOfString:@"{from}" withString:@"facebook"];
    content.contentURL = [NSURL URLWithString:shareString];
    content.contentTitle = _model.title;
    ImageModel *imageModel = _model.imgs.firstObject;
    content.imageURL = [NSURL URLWithString:imageModel.src];
    [FBSDKShareDialog showFromViewController:weakSelf
                                 withContent:content
                                    delegate:weakSelf];
}

/**
 *  字体按钮点击事件
 */
- (void)moreAction
{
    // 打点-点击文字调节-010223
    [Flurry logEvent:@"Article_FontSize_Set"];
    UIAlertController *sheetAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *extraLarge = [UIAlertAction actionWithTitle:@"Extra Large" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 打点-选择字体大小-010224
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"Extra Large", @"text_size",
                                       nil];
        [Flurry logEvent:@"Article_FontSize_Set_Click" withParameters:articleParams];
        DEF_PERSISTENT_SET_OBJECT(SS_FontSize, @1);
//        [_tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_FontSize_Change object:nil];
    }];
    UIAlertAction *large = [UIAlertAction actionWithTitle:@"Large" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 打点-选择字体大小-010224
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"Large", @"text_size",
                                       nil];
        [Flurry logEvent:@"Article_FontSize_Set_Click" withParameters:articleParams];
        DEF_PERSISTENT_SET_OBJECT(SS_FontSize, @2);
//        [_tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_FontSize_Change object:nil];
    }];
    UIAlertAction *normal = [UIAlertAction actionWithTitle:@"Normal" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 打点-选择字体大小-010224
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"Normal", @"text_size",
                                       nil];
        [Flurry logEvent:@"Article_FontSize_Set_Click" withParameters:articleParams];
        DEF_PERSISTENT_SET_OBJECT(SS_FontSize, @0);
//        [_tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_FontSize_Change object:nil];
    }];
    UIAlertAction *small = [UIAlertAction actionWithTitle:@"Small" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 打点-选择字体大小-010224
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"Small", @"text_size",
                                       nil];
        [Flurry logEvent:@"Article_FontSize_Set_Click" withParameters:articleParams];
        DEF_PERSISTENT_SET_OBJECT(SS_FontSize, @3);
//        [_tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_FontSize_Change object:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [sheetAlert addAction:extraLarge];
    [sheetAlert addAction:large];
    [sheetAlert addAction:normal];
    [sheetAlert addAction:small];
    [sheetAlert addAction:cancel];
    [self presentViewController:sheetAlert animated:YES completion:nil];
}

/**
 *  取消按钮点击事件
 */
- (void)cancelAction
{
    [_commentTextView.textView resignFirstResponder];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        _commentTextView.shadowView.alpha = 0;
        _commentTextView.bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [_commentTextView removeFromSuperview];
        _commentTextView = nil;
    }];
}

/**
 *  发送评论按钮点击事件
 */
- (void)sendAction
{
    // 打点-发送评论-010209
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   _channelName, @"channel",
                                   _model.news_id, @"article",
                                   nil];
    [Flurry logEvent:@"Article_Comments_Send" withParameters:articleParams];
    [self postComment];
}

/**
 *  重写返回按钮点击事件
 *
 *  @param button 返回按钮
 */
- (void)backAction:(UIButton *)button
{
    // 取消网络请求
    [_task cancel];
    [SVProgressHUD dismiss];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SVProgressHUD.defaultStyle = SVProgressHUDStyleLight;
    });
    // 打点-点击返回-010202
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   _channelName, @"channel",
                                   _model.news_id, @"article",
                                   nil];
    [Flurry logEvent:@"Article_BackButton_Click" withParameters:articleParams];
    [super backAction:button];
}


/**
 关键词搜索点击事件

 @param button 关键词按钮
 */
- (void)searchAction:(UIButton *)button
{
    SearchViewController *searchVC = [[SearchViewController alloc] init];
    searchVC.keyword = button.titleLabel.text;
    searchVC.isTagEnter = YES;
    [self.navigationController pushViewController:searchVC animated:YES];
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

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (_commentTextView.textView.text.length > 0) {
        _commentTextView.placeholderLabel.hidden = YES;
        _commentTextView.isInput = YES;
    } else {
        _commentTextView.placeholderLabel.hidden = NO;
        _commentTextView.isInput = NO;
    }
}

#pragma mark - FBSDKSharingDelegate
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    SSLog(@"分享成功");
}
- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    SSLog(@"分享失败");
}
- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    SSLog(@"取消分享");
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
