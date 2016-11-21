//
//  NotificationViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/11/15.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "BaseViewController.h"

@interface NotificationViewController : BaseViewController<UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataList;


@property (nonatomic, assign) BOOL showBlankView;
@property (nonatomic, strong) UIView *blankView;


@end
