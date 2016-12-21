//
//  ManyPicCell.h
//  Agilanews
//
//  Created by 张思思 on 16/7/15.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"

@interface ManyPicCell : UITableViewCell

@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) UILabel *titleLabel;          // 标题
@property (nonatomic, strong) UIImageView *imageViewOne;    // 图片1
@property (nonatomic, strong) UIImageView *imageViewTwo;    // 图片2
@property (nonatomic, strong) UIImageView *imageViewThree;  // 图片3
@property (nonatomic, strong) UILabel *tagLabel;            // 标签
@property (nonatomic, strong) UILabel *sourceLabel;         // 来源
@property (nonatomic, strong) UIImageView *timeView;        // 时钟
@property (nonatomic, strong) UILabel *timeLabel;           // 发布时间
@property (nonatomic, strong) UIImageView *commentView;     // 评论
@property (nonatomic, strong) UILabel *commentLabel;        // 评论数
@property (nonatomic, strong) UIButton *dislikeButton;      // 不喜欢按钮
@property (nonatomic, assign) BOOL isSearch;            

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier bgColor:(UIColor *)bgColor;

@end
