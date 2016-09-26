//
//  GifPicCell.h
//  Agilanews
//
//  Created by 张思思 on 16/7/15.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"
#import "LoadingView.h"

@interface GifPicCell : UITableViewCell

@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) UILabel *titleLabel;          // 标题
@property (nonatomic, strong) UIImageView *titleImageView;  // 标题图片
@property (nonatomic, strong) UIButton *playButton;         // 播放图片
@property (nonatomic, strong) UIButton *likeButton;         // 点赞按钮
@property (nonatomic, strong) UIButton *shareButton;        // 分享按钮
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) AVPlayer *player;             // 播放器对象
@property (nonatomic, strong) AVPlayerLayer *playerLayer;   // 播放层
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) LoadingView *loadingView;
@property (nonatomic, assign) BOOL isPlay;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier bgColor:(UIColor *)bgColor;

@end
