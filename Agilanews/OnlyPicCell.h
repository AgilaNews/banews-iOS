//
//  OnlyPicCell.h
//  Agilanews
//
//  Created by 张思思 on 16/7/15.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"
#import "HZPhotoBrowser.h"

@interface OnlyPicCell : UITableViewCell <HZPhotoBrowserDelegate>

@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) UILabel *titleLabel;          // 标题
@property (nonatomic, strong) UIImageView *titleImageView;  // 标题图片
@property (nonatomic, strong) UIImageView *watchView;       // 观看量视图
@property (nonatomic, strong) UILabel *watchLabel;
@property (nonatomic, strong) UIImageView *commentView;     // 评论视图
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UIButton *shareButton;        // 分享按钮
@property (nonatomic, strong) UIColor *bgColor;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier bgColor:(UIColor *)bgColor;
- (void)tapAction;

@end
