//
//  BigPicCell.h
//  Agilanews
//
//  Created by 张思思 on 16/8/29.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"

@interface BigPicCell : UITableViewCell

@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) UILabel *titleLabel;          // 标题
@property (nonatomic, strong) UIImageView *titleImageView;  // 标题图片
@property (nonatomic, strong) UILabel *sourceLabel;         // 来源
@property (nonatomic, strong) UIImageView *timeView;        // 时钟
@property (nonatomic, strong) UILabel *timeLabel;           // 发布时间
@property (nonatomic, strong) UIColor *bgColor;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier bgColor:(UIColor *)bgColor;

@end
