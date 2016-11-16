//
//  NotifDetailViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/11/15.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "NotifDetailModel.h"
#import "CommentTextView.h"

@interface NotifDetailViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, FBSDKSharingDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSNumber *notify_id;      // 通知ID
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NotifDetailModel *model;
@property (nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, strong) CommentTextView *commentTextView; // 评论输入框
@property (nonatomic, strong) NSNumber *commentID;


@end
