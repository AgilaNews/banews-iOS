//
//  UserInfoViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/7/21.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "LoginModel.h"

@interface UserInfoViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) LoginModel *model;
@property (nonatomic, strong) UITableView *tableView;

@end
