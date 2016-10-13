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
#import "NewsDetailModel.h"

@interface FavoriteDetailViewController : BaseViewController <UIWebViewDelegate>

@property (nonatomic, strong) NewsModel *model;
@property (nonatomic, strong) NewsDetailModel *detailModel;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) WebViewJavascriptBridge *bridge;

@end
