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

@interface HomeTableViewController : EaseRefreshTableViewController<UITableViewDataSource, UITableViewDelegate, FBSDKSharingDelegate>

@property (nonatomic, strong) CategoriesModel *model;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) UIViewController *segmentVC;
@property (nonatomic, strong) GuideRefreshView *guideView;
@property (nonatomic, assign) float scrollY;
@property (nonatomic, assign) BOOL isDecelerating;          // 正在减速
@property (nonatomic, assign) long long beginScrollTime;    // 开始滚动时间
@property (nonatomic, assign) long long refreshTime;        // 刷新时间
@property (nonatomic, assign) BOOL isFailure;               // 进入失败页面
@property (nonatomic, assign) BOOL isShowBanner;            // 显示刷新位置

- (instancetype)initWithModel:(CategoriesModel *)model;

@end
