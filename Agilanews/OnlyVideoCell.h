//
//  OnlyVideoCell.h
//  Agilanews
//
//  Created by 张思思 on 16/10/24.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"

@interface OnlyVideoCell : UITableViewCell<YTPlayerViewDelegate>

@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) YTPlayerView *playerView;     // 播放视图
@property (nonatomic, strong) NSDictionary *playerVars;     // 播放参数
@property (nonatomic, strong) UIImageView *titleImageView;  // 图片视图
@property (nonatomic, strong) UIView *holderView;           // 占位图
@property (nonatomic, strong) UIImageView *shadowView;      // 遮罩视图
@property (nonatomic, strong) UILabel *titleLabel;          // 标题
@property (nonatomic, strong) UILabel *durationLabel;       // 时长标签
@property (nonatomic, strong) UIButton *playButton;         // 播放图片
@property (nonatomic, strong) UIImageView *watchView;       // 观看量视图
@property (nonatomic, strong) UILabel *watchLabel;
@property (nonatomic, strong) UIImageView *commentView;     // 评论视图
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UIButton *shareButton;        // 分享按钮
@property (nonatomic, assign) BOOL isPlay;
@property (nonatomic, assign) BOOL isMove;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier bgColor:(UIColor *)bgColor;

@end
