//
//  HZPhotoBrowser.m
//  photoBrowser
//
//  Created by huangzhenyu on 15/6/23.
//  Copyright (c) 2015年 eamon. All rights reserved.
//

#import "HZPhotoBrowser.h"
#import "HZPhotoBrowserConfig.h"
#import "HomeViewController.h"
#import "HomeTableViewController.h"
#import "CommentTextField.h"
#import "LoginView.h"
#import "CommentViewController.h"
#import "OnlyPicCell.h"
#import "PicDetailViewController.h"

@interface HZPhotoBrowser() <UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,assign) BOOL hasShowedPhotoBrowser;
@property (nonatomic,strong) UILabel *indexLabel;
@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic,strong) UIButton *saveButton;
@end

@implementation HZPhotoBrowser

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.isBackButton = YES;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        [self.navigationController.navigationBar setBarTintColor:SSColor_RGB(27)];
        UIView *barBgView = self.navigationController.navigationBar.subviews.firstObject;
        for (UIView *subview in barBgView.subviews) {
            if([subview isKindOfClass:[UIVisualEffectView class]]) {
                subview.backgroundColor = SSColor_RGB(27);
                [subview removeAllSubviews];
            }
        }
    } else {
        [self.navigationController.navigationBar lt_setBackgroundColor:SSColor_RGB(27)];
    }
    
    _hasShowedPhotoBrowser = NO;
    self.view.backgroundColor = SSColor_RGB(27);
    [self addScrollView];
    [self addToolbars];
    [self setUpFrames];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
//    longPress.minimumPressDuration = 1;
    [self.view addGestureRecognizer:longPress];
    
    // 底部评论框
    [self.view addSubview:self.commentsView];
    // 详情标签
    [self.view addSubview:self.contentView];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSArray *array = [[NSMutableArray alloc] initWithArray: self.jt_navigationController.jt_viewControllers];
    NSInteger index = -1;
    for (int i = 0; i < self.jt_navigationController.jt_viewControllers.count; i++) {
        UIViewController *vc = array[i];
        if ([vc isKindOfClass:[PicDetailViewController class]]) {
            index = i;
            break;
        }
    }
    if (index >= 0) {
        NSMutableArray *navigationArray = [NSMutableArray arrayWithArray:self.jt_navigationController.viewControllers];
        [navigationArray removeObjectAtIndex:index];
        self.jt_navigationController.viewControllers = navigationArray;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_hasShowedPhotoBrowser) {
        [self showPhotoBrowser];
    } else {
        if (_model.commentCount.integerValue > 0) {
            _commentsLabel.hidden = NO;
            if (_model.commentCount.integerValue < 1000) {
                _commentsLabel.text = _model.commentCount.stringValue;
            } else {
                _commentsLabel.text = @"999+";
            }
            CGSize commentSize = [_model.commentCount.stringValue calculateSize:CGSizeMake(40, 10) font:_commentsLabel.font];
            _commentsLabel.width = MAX(commentSize.width + 5, 10);
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (_cell) {
        [_cell setNeedsLayout];
    }
}

#pragma mark 重置各控件frame（处理屏幕旋转）
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self setUpFrames];
}

#pragma mark 设置各控件frame
- (void)setUpFrames
{
    CGRect rect = self.view.bounds;
    rect.size.width += kPhotoBrowserImageViewMargin * 2;
    _scrollView.bounds = rect;
    _scrollView.center = CGPointMake(kAPPWidth *0.5, kAppHeight *0.5);
    
    CGFloat y = 0;
    __block CGFloat w = kAPPWidth;
    CGFloat h = kAppHeight;
    
    //设置所有HZPhotoBrowserView的frame
    [_scrollView.subviews enumerateObjectsUsingBlock:^(HZPhotoBrowserView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat x = kPhotoBrowserImageViewMargin + idx * (kPhotoBrowserImageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
    }];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.subviews.count * _scrollView.frame.size.width, kAppHeight);
    _scrollView.contentOffset = CGPointMake(self.currentImageIndex * _scrollView.frame.size.width, 0);
    
    _indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    _indexLabel.center = CGPointMake(kAPPWidth * 0.5, 30);
    _saveButton.frame = CGRectMake(30, kAppHeight - 70, 55, 30);
}

