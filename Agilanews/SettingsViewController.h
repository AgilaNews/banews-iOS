//
//  SettingsViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/7/23.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "BaseViewController.h"
#import "FontSizeView.h"

typedef NS_ENUM(NSInteger, FontSizeType) {
    Normal = 0,
    ExtraLarge,
    Large,
    Small
};

@interface SettingsViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FontSizeView *fontSizeView;
@property (nonatomic, strong) UISwitch *textOnlySwith;
@property (nonatomic, strong) NSString *cacheSize;

@end
