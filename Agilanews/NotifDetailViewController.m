//
//  NotifDetailViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/11/15.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "NotifDetailViewController.h"
#import "ManyPicCell.h"
#import "SinglePicCell.h"
#import "NoPicCell.h"
#import "BigPicCell.h"
#import "OnlyVideoCell.h"
#import "CommentCell.h"
#import "ImageModel.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "NewsDetailViewController.h"
#import "VideoDetailViewController.h"
#import "PushTransitionAnimate.h"

#define titleFont_Normal        [UIFont systemFontOfSize:16]
#define titleFont_ExtraLarge    [UIFont systemFontOfSize:20]
#define titleFont_Large         [UIFont systemFontOfSize:18]
#define titleFont_Small         [UIFont systemFontOfSize:14]
#define imageHeight 162 * kScreenWidth / 320.0
#define videoHeight 180 * kScreenWidth / 320.0

@interface NotifDetailViewController ()

@end

@implementation NotifDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Comments";
    self.isBackButton = YES;
    self.view.backgroundColor = kWhiteBgColor;

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = kWhiteBgColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.sectionHeaderHeight = 0;
    _tableView.sectionFooterHeight = 0;
    _tableView.separatorColor = SSColor(235, 235, 235);
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    
    // 请求数据
    [self requestData];
    
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginSuccess:)
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
                                             selector:@selector(recoverVideo:)
                                                 name:KNOTIFICATION_RecoverVideo
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (IOS_VERSION_CODE <= 8) {
        __weak typeof(self.navigationController.delegate) weakDelegate = self.navigationController.delegate;
        if (weakDelegate != self) {
            weakDelegate = self;
        }
    } else {
        if (self.navigationController.delegate != self) {
            self.navigationController.delegate = self;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        [self.navigationController.navigationBar setBarTintColor:kOrangeColor];
        UIView *barBgView = self.navigationController.navigationBar.subviews.firstObject;
        for (UIView *subview in barBgView.subviews) {
            if([subview isKindOfClass:[UIVisualEffectView class]]) {
                subview.backgroundColor = kOrangeColor;
                [subview removeAllSubviews];
            }
        }
    } else {
        [self.navigationController.navigationBar lt_setBackgroundColor:kOrangeColor];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

#pragma mark - Network
- (void)requestData
{
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_notify_id forKey:@"id"];
    [[SSHttpRequest sharedInstance] get:kHomeUrl_NotifDetail params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        [SVProgressHUD dismiss];
        weakSelf.model = [NotifDetailModel mj_objectWithKeyValues:responseObj];
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    } isShowHUD:NO];
}

/**
 评论点赞网络请求
 
 @param button
 */
