//
//  GifDetailViewController.m
//  Agilanews
//
//  Created by 张思思 on 16/12/28.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "GifDetailViewController.h"
#import "CommentTextField.h"
#import "CommentModel.h"
#import "CommentCell.h"
#import "AppDelegate.h"
#import "LoginView.h"
#import "ImageModel.h"
#import "GifDetailCell.h"
#import "AppDelegate.h"

@import SafariServices;
@interface GifDetailViewController ()

@end

@implementation GifDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.isBackButton = YES;
    _commentArray = [NSMutableArray array];

//    // 添加导航栏右侧按钮
//    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    shareBtn.backgroundColor = kOrangeColor;
//    shareBtn.frame = CGRectMake(0, 0, 40, 40);
//    shareBtn.imageView.backgroundColor = kOrangeColor;
//    [shareBtn setImage:[UIImage imageNamed:@"icon_article_share_default"] forState:UIControlStateNormal];
//    [shareBtn addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc]initWithCustomView:shareBtn];
//    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    negativeSpacer.width = -10;
//    self.navigationItem.rightBarButtonItems = @[negativeSpacer, shareItem];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64 - 50) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = kWhiteBgColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.sectionHeaderHeight = 0;
    _tableView.sectionFooterHeight = 0;
    _tableView.separatorColor = SSColor(235, 235, 235);
    [self.view addSubview:_tableView];
    [self.view addSubview:self.commentsView];
    
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
    
    _tasks = [NSMutableArray array];
    // 评论网络请求
    [self requsetCommentsListWithNewsID:_model.news_id];
    // 详情网络请求
    [self requsetDetailWithNewsID:_model.news_id];
    _collectID = _model.collect_id;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SVProgressHUD.defaultStyle = SVProgressHUDStyleLight;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (cell && [cell isKindOfClass:[GifDetailCell class]]) {
        GifDetailCell *gifCell = cell;
        AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
        if (manager.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
            [gifCell tapAction];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (NSURLSessionDataTask *task in _tasks) {
        [task cancel];
    }
    [_tasks removeAllObjects];
    
    if (_cell) {
        [_cell setNeedsLayout];
    }
    
//    // 服务器打点-详情页返回-020201
//    NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
//    [eventDic setObject:@"020201" forKey:@"id"];
//    [eventDic setObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"time"];
//    [eventDic setObject:_model.news_id forKey:@"news_id"];
//    float pagePos = (_tableView.contentOffset.y + kScreenHeight - 64 - 50) / _tableView.contentSize.height;
//    [eventDic setObject:[NSString stringWithFormat:@"%.1f",MAX(pagePos, 1)] forKey:@"page_pos"];
//    float duration = ([[NSDate date] timeIntervalSince1970] * 1000 - _enterTime * 1000) / 1000.0;
//    [eventDic setObject:[NSString stringWithFormat:@"%.1f",duration] forKey:@"duration"];
//    [eventDic setObject:[NetType getNetType] forKey:@"net"];
//    if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
//        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
//        [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
//    } else {
//        [eventDic setObject:@"" forKey:@"lng"];
//        [eventDic setObject:@"" forKey:@"lat"];
//    }
//    NSString *abflag = DEF_PERSISTENT_GET_OBJECT(@"abflag");
//    if (abflag && abflag.length > 0) {
//        [eventDic setObject:abflag forKey:@"abflag"];
//    }
//    [eventDic setObject:DEF_PERSISTENT_GET_OBJECT(@"UUID") forKey:@"session"];
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate.eventArray addObject:eventDic];
}


#pragma mark - Network
/**
 // 评论网络请求
 */
