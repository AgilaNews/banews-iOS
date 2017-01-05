//
//  HZPhotoBrowser.h
//  photoBrowser
//
//  Created by huangzhenyu on 15/6/23.
//  Copyright (c) 2015年 eamon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HZPhotoBrowserView.h"
#import "NewsModel.h"
#import "BaseViewController.h"
#import "CommentTextView.h"

@class HZPhotoBrowser;
@class OnlyPicCell;
@protocol HZPhotoBrowserDelegate <NSObject>
- (UIImage *)photoBrowser:(HZPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index;
- (NSURL *)photoBrowser:(HZPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index;
@end

@interface HZPhotoBrowser : BaseViewController <UITextViewDelegate, FBSDKSharingDelegate>

@property (nonatomic, weak) UIView *sourceImagesContainerView;
@property (nonatomic, assign) int currentImageIndex;
@property (nonatomic, assign) NSInteger imageCount;//图片总数
@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) OnlyPicCell *cell;
@property (nonatomic, weak) id<HZPhotoBrowserDelegate> delegate;

@property (nonatomic, strong) UIView *commentsView;     // 底部评论框
@property (nonatomic, strong) UILabel *commentsLabel;   // 评论数标签
@property (nonatomic, strong) CommentTextView *commentTextView;     // 评论输入框
@property (nonatomic, strong) UIView *contentView;    // 详情标签



- (void)show;
@end
