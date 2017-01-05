//
//  CommentViewController.m
//  Agilanews
//
//  Created by 张思思 on 17/1/4.
//  Copyright © 2017年 banews. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentModel.h"
#import "CommentCell.h"
#import "AppDelegate.h"
#import "LoginView.h"
#import "CommentTextField.h"
#import "HZPhotoBrowser.h"

@interface CommentViewController ()

@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isBackButton = YES;
    self.title = @"Comments";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 50) style:UITableViewStylePlain];
    _tableView.backgroundColor = kWhiteBgColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.sectionHeaderHeight = 0;
    _tableView.sectionFooterHeight = 0;
    _tableView.separatorColor = SSColor(235, 235, 235);
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    [self.view addSubview:self.commentsView];
    
    // 评论网络请求
    [self requsetCommentsListWithNewsID:_model.news_id];
    
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
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    for (NSURLSessionDataTask *task in _tasks) {
        [task cancel];
    }
    [_tasks removeAllObjects];
}

#pragma mark - Network
/**
 // 评论网络请求
 */
- (void)requsetCommentsListWithNewsID:(NSString *)newsID
{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:newsID forKey:@"news_id"];
    [params setObject:@"later" forKey:@"prefer"];
    [params setObject:@10 forKey:@"pn"];
    NSURLSessionDataTask *task = [[SSHttpRequest sharedInstance] get:kHomeUrl_VideoComment params:params contentType:UrlencodedType serverType:NetServer_V3 success:^(id responseObj) {
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
    [_tasks addObject:task];
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
    [self requsetCommentsListWithNewsID:_model.news_id];
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
    [[SSHttpRequest sharedInstance] post:kHomeUrl_VideoComment params:params contentType:JsonType serverType:NetServer_V3 success:^(id responseObj) {
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
            _model.commentCount = [NSNumber numberWithInteger:_model.commentCount.integerValue + 1];
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
    } failure:^(NSError *error) {
        _commentTextView.sendButton.enabled = YES;
    } isShowHUD:YES];
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
        return 2;
    } else if (_commentArray.count > 0){
        return 1;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if (_hotCommentArray.count > 0){
                return _hotCommentArray.count + 1;
            }
            if (_commentArray.count > 0) {
                return _commentArray.count + 1;
            } else {
                return 0;
            }
        case 1:
            if (_commentArray.count > 0) {
                return _commentArray.count + 1;
            } else {
                return 0;
            }
        default:
            return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 8)];
    view.backgroundColor = SSColor(235, 235, 235);
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
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
        case 1:
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
//                        if (_commentArray.count > 0) {
//                            [self.noCommentView removeFromSuperview];
//                        }
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
                        ((CommentCell *)cell).model = _commentArray[indexPath.row - 1];
//                        if (_commentArray.count > 0) {
//                            [self.noCommentView removeFromSuperview];
//                        } else {
//                            ((CommentCell *)cell).model = nil;
//                            [cell.contentView addSubview:self.noCommentView];
//                        }
                        [cell setNeedsLayout];
                        return cell;
                    }
                }
            }
        }
        case 1:
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
//                    if (_commentArray.count > 0) {
//                        [self.noCommentView removeFromSuperview];
//                        ((CommentCell *)cell).model = _commentArray[indexPath.row - 1];
//                    } else {
//                        ((CommentCell *)cell).model = nil;
//                        [cell.contentView addSubview:self.noCommentView];
//                    }
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
        _noCommentView = [[UIView alloc] initWithFrame:CGRectMake(0, (kScreenHeight - 90) * .5 - 50, kScreenWidth, 90)];
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
        [self.noCommentView removeFromSuperview];
    } else {
        [self.tableView removeFooter];
        [self.view addSubview:self.noCommentView];
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
        
        CommentTextField *textField = [[CommentTextField alloc] initWithFrame:CGRectMake(11, 8, kScreenWidth - 22, 34)];
        [_commentsView addSubview:textField];
        UIView *view = [[UIView alloc] initWithFrame:textField.frame];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentAction:)];
        [view addGestureRecognizer:tap];
        [_commentsView addSubview:view];
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
