//
//  FavoriteDetailViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/7/28.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "NewsModel.h"

@interface FavoriteDetailViewController : BaseViewController <UIWebViewDelegate>

@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSURLSessionDataTask *task;

@end