- (void)commentLike:(UIButton *)button
{
    //    __weak typeof(self) weakSelf = self;
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

/**
 *  发布评论网络请求
 */
- (void)postComment
{
    _commentTextView.sendButton.enabled = NO;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_model.related_news.news_id forKey:@"news_id"];
    [params setObject:_commentTextView.textView.text forKey:@"comment_detail"];
    if (_commentID) {
        [params setObject:_commentID forKey:@"ref_id"];
    }
    [[SSHttpRequest sharedInstance] post:kHomeUrl_Comment params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        _commentTextView.sendButton.enabled = YES;
        CommentModel *model = [CommentModel mj_objectWithKeyValues:responseObj[@"comment"]];
        for (CommentModel *commentModel in _dataList) {
            if (_commentID && [commentModel.commentID isEqualToNumber:_commentID]) {
                model.reply = commentModel;
                _commentID = nil;
                break;
            }
        }
        if (model) {
            [weakSelf.dataList insertObject:model atIndex:0];
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
                                       @"Notification", @"channel",
                                       _model.related_news.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Article_Comments_Send_Y" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Article_Comments_Send_Y:%@",articleParams],nil];
#endif
    } failure:^(NSError *error) {
        _commentTextView.sendButton.enabled = YES;
        // 打点-评论失败-010211
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       @"Notification", @"channel",
                                       _model.related_news.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Article_Comments_Send_N" withParameters:articleParams];
#if DEBUG
        [iConsole info:[NSString stringWithFormat:@"Article_Comments_Send_N:%@",articleParams],nil];
#endif
    } isShowHUD:YES];
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
        }
    } else {
        _commentID = nil;
    }
    // 评论
    _commentTextView = [[CommentTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    UITapGestureRecognizer *commentTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)];
    [_commentTextView.shadowView addGestureRecognizer:commentTap];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:_commentTextView];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    _commentTextView.textView.delegate = self;
    [_commentTextView.cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [_commentTextView.sendButton addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - ButtonAction
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
                                   @"Notification", @"channel",
                                   _model.related_news.news_id, @"article",
                                   nil];
    [Flurry logEvent:@"Article_Comments_Send" withParameters:articleParams];
#if DEBUG
    [iConsole info:[NSString stringWithFormat:@"Article_Comments_Send:%@",articleParams],nil];
#endif
    [self postComment];
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_dataList.count > 0) {
        return _dataList.count + 1;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        NewsModel *model = _model.related_news;
        UIFont *titleFont = nil;
        switch ([DEF_PERSISTENT_GET_OBJECT(SS_FontSize) integerValue])
        {
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
                CGSize titleLabelSize = [model.title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:titleFont];
                return 11 + titleLabelSize.height + 10 + 70 + 10 + 11 + 11;
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
                CGSize titleLabelSize = [model.title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:titleFont];
                return 12 + titleLabelSize.height + imageHeight + 20 + 11 + 11;
            }
            case NEWS_HaveVideo:
            {
                return 12 + 68 + 12;
            }
            case NEWS_OnlyVideo:
            {
                return videoHeight + 42;
            }
            default:
                return 50;
        }
    } else {
        CommentModel *model = _dataList[indexPath.row - 1];
        CGSize commentLabelSize = [model.comment calculateSize:CGSizeMake(kScreenWidth - 55 - 11, 1000) font:[UIFont systemFontOfSize:15]];
        CommentModel *commentModel = model.reply;
        if (commentModel.comment) {
            NSString *replyString = [NSString stringWithFormat:@"@%@: %@",commentModel.user_name,commentModel.comment];
            CGSize replyLabelSize = [replyString calculateSize:CGSizeMake(kScreenWidth - 11 - 7 - 55, 1000) font:[UIFont systemFontOfSize:13]];
            return 10 + 5 + 16 + 12 + commentLabelSize.height + 5 + 12 + 9 + replyLabelSize.height + 10;
        }
        return 10 + 5 + 16 + 12 + commentLabelSize.height + 5 + 12 + 9;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        // 相关新闻
        NewsModel *model = _model.related_news;
        switch ([model.tpl integerValue])
        {
            case NEWS_ManyPic:
            {
                // 多图cell
                static NSString *cellID = @"ManyPicCellID";
                ManyPicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[ManyPicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
                }
                cell.model = model;
                [cell setNeedsLayout];
                return cell;
            }
            case NEWS_SinglePic:
            {
                // 单图cell
                static NSString *cellID = @"SinglePicCellID";
                SinglePicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[SinglePicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
                }
                cell.model = model;
                cell.isHaveVideo = NO;
                [cell setNeedsLayout];
                return cell;
            }
            case NEWS_NoPic:
            {
                // 无图cell
                static NSString *cellID = @"NoPicCellID";
                NoPicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[NoPicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
                }
                cell.model = model;
                [cell setNeedsLayout];
                return cell;
            }
            case NEWS_BigPic:
            {
                // 大图cell
                static NSString *cellID = @"BigPicCellID";
                BigPicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[BigPicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
                }
                cell.model = model;
                [cell setNeedsLayout];
                return cell;
            }
            case NEWS_HaveVideo:
            {
                // 单图cell
                static NSString *cellID = @"SinglePicCellID";
                SinglePicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[SinglePicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
                }
                cell.model = model;
                cell.isHaveVideo = YES;
                [cell setNeedsLayout];
                return cell;
            }
            case NEWS_OnlyVideo:
            {
                // 视频cell
                static NSString *cellID = @"OnlyVideoCell";
                OnlyVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[OnlyVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID bgColor:[UIColor whiteColor]];
                    [cell.shareButton addTarget:self action:@selector(shareToFacebook:) forControlEvents:UIControlEventTouchUpInside];
                }
                cell.model = model;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell setNeedsLayout];
                return cell;
            }
            default:
            {
                static NSString *cellID = @"newsListCellID";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                }
                [cell setNeedsLayout];
                return cell;
            }
        }
    } else {
        // 评论
        static NSString *cellID = @"commentID";
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            [cell.likeButton addTarget:self action:@selector(commentLike:) forControlEvents:UIControlEventTouchUpInside];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentAction:)];
            [cell.replyLabel addGestureRecognizer:tap];
        }
        cell.model = _dataList[indexPath.row - 1];
        [cell setNeedsLayout];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        NewsModel *model = _model.related_news;
        if (model.tpl.integerValue == NEWS_OnlyVideo) {
            VideoDetailViewController *videoDetailVC = [[VideoDetailViewController alloc] init];
            videoDetailVC.model = model;
            videoDetailVC.channelName = @"Hot";
            OnlyVideoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            videoDetailVC.playerView = cell.playerView;
            videoDetailVC.indexPath = indexPath;
            videoDetailVC.fromCell = cell;
            cell.isPlay = YES;
            cell.titleImageView.hidden = YES;
            [self.navigationController pushViewController:videoDetailVC animated:YES];
        } else {
            NewsDetailViewController *newsDetailVC = [[NewsDetailViewController alloc] init];
            newsDetailVC.model = model;
            newsDetailVC.channelName = @"Hot";
            [self.navigationController pushViewController:newsDetailVC animated:YES];
        }
    }
}