#pragma mark 显示图片浏览器
- (void)showPhotoBrowser
{
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
//    UIView *sourceView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
    UIView *sourceView = self.sourceImagesContainerView;

    UIView *parentView = [self getParsentView:sourceView];
    CGRect rect = [sourceView.superview convertRect:sourceView.frame toView:parentView];
    
    //如果是tableview，要减去偏移量
    if ([parentView isKindOfClass:[UITableView class]]) {
        UITableView *tableview = (UITableView *)parentView;
        rect.origin.y =  rect.origin.y - tableview.contentOffset.y;
    }
    if ([sourceView.superview.superview isKindOfClass:[UITableViewCell class]]) {
        rect.origin.y =  rect.origin.y + 64 + 40;
    }
    
//    UIImageView *tempImageView = [[UIImageView alloc] init];
//    tempImageView.frame = rect;
//    tempImageView.image = [self placeholderImageForIndex:self.currentImageIndex];
//    [self.view addSubview:tempImageView];
//    tempImageView.contentMode = UIViewContentModeScaleAspectFill;

//    CGFloat placeImageSizeW = tempImageView.image.size.width;
//    CGFloat placeImageSizeH = tempImageView.image.size.height;
//    CGRect targetTemp;
//    
//    if (!kIsFullWidthForLandScape) {
//        if (kAPPWidth < kAppHeight) {
//            CGFloat placeHolderH = (placeImageSizeH * kAPPWidth)/placeImageSizeW;
//            if (placeHolderH <= kAppHeight) {
//                targetTemp = CGRectMake(0, (kAppHeight - placeHolderH) * 0.5 , kAPPWidth, placeHolderH);
//            } else {
//                targetTemp = CGRectMake(0, 0, kAPPWidth, placeHolderH);
//            }
//        } else {
//            CGFloat placeHolderW = (placeImageSizeW * kAppHeight)/placeImageSizeH;
//            if (placeHolderW < kAPPWidth) {
//                targetTemp = CGRectMake((kAPPWidth - placeHolderW)*0.5, 0, placeHolderW, kAppHeight);
//            } else {
//                targetTemp = CGRectMake(0, 0, placeHolderW, kAppHeight);
//            }
//        }
//
//    } else {
//        CGFloat placeHolderH = (placeImageSizeH * kAPPWidth)/placeImageSizeW;
//        if (placeHolderH <= kAppHeight) {
//            targetTemp = CGRectMake(0, (kAppHeight - placeHolderH) * 0.5 , kAPPWidth, placeHolderH);
//        } else {
//            targetTemp = CGRectMake(0, 0, kAPPWidth, placeHolderH);
//        }
//    }
    
    _scrollView.hidden = YES;
    _indexLabel.hidden = YES;
    _saveButton.hidden = YES;

    [UIView animateWithDuration:kPhotoBrowserShowDuration animations:^{
//        tempImageView.frame = targetTemp;
    } completion:^(BOOL finished) {
        _hasShowedPhotoBrowser = YES;
//        [tempImageView removeFromSuperview];
        _scrollView.hidden = NO;
        _indexLabel.hidden = NO;
        _saveButton.hidden = NO;
    }];
}

#pragma mark 添加scrollview
- (void)addScrollView
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = self.view.bounds;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.hidden = YES;
    [self.view addSubview:_scrollView];
    
    for (int i = 0; i < self.imageCount; i++) {
        HZPhotoBrowserView *view = [[HZPhotoBrowserView alloc] init];
        view.imageview.tag = i;
        
        //处理单击
        __weak __typeof(self)weakSelf = self;
        view.singleTapBlock = ^(UITapGestureRecognizer *recognizer){
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf hidePhotoBrowser:recognizer];
        };
        
        [_scrollView addSubview:view];
    }
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
}

#pragma mark 添加操作按钮
- (void)addToolbars
{
    //序标
    if (self.imageCount > 1) {
        if (!_indexLabel) {
            UILabel *indexLabel = [[UILabel alloc] init];
            indexLabel.textAlignment = NSTextAlignmentCenter;
            indexLabel.textColor = [UIColor whiteColor];
            indexLabel.font = [UIFont boldSystemFontOfSize:20];
            indexLabel.bounds = CGRectMake(0, 0, 100, 40);
            indexLabel.center = CGPointMake(kAPPWidth * 0.5, 30);
            NSString *titleStr = [NSString stringWithFormat:@"1/%ld", (long)self.imageCount];
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:titleStr];
            [attributedStr addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:19],
                                           NSForegroundColorAttributeName : [UIColor whiteColor]
                                           } range:NSMakeRange(0, 1)];
            [attributedStr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16],
                                           NSForegroundColorAttributeName : [UIColor whiteColor]
                                           } range:NSMakeRange(1, attributedStr.length - 1)];
            indexLabel.attributedText = attributedStr;
            self.navigationItem.titleView = indexLabel;
            _indexLabel = indexLabel;
        }
    }
    
