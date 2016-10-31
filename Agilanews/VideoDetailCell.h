//
//  VideoDetailCell.h
//  Agilanews
//
//  Created by 张思思 on 16/10/31.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsDetailModel.h"

@interface VideoDetailCell : UITableViewCell

@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) NewsDetailModel *model;
@property (nonatomic, strong) UILabel *titleLabel;          // 标题
@property (nonatomic, strong) UILabel *sourceLabel;         // 来源
@property (nonatomic, strong) UIImageView *watchView;       // 观看量视图
@property (nonatomic, strong) UILabel *watchLabel;          // 观看量
@property (nonatomic, strong) UILabel *contentLabel;        // 内容
@property (nonatomic, strong) UIButton *openButton;         // 展开按钮
@property (nonatomic, strong) UIButton *likeButton;         // 点赞按钮

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier bgColor:(UIColor *)bgColor;

@end
