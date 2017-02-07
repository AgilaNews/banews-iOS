//
//  HomeViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/7/14.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SegmentViewController.h"
#import "LeftView.h"

@interface HomeViewController : BaseViewController

@property (nonatomic, strong) SegmentViewController *segmentVC;
@property (nonatomic, strong) LeftView *leftView;
@property (nonatomic, strong) UIView *navView;
@property (nonatomic, strong) UIButton *titleButton;
//@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIView *backToTop;

- (void)showBackToTopView;
- (void)removeBackToTopView;


@end
