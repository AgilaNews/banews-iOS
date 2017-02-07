//
//  VideoViewController.h
//  Agilanews
//
//  Created by 张思思 on 17/1/23.
//  Copyright © 2017年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SegmentViewController.h"

@interface VideoViewController : BaseViewController

@property (nonatomic, strong) SegmentViewController *segmentVC;
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UIView *navView;

@end
