//
//  InterestsViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/12/22.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "BaseViewController.h"

@interface InterestsViewController : BaseViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *baseArray;
@property (nonatomic, strong) NSMutableArray *interests;
@property (nonatomic, assign) BOOL isSkip;

@end
