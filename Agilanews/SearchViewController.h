//
//  SearchViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/12/16.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SearchViewController : BaseViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, FBSDKSharingDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, assign) BOOL showBlankView;
@property (nonatomic, strong) UIView *blankView;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, strong) NSArray *hotArray;
@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, assign) BOOL isTagEnter;

@end
