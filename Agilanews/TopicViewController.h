//
//  TopicViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/12/22.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "BaseViewController.h"
#import "NewsModel.h"

@interface TopicViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, FBSDKSharingDelegate>

@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, assign) BOOL showBlankView;
@property (nonatomic, strong) UIView *blankView;
@property (nonatomic, strong) UILabel *blankLabel;
@property (nonatomic, strong) UIImageView *failureView;


@end
