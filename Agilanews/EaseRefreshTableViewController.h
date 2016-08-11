//
//  EaseRefreshTableViewController.h
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/24.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KCELLDEFAULTHEIGHT 50

@interface EaseRefreshTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_rightItems;
}

@property (strong, nonatomic) NSArray *rightItems;
@property (strong, nonatomic) UIView *defaultFooterView;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableDictionary *dataDictionary;
@property (nonatomic) int page;

@property (nonatomic) BOOL showOldRefreshHeader;
@property (nonatomic) BOOL showRefreshHeader;//是否支持下拉刷新
@property (nonatomic) BOOL showRefreshFooter;//是否支持上拉加载
@property (nonatomic,assign) BOOL customBottomFotter; //自定义fotter
@property (nonatomic) BOOL showTableBlankView;//是否显示无数据时默认背景
@property (nonatomic, strong) UIView *blankView;
@property (nonatomic, strong) UILabel *blankLabel;
@property (nonatomic, strong) UIImageView *failureView;

- (instancetype)initWithStyle:(UITableViewStyle)style;

- (void)tableViewDidTriggerHeaderRefresh;//下拉刷新事件
- (void)tableViewDidTriggerFooterRefresh;//上拉加载事件

- (void)tableViewDidFinishTriggerHeader:(BOOL)isHeader reload:(BOOL)reload;

#pragma mark - 设置返回按钮
- (void)setIsBackButton;
- (void)backAction:(UIButton *) leftBtn;
#pragma mark - 设置标题颜色为白色
//- (void)setTitleColorIsWhite:(BOOL)titleColorIsWhite;

#pragma mark - 设置关闭按钮
- (void)setIsDismissButton;
/**
 *  隐藏navgationbar
 */
- (void)hidenNavBar;
// 显示NavgationBar
//- (void) showNavBar:(UIColor *) color ;

@end
