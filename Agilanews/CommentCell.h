//
//  CommentCell.h
//  Agilanews
//
//  Created by 张思思 on 16/7/26.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentModel.h"

@interface CommentCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarView;  // 头像视图
@property (nonatomic, strong) UILabel *nameLabel;       // 用户名
@property (nonatomic, strong) UILabel *contentLabel;    // 评论内容
@property (nonatomic, strong) UIImageView *timeView;    // 时钟视图
@property (nonatomic, strong) UILabel *timeLabel;       // 评论时间
@property (nonatomic, strong) UIButton *likeButton;     // 点赞按钮
@property (nonatomic, strong) UILabel *replyLabel;      // 回复评论
@property (nonatomic, strong) UILabel *replyContentLabel;

@property (nonatomic, strong) CommentModel *model;

@end
