//
//  NotificationCell.h
//  Agilanews
//
//  Created by 张思思 on 16/11/15.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationModel.h"

@interface NotificationCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarView;  // 头像视图
@property (nonatomic, strong) UILabel *nameLabel;       // 用户名
@property (nonatomic, strong) UILabel *contentLabel;    // 评论内容
@property (nonatomic, strong) UIImageView *timeView;    // 时钟视图
@property (nonatomic, strong) UILabel *timeLabel;       // 评论时间
@property (nonatomic, strong) UILabel *replyContentLabel;   // 回复评论内容
@property (nonatomic, strong) UIView *verticalLine;

@property (nonatomic, strong) NotificationModel *model;

@end
