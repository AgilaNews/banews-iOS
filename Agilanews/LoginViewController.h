//
//  LoginViewController.h
//  Agilanews
//
//  Created by 张思思 on 16/7/20.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface LoginViewController : BaseViewController

@property (nonatomic, strong) UIImageView *titleImageView;
@property (nonatomic, assign) BOOL isFavorite;  // 从侧边收藏进入
@property (nonatomic, assign) BOOL isCollect;   // 从新闻详情收藏进入
@property (nonatomic, assign) BOOL isComment;   // 从评论框进入
@property (nonatomic, assign) BOOL isShareFacebook; // 从分享facebook进入
@property (nonatomic, assign) BOOL isShareTwitter;  // 从分享twitter进入
@property (nonatomic, assign) BOOL isShareGoogle;   // 从分享google进入

@end