- (void)requsetCommentsListWithNewsID:(NSString *)newsID
{
    [_recommentsView startAnimation];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:newsID forKey:@"news_id"];
    [params setObject:@"later" forKey:@"prefer"];
    [params setObject:@3 forKey:@"pn"];
    NSURLSessionDataTask *task = [[SSHttpRequest sharedInstance] get:kHomeUrl_VideoComment params:params contentType:UrlencodedType serverType:NetServer_V3 success:^(id responseObj) {
        [_recommentsView stopAnimation];
        NSArray *newArray = responseObj[@"new"];
        NSMutableArray *newModels = [NSMutableArray array];
        @autoreleasepool {
            for (NSDictionary *dic in newArray) {
                CommentModel *model = [CommentModel mj_objectWithKeyValues:dic];
                [newModels addObject:model];
            }
        }
        weakSelf.commentArray = [NSMutableArray arrayWithArray:newModels];
        NSArray *hotArray = responseObj[@"hot"];
        NSMutableArray *hotModels = [NSMutableArray array];
        @autoreleasepool {
            for (NSDictionary *dic in hotArray) {
                CommentModel *model = [CommentModel mj_objectWithKeyValues:dic];
                [hotModels addObject:model];
            }
        }
        weakSelf.hotCommentArray = [NSMutableArray arrayWithArray:hotModels];
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        [_recommentsView stopAnimation];
        _recommentsView.retryLabel.hidden = NO;
    } isShowHUD:NO];
    [_tasks addObject:task];
}

/**
 *  上拉加载评论
 */
- (void)tableViewDidTriggerFooterRefresh
{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_model.news_id forKey:@"news_id"];
    [params setObject:@"later" forKey:@"prefer"];
    CommentModel *commentModel = _commentArray.lastObject;
    if (!commentModel.commentID) {
        return;
    }
    [params setObject:commentModel.commentID forKey:@"last_id"];
    NSURLSessionDataTask *task = [[SSHttpRequest sharedInstance] get:kHomeUrl_VideoComment params:params contentType:UrlencodedType serverType:NetServer_V3 success:^(id responseObj) {
        [_tableView.footer endRefreshing];
        NSArray *array = responseObj[@"new"];
        if (array.count > 0) {
            NSMutableArray *models = [NSMutableArray array];
            @autoreleasepool {
                for (NSDictionary *dic in array) {
                    CommentModel *model = [CommentModel mj_objectWithKeyValues:dic];
                    [models addObject:model];
                }
            }
            [self.commentArray addObjectsFromArray:models];
            [weakSelf.tableView reloadData];
        } else {
            _tableView.footer.state = MJRefreshFooterStateNoMoreData;
        }
    } failure:^(NSError *error) {
        [_tableView.footer endRefreshing];
    } isShowHUD:NO];
    [_tasks addObject:task];
}

/**
 新闻详情网络请求
 
 @param newsID
 */
- (void)requsetDetailWithNewsID:(NSString *)newsID
{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:newsID forKey:@"news_id"];
    NSURLSessionDataTask *task = [[SSHttpRequest sharedInstance] get:kHomeUrl_NewsDetail params:params contentType:UrlencodedType serverType:NetServer_V3 success:^(id responseObj) {
        weakSelf.detailModel = [NewsDetailModel mj_objectWithKeyValues:responseObj];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (appDelegate.model) {
            if (![_detailModel.collect_id isEqualToString:@"0"]) {
                UIButton *button = [weakSelf.commentsView viewWithTag:301];
                button.selected = YES;
                _collectID = _detailModel.collect_id;
            } else {
                UIButton *button = [weakSelf.commentsView viewWithTag:301];
                button.selected = NO;
                _collectID = _detailModel.collect_id;
            }
        }
        if (_isNoModel) {
            weakSelf.model = [NewsModel mj_objectWithKeyValues:responseObj];
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        }
    } failure:nil isShowHUD:NO];
    [_tasks addObject:task];
}

/**
 *  点赞按钮网络请求
 *
 *  @param appDelegate
 *  @param button      点赞按钮
 */
