//
//  WebViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/7/23.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, WebType) {
    TermOfService,
    PrivacyPolicy
};

@interface WebViewController : BaseViewController <UIWebViewDelegate>

@property (nonatomic, assign) WebType webType;
@property (nonatomic, strong) UIWebView *webView;

- (instancetype)initWithWebType:(WebType)webType;

@end
