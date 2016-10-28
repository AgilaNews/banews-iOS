//
//  DetailPlayerViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/10/25.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
#import "NewsModel.h"

@interface DetailPlayerViewController : UIViewController<YTPlayerViewDelegate>

@property (nonatomic, strong) YTPlayerView *playerView;
@property (nonatomic, strong) UIImageView *holderView;
@property (nonatomic, strong) LoadingView *loadingView;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSString *videoid;
@property (nonatomic, strong) NSString *pattern;
@property (nonatomic, strong) NewsModel *model;

@end