- (void)likedNewsWithAppDelegate:(AppDelegate *)appDelegate button:(UIButton *)button
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_model.news_id forKey:@"news_id"];
    [[SSHttpRequest sharedInstance] post:kHomeUrl_Like params:params contentType:JsonType serverType:NetServer_Home success:^(id responseObj) {
        [appDelegate.likedDic setValue:@1 forKey:_model.news_id];
        _model.likedCount = responseObj[@"liked"];
        [button setTitle:[NSString stringWithFormat:@"%@",responseObj[@"liked"]] forState:UIControlStateNormal];
        button.selected = YES;
    } failure:^(NSError *error) {
        //        [button setTitle:[NSString stringWithFormat:@"%d",button.titleLabel.text.intValue - 1] forState:UIControlStateNormal];
        //        weakSelf.likeButton.selected = NO;
    } isShowHUD:NO];
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
            _model.commentCount = [NSNumber numberWithInteger:_model.commentCount.integerValue + 1];
            if (_model.commentCount.integerValue < 1000) {
                _commentsLabel.text = _model.commentCount.stringValue;
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
    } failure:^(NSError *error) {
        _commentTextView.sendButton.enabled = YES;
        // 打点-评论失败-010211
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       _channelName, @"channel",
                                       _model.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Article_Comments_Send_N" withParameters:articleParams];
    } isShowHUD:YES];
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
                [[CoreDataManager sharedInstance] addAccountFavoriteWithCollectID:weakSelf.collectID DetailModel:_detailModel];
                [SVProgressHUD showSuccessWithStatus:@"Save the news and read it later by entering 'Favorites'"];
                // 打点-收藏成功-010215
                NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                               _channelName, @"channel",
                                               _model.news_id, @"article",
                                               nil];
                [Flurry logEvent:@"Article_Favorite_Click_Y" withParameters:articleParams];
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
        } isShowHUD:YES];
    } else if (_detailModel && _model) {
        // 新闻详情本地缓存
        if (_isNoModel) {
            _model.tpl = @7;
        }
        NSString *time = [NSString stringWithFormat:@"%@",[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]];
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
        } failure:^(NSError *error) {
            
        } isShowHUD:NO];
    } else {
        [[CoreDataManager sharedInstance] removeLocalFavoriteModelWithNewsIDs:[NSArray arrayWithObject:_model.news_id]];
        button.selected = NO;
    }
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
            if (likeNum && likeNum.integerValue > 0) {
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
    if (_hotCommentArray.count > 0){
        return 3;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            if (_hotCommentArray.count > 0){
                return _hotCommentArray.count + 1;
            }
            if (_commentArray.count > 0) {
                return _commentArray.count + 1;
            } else {
                return 2;
            }
        case 2:
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
        {
            CGSize titleLabelSize = [_model.title calculateSize:CGSizeMake(kScreenWidth - 22, 80) font:[UIFont systemFontOfSize:16]];
            ImageModel *model = _model.imgs.firstObject;
            return 11 + titleLabelSize.height + 12 + (int)(model.height.integerValue / 2.0) + 30 + 34 + 25;
        }
        case 1:
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
        case 2:
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
            // 视频详情
            static NSString *cellID = @"GifDetailCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[GifDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                [((GifDetailCell *)cell).likeButton addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
                [((GifDetailCell *)cell).facebookShare addTarget:self action:@selector(shareToFacebook:) forControlEvents:UIControlEventTouchUpInside];
            }
            ((GifDetailCell *)cell).model = _model;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
        case 1:
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
                        if (_commentArray.count > 0) {
                            [self.noCommentView removeFromSuperview];
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
                            _recommentsView = [[RecommendedView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30) titleImage:[UIImage imageNamed:@"icon_newcomment"] titleText:@"New Comments" HaveLoading:YES];
                            [cell.contentView addSubview:_recommentsView];
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
        case 2:
            switch (indexPath.row) {
                case 0:
                {
                    static NSString *cellID = @"commentsCellID";
                    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                    }
                    if (cell.contentView.subviews.count <= 0) {
                        _recommentsView = [[RecommendedView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30) titleImage:[UIImage imageNamed:@"icon_newcomment"] titleText:@"New Comments" HaveLoading:YES];
                        [cell.contentView addSubview:_recommentsView];
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
    static NSString *cellID = @"newsListCellID";
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.backgroundColor = kWhiteBgColor;
    [cell setNeedsLayout];
    return cell;
}

#pragma mark - 按钮点击事件
/**
 *  点赞按钮点击事件
 *
 *  @param button 点赞按钮
 */
- (void)likeAction:(UIButton *)button
{
    // 打点-视频点赞-011602
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   _channelName, @"channel",
                                   _model.news_id, @"article",
                                   nil];
    [Flurry logEvent:@"Video_LikeButton_Click" withParameters:articleParams];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (button.selected) {
        if (button.titleLabel.text.intValue > 1) {
            _model.likedCount = [NSNumber numberWithInteger:_model.likedCount.integerValue - 1];
        } else {
            [button setTitle:@"" forState:UIControlStateNormal];
            _model.likedCount = @0;
        }
        [appDelegate.likedDic setValue:@0 forKey:_model.news_id];
    } else {
        _model.likedCount = [NSNumber numberWithInteger:_model.likedCount.integerValue + 1];
        if (appDelegate.likedDic[_model.news_id] == nil) {
            [self likedNewsWithAppDelegate:appDelegate button:button];
        } else {
            [appDelegate.likedDic setValue:@1 forKey:_model.news_id];
        }
    }
    GifDetailCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.likeButton.selected = !button.selected;
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
    //#if DEBUG
    //    [iConsole info:[NSString stringWithFormat:@"Article_Comments_Send:%@",articleParams],nil];
    //#endif
    [self postComment];
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
            // 打点-视频评论点击-011606
            NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                           _channelName, @"channel",
                                           _model.news_id, @"article",
                                           nil];
            [Flurry logEvent:@"Video_Comment_Click" withParameters:articleParams];
            // 点击评论按钮
            CGRect commentRect = [_tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
            if (_tableView.contentOffset.y < commentRect.origin.y - (kScreenHeight - 0 - 64 - 50)) {
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            } else {
                [_tableView setContentOffset:CGPointMake(_tableView.contentOffset.x, 0) animated:YES];
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
    // 打点-视频分享-011604
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   _channelName, @"channel",
                                   _model.news_id, @"article",
                                   nil];
    [Flurry logEvent:@"Video_share_Click" withParameters:articleParams];
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
        NSString *shareString = _model.share_url;
        shareString = [shareString stringByReplacingOccurrencesOfString:@"{from}" withString:@"facebook"];
        content.contentURL = [NSURL URLWithString:shareString];
        content.contentTitle = _model.title;
        ImageModel *imageModel = _model.imgs.firstObject;
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

        NSString *shareString = _model.share_url;
        shareString = [shareString stringByReplacingOccurrencesOfString:@"{from}" withString:@"twitter"];
        TWTRComposer *composer = [[TWTRComposer alloc] init];
        [composer setText:_model.title];
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
        NSString *shareString = _model.share_url;
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

#pragma mark - Notification
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

#pragma mark - setter/getter
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

- (void)setCommentArray:(NSMutableArray *)commentArray
{
    _commentArray = commentArray;
    
    if (commentArray.count > 0) {
        __weak typeof(self) weakSelf = self;
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
                {
                    [button setImage:[UIImage imageNamed:@"icon_article_collect_default"] forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:@"icon_article_collect_select"] forState:UIControlStateSelected];
                    [button setImage:[UIImage imageNamed:@"icon_article_collect_select"] forState:UIControlStateHighlighted];
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    if (!appDelegate.model && [[CoreDataManager sharedInstance] searchLocalFavoriteModelWithNewsID:_model.news_id]) {
                        button.selected = YES;
                    }
                    break;
                }
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
                if (_model.commentCount.integerValue > 0) {
                    _commentsLabel.hidden = NO;
                    if (_model.commentCount.integerValue < 1000) {
                        _commentsLabel.text = _model.commentCount.stringValue;
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
