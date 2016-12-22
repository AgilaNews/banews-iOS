//
//  TopicCell.h
//  Agilanews
//
//  Created by 张思思 on 16/12/21.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"

@interface TopicCell : UITableViewCell

@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) UIImageView *titleImageView;  // 标题图片
@property (nonatomic, strong) UIView *shadowView;           // 遮罩视图
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UILabel *titleLabel;          // 标题
@property (nonatomic, strong) UILabel *tagLabel;            // 标签
@property (nonatomic, strong) UIImageView *timeView;        // 时钟
@property (nonatomic, strong) UILabel *timeLabel;           // 发布时间
@property (nonatomic, strong) UIButton *dislikeButton;      // 不喜欢按钮

@end
