//
//  SingleVideoCell.h
//  Agilanews
//
//  Created by 张思思 on 16/11/3.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"

@interface SingleVideoCell : UITableViewCell

@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) UILabel *titleLabel;          // 标题
@property (nonatomic, strong) UIImageView *titleImageView;  // 标题图片
@property (nonatomic, strong) UIImageView *playView;
@property (nonatomic, strong) UILabel *durationLabel;       // 时长标签
@property (nonatomic, strong) UILabel *tagLabel;            // 标签
@property (nonatomic, strong) UIImageView *watchView;       // 观看量视图
@property (nonatomic, strong) UILabel *watchLabel;
@property (nonatomic, strong) UIImageView *commentView;     // 评论
@property (nonatomic, strong) UILabel *commentLabel;        // 评论数
@property (nonatomic, strong) UIColor *bgColor;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier bgColor:(UIColor *)bgColor;

@end
