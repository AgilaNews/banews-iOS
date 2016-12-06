//
//  TopCell.h
//  Agilanews
//
//  Created by 张思思 on 16/12/5.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"

@interface TopCell : UITableViewCell

@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) UIImageView *titleImageView;

@end
