//
//  MeViewController.h
//  Agilanews
//
//  Created by 张思思 on 17/1/23.
//  Copyright © 2017年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface MeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, GIDSignInDelegate, GIDSignInUIDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *loginLabel;
@property (nonatomic, strong) AppDelegate *appDelegate;

@end