//    // 2.保存按钮
//    UIButton *saveButton = [[UIButton alloc] init];
//    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
//    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    saveButton.layer.borderWidth = 0.1;
//    saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
//    saveButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
//    saveButton.layer.cornerRadius = 2;
//    saveButton.clipsToBounds = YES;
//    [saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
//    _saveButton = saveButton;
//    [self.view addSubview:saveButton];
}

#pragma mark 长按图片事件
- (void)longPressAction:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        __weak __typeof(self)weakSelf = self;
        UIAlertController *sheetAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *saveImage = [UIAlertAction actionWithTitle:@"Save Image" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf saveImage];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [sheetAlert addAction:saveImage];
        [sheetAlert addAction:cancel];
        [self presentViewController:sheetAlert animated:YES completion:nil];
    }
}

#pragma mark 保存图像
- (void)saveImage
{
    // 打点-长按图片点击下载-010008
    JTNavigationController *navCtrl = (JTNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    HomeViewController *homeVC = navCtrl.jt_viewControllers.firstObject;
    HomeTableViewController *homeTBC = homeVC.segmentVC.subViewControllers[homeVC.segmentVC.selectIndex - 10000];
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   homeTBC.model.name, @"channel",
                                   _model.news_id, @"article",
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   [NetType getNetType], @"network",
                                   nil];
    [Flurry logEvent:@"PhotoFullScreen_SavePhoto_Click" withParameters:articleParams];
//#if DEBUG
//    [iConsole info:[NSString stringWithFormat:@"PhotoFullScreen_SavePhoto_Click:%@",articleParams],nil];
//#endif
    int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    
    HZPhotoBrowserView *currentView = _scrollView.subviews[index];
    
    UIImageWriteToSavedPhotosAlbum(currentView.imageview.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.view.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [_indicatorView removeFromSuperview];
    SVProgressHUD.defaultStyle = SVProgressHUDStyleDark;
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"Save failed."];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"Saved to your album."];
    }
}

