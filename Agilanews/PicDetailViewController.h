//
//  PicDetailViewController.h
//  Agilanews
//
//  Created by 张思思 on 17/1/8.
//  Copyright © 2017年 banews. All rights reserved.
//

#import "BaseViewController.h"
#import "OnlyPicCell.h"

@interface PicDetailViewController : BaseViewController

@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) OnlyPicCell *cell;

@property (nonatomic, strong) UIView *blankView;
@property (nonatomic, strong) UILabel *blankLabel;
@property (nonatomic, strong) UIImageView *failureView;

@end