#pragma mark - setter/getter
- (void)setModel:(NotifDetailModel *)model
{
    if (_model != model) {
        _model = model;
        
        _dataList = [NSMutableArray arrayWithArray:model.comments];
    }
}

/**
 分享到Facebook
 
 @param button
 */
- (void)shareToFacebook:(UIButton *)button
{
    id cell = button.superview;
    do {
        if ([cell isKindOfClass:[UITableViewCell class]]) {
            break;
        }
        cell = ((UIView *)cell).superview;
    } while (cell != nil);
    NewsModel *newsModel = ((OnlyVideoCell *)cell).model;
    
    __weak typeof(self) weakSelf = self;
//    // 打点-分享至facebook-010219
//    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
//                                   _model.name, @"channel",
//                                   newsModel.news_id, @"article",
//                                   nil];
//    [Flurry logEvent:@"Home_List_Share_FacebookClick" withParameters:articleParams];
//#if DEBUG
//    [iConsole info:[NSString stringWithFormat:@"Home_List_Share_FacebookClick:%@",articleParams],nil];
//#endif
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.model) {
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        NSString *shareString = newsModel.share_url;
        shareString = [shareString stringByReplacingOccurrencesOfString:@"{from}" withString:@"facebook"];
        content.contentURL = [NSURL URLWithString:shareString];
        content.contentTitle = newsModel.title;
        ImageModel *imageModel = newsModel.imgs.firstObject;
        content.imageURL = [NSURL URLWithString:imageModel.src];
        [FBSDKShareDialog showFromViewController:weakSelf
                                     withContent:content
                                        delegate:weakSelf];
    } else {
        // 登录后分享
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.isShareFacebook = YES;
        loginVC.shareModel = newsModel;
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [weakSelf.navigationController presentViewController:navCtrl animated:YES completion:nil];
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

#pragma mark - Notification
/**
 *  点击收藏/评论后登录成功
 */
- (void)loginSuccess:(NSNotification *)notif
{
    if ([notif.object[@"isShareFacebook"] isEqualToNumber:@1]) {
        // 分享Facebook
        NewsModel *model = notif.object[@"shareModel"];
        if (model) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
                NSString *shareString = model.share_url;
                shareString = [shareString stringByReplacingOccurrencesOfString:@"{from}" withString:@"facebook"];
                content.contentURL = [NSURL URLWithString:shareString];
                content.contentTitle = model.title;
                ImageModel *imageModel = model.imgs.firstObject;
                content.imageURL = [NSURL URLWithString:imageModel.src];
                [FBSDKShareDialog showFromViewController:self
                                             withContent:content
                                                delegate:self];
            });
        }
    }
}

/**
 视频从详情回位
 */
- (void)recoverVideo:(NSNotification *)notif
{
    NSDictionary *dic = notif.object;
    YTPlayerView *playerView = dic[@"playerView"];
    NSIndexPath *indexPath = dic[@"index"];
    NSNumber *isPlay = dic[@"stop"];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[OnlyVideoCell class]]) {
        OnlyVideoCell *videoCell = (OnlyVideoCell *)cell;
        [videoCell setNeedsLayout];
        if (videoCell.isMove) {
            NSNumber *duration = dic[@"duration"];
            videoCell.playTimeCount += duration.longLongValue;
            [videoCell.contentView addSubview:playerView];
            [videoCell.contentView bringSubviewToFront:videoCell.titleImageView];
            videoCell.isMove = NO;
            if ([isPlay isEqualToNumber:@1]) {
                videoCell.isPlay = NO;
            }
        }
    }
}

#pragma mark - UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    // && [_model.channelID isEqualToNumber:@30001]
    if(operation == UINavigationControllerOperationPush) {
        PushTransitionAnimate *pushTransition = [[PushTransitionAnimate alloc] init];
        return pushTransition;
    } else {
        return nil;
    }
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
