//
//  FacebookAdCell.h
//  Agilanews
//
//  Created by 张思思 on 16/11/18.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"

@interface FacebookAdCell : UITableViewCell <FBNativeAdDelegate>

@property (nonatomic, strong) NewsModel *model;

@property (nonatomic, strong) UILabel *titleLabel;          // 标题
@property (nonatomic, strong) UIImageView *titleImageView;  // 标题图片
@property (nonatomic, strong) UILabel *contentLabel;        // 内容标签
@property (nonatomic, strong) UILabel *sourceLabel;         // 来源
@property (nonatomic, strong) UIButton *learnButton;        // 更多按钮

@end
