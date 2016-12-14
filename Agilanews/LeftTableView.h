//
//  LeftTableView.h
//  Agilanews
//
//  Created by 张思思 on 16/7/20.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface LeftTableView : UITableView<UITableViewDataSource, UITableViewDelegate, GIDSignInDelegate, GIDSignInUIDelegate>

@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *loginLabel;
@property (nonatomic, strong) AppDelegate *appDelegate;

@end
