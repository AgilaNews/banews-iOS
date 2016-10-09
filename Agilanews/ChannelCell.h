//
//  ChannelCell.h
//  Agilanews
//
//  Created by 张思思 on 16/9/28.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoriesModel.h"

@interface ChannelCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CategoriesModel *model;
@property (nonatomic, strong) UIImageView *labelView;

@end
