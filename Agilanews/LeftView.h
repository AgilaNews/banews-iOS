//
//  LeftViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/7/19.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftTableView.h"

@interface LeftView : UIView

@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, strong) LeftTableView *tableView;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UIPanGestureRecognizer *leftPan;
@property (nonatomic, assign) float panX;

@end