- (void)show
{
//    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:self animated:NO completion:nil];
    // 打点-图片全屏展示页页面进入-010009
    JTNavigationController *navCtrl = (JTNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    HomeViewController *homeVC = navCtrl.jt_viewControllers.firstObject;
    HomeTableViewController *homeTBC = homeVC.segmentVC.subViewControllers[homeVC.segmentVC.selectIndex - 10000];
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                   homeTBC.model.name, @"channel",
                                   _model.news_id, @"article",
                                   [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                   [NetType getNetType], @"network",
                                   nil];
    [Flurry logEvent:@"PhotoFullScreen_Enter" withParameters:articleParams];
    UIViewController *controller = navCtrl.jt_viewControllers[navCtrl.jt_viewControllers.count - 1];
    if ([controller isKindOfClass:[PicDetailViewController class]]) {
        [controller.navigationController pushViewController:self animated:NO];
        return;
    }
    [homeVC.navigationController pushViewController:self animated:YES];
}

#pragma mark 单击隐藏图片浏览器
- (void)hidePhotoBrowser:(UITapGestureRecognizer *)recognizer
{
    [self.navigationController popViewControllerAnimated:YES];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
//    
//    HZPhotoBrowserView *view = (HZPhotoBrowserView *)recognizer.view;
//    UIImageView *currentImageView = view.imageview;
//    
////    UIView *sourceView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
//    UIView *sourceView = self.sourceImagesContainerView;
//    UIView *parentView = [self getParsentView:sourceView];
//    CGRect targetTemp = [sourceView.superview convertRect:sourceView.frame toView:parentView];
//    
//    // 减去偏移量
////    if ([parentView isKindOfClass:[UITableView class]]) {
////        UITableView *tableview = (UITableView *)parentView;
////        targetTemp.origin.y =  targetTemp.origin.y - tableview.contentOffset.y;
////    }
//    if ([sourceView.superview.superview isKindOfClass:[UITableViewCell class]]) {
////        UITableView *tableview = (UITableView *)parentView;
//        targetTemp.origin.y =  targetTemp.origin.y + 64 + 40;
//    }
//    
//    CGFloat appWidth;
//    CGFloat appHeight;
//    if (kAPPWidth < kAppHeight) {
//        appWidth = kAPPWidth;
//        appHeight = kAppHeight;
//    } else {
//        appWidth = kAppHeight;
//        appHeight = kAPPWidth;
//    }
//    
//    UIImageView *tempImageView = [[UIImageView alloc] init];
//    tempImageView.image = currentImageView.image;
//    if (tempImageView.image) {
//        CGFloat tempImageSizeH = tempImageView.image.size.height;
//        CGFloat tempImageSizeW = tempImageView.image.size.width;
//        CGFloat tempImageViewH = (tempImageSizeH * appWidth)/tempImageSizeW;
//        if (tempImageViewH < appHeight) {
//            tempImageView.frame = CGRectMake(0, (appHeight - tempImageViewH)*0.5, appWidth, tempImageViewH);
//        } else {
//            tempImageView.frame = CGRectMake(0, 0, appWidth, tempImageViewH);
//        }
//    } else {
//        tempImageView.backgroundColor = [UIColor whiteColor];
//        tempImageView.frame = CGRectMake(0, (appHeight - appWidth)*0.5, appWidth, appWidth);
//    }
//    
//    [self.view.window addSubview:tempImageView];
//    [self dismissViewControllerAnimated:NO completion:nil];
//    [UIView animateWithDuration:kPhotoBrowserHideDuration animations:^{
//        tempImageView.frame = targetTemp;
//    } completion:^(BOOL finished) {
//        [tempImageView removeFromSuperview];
//    }];
}

#pragma mark 网络加载图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index
{
    HZPhotoBrowserView *view = _scrollView.subviews[index];
    if (view.beginLoadingImage) return;
    if ([self highQualityImageURLForIndex:index]) {
        [view setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
    } else {
        view.imageview.image = [self placeholderImageForIndex:index];
    }
    view.beginLoadingImage = YES;
}

#pragma mark 获取控制器的view
- (UIView *)getParsentView:(UIView *)view{
    if ([[view nextResponder] isKindOfClass:[UIViewController class]] || view == nil) {
        return view;
    }
    return [self getParsentView:view.superview];
}

#pragma mark 获取低分辨率（占位）图片
- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.delegate photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

#pragma mark 获取高分辨率图片url
- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}


#pragma mark - scrollview代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) / _scrollView.bounds.size.width;
    
    NSString *titleStr = [NSString stringWithFormat:@"%d/%ld", index + 1, (long)self.imageCount];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:titleStr];
    [attributedStr addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:19],
                                   NSForegroundColorAttributeName : [UIColor whiteColor]
                                   } range:NSMakeRange(0, 1)];
    [attributedStr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16],
                                   NSForegroundColorAttributeName : [UIColor whiteColor]
                                   } range:NSMakeRange(1, attributedStr.length - 1)];
    _indexLabel.attributedText = attributedStr;
    long left = index - 2;
    long right = index + 2;
    left = left>0?left : 0;
    right = right>self.imageCount ? self.imageCount : right;
    
    //预加载三张图片
    for (long i = left; i < right; i++) {
        [self setupImageOfImageViewForIndex:i];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int autualIndex = scrollView.contentOffset.x / _scrollView.bounds.size.width;
    //设置当前下标
    self.currentImageIndex = autualIndex;
    
    //将不是当前imageview的缩放全部还原 (这个方法有些冗余，后期可以改进)
    for (HZPhotoBrowserView *view in _scrollView.subviews) {
        if (view.imageview.tag != autualIndex) {
            view.scrollview.zoomScale = 1.0;
        }
    }
}

#pragma mark 横竖屏设置
- (BOOL)shouldAutorotate
{
    return shouldSupportLandscape;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (shouldSupportLandscape) {
        return UIInterfaceOrientationMaskAll;
    } else{
        return UIInterfaceOrientationMaskPortrait;
    }
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - addPrivateMethod

#pragma mark - setter/getter
// 内容描述
- (UIView *)contentView
{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor colorWithRed:27/255.0 green:27/255.0 blue:27/255.0 alpha:.4];
        UILabel *contentLabel = [[UILabel alloc] init];
        contentLabel.numberOfLines = 0;
        contentLabel.font = [UIFont systemFontOfSize:16];
        contentLabel.textColor = [UIColor whiteColor];
        contentLabel.text = _model.title;
        CGSize contentSize = [_model.title calculateSize:CGSizeMake(kScreenWidth - 22, 40) font:contentLabel.font];
        contentLabel.frame = CGRectMake(11, 8, contentSize.width, contentSize.height);
        [_contentView addSubview:contentLabel];
        _contentView.frame = CGRectMake(0, self.commentsView.top - contentLabel.height - 16, kScreenWidth, contentLabel.height + 16);
    }
    return _contentView;
}

