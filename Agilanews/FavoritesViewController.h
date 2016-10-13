//
//  FavoritesViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/7/25.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "BaseViewController.h"

@interface FavoritesViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) NSMutableArray *detailList;
@property (nonatomic, strong) NSMutableIndexSet *indexSet;
@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) NSMutableArray *selectedList;
@property (nonatomic, strong) NSMutableArray *selectedDetail;
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL showBlankView;
@property (nonatomic, strong) UIView *blankView;

@end
