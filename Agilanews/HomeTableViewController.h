//
//  HomeTableViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/7/14.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "EaseRefreshTableViewController.h"
#import "CategoriesModel.h"
#import "ImageModel.h"
#import "GuideRefreshView.h"

@interface HomeTableViewController : EaseRefreshTableViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CategoriesModel *model;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) UIViewController *segmentVC;
@property (nonatomic, strong) GuideRefreshView *guideView;
@property (nonatomic, assign) float scrollY;
@property (nonatomic, assign) BOOL isDecelerating;
@property (nonatomic, assign) long long beginScrollTime;

- (instancetype)initWithModel:(CategoriesModel *)model;

@end