// 评论视图
- (UIView *)commentsView
{
    if (_commentsView == nil) {
        _commentsView = [[UIView alloc] initWithFrame:CGRectMake(-1, kScreenHeight - 50, kScreenWidth + 2, 51)];
        _commentsView.backgroundColor = SSColor_RGB(27);
        _commentsView.layer.borderWidth = 1;
        _commentsView.layer.borderColor = SSColor_RGB(102).CGColor;
        _commentsView.userInteractionEnabled = YES;
        
        CommentTextField *textField = [[CommentTextField alloc] initWithFrame:CGRectMake(11, 8, kScreenWidth - 22 - 19 * 2 - 24 * 2, 34)];
        textField.backgroundColor = SSColor_RGB(27);
        textField.layer.borderColor = SSColor_RGB(102).CGColor;
        [textField setValue:kGrayColor forKeyPath:@"_placeholderLabel.textColor"];
        [_commentsView addSubview:textField];
        
        UIView *view = [[UIView alloc] initWithFrame:textField.frame];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentAction:)];
        [view addGestureRecognizer:tap];
        [_commentsView addSubview:view];
        
        for (int i = 0; i < 2; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(textField.right + 10 + 43 * i, 0, 42, 50);
            button.tag = 300 + i;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            switch (i) {
                case 0:
                {
                    [button setImage:[UIImage imageNamed:@"icon_article_comments_gray"] forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:@"icon_article_comments_select"] forState:UIControlStateHighlighted];
                    break;
                }
                case 1:
                    [button setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
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
                    CGSize commentSize = [_model.commentCount.stringValue calculateSize:CGSizeMake(40, 10) font:_commentsLabel.font];
                    _commentsLabel.width = MAX(commentSize.width + 5, 10);
                }
            }
        }
    }
    return _commentsView;
}

/**
 *  评论框点击事件
 */
- (void)commentAction:(UITapGestureRecognizer *)tap
{
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
 *  发送评论按钮点击事件
 */
- (void)sendAction
{
    [self postComment];
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
                                           @"Photos", @"channel",
                                           _model.news_id, @"article",
                                           nil];
            [Flurry logEvent:@"Video_Comment_Click" withParameters:articleParams];
            // 点击评论按钮,跳转到评论页
            CommentViewController *commentVC = [[CommentViewController alloc] init];
            commentVC.model = _model;
            [self.navigationController pushViewController:commentVC animated:YES];
            break;
        }
        case 1:
        {
            // 点击facebook按钮
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            NSString *shareString = _model.share_url;
            shareString = [shareString stringByReplacingOccurrencesOfString:@"{from}" withString:@"facebook"];
            content.contentURL = [NSURL URLWithString:shareString];
            content.contentTitle = _model.title;
            ImageModel *imageModel = _model.imgs.firstObject;
            content.imageURL = [NSURL URLWithString:imageModel.src];
            [FBSDKShareDialog showFromViewController:self
                                         withContent:content
                                            delegate:self];
            break;
        }
        default:
            break;
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

#pragma mark - Network
/**
 *  发布评论网络请求
 */
- (void)postComment
{
    _commentTextView.sendButton.enabled = NO;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_model.news_id forKey:@"news_id"];
    [params setObject:_commentTextView.textView.text forKey:@"comment_detail"];
    [[SSHttpRequest sharedInstance] post:kHomeUrl_VideoComment params:params contentType:JsonType serverType:NetServer_V3 success:^(id responseObj) {
        _commentTextView.sendButton.enabled = YES;
        _commentsLabel.hidden = NO;
        _model.commentCount = [NSNumber numberWithInteger:_model.commentCount.integerValue + 1];
        if (_model.commentCount.integerValue < 1000) {
            _commentsLabel.text = _model.commentCount.stringValue;
        } else {
            _commentsLabel.text = @"999+";
        }
        CGSize commentSize = [_model.commentCount.stringValue calculateSize:CGSizeMake(40, 10) font:_commentsLabel.font];
        _commentsLabel.width = MAX(commentSize.width + 5, 10);

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
                                       @"Photos", @"channel",
                                       _model.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Article_Comments_Send_Y" withParameters:articleParams];
    } failure:^(NSError *error) {
        _commentTextView.sendButton.enabled = YES;
        // 打点-评论失败-010211
        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]], @"time",
                                       @"Photos", @"channel",
                                       _model.news_id, @"article",
                                       nil];
        [Flurry logEvent:@"Article_Comments_Send_N" withParameters:articleParams];
    } isShowHUD:YES];
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



@end
