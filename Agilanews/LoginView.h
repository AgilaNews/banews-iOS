//
//  LoginView.h
//  Agilanews
//
//  Created by 张思思 on 16/12/14.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIView <UIGestureRecognizerDelegate, GIDSignInDelegate, GIDSignInUIDelegate>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, assign) BOOL isNotification;  // 从侧边通知进入
@property (nonatomic, assign) BOOL isFavorite;  // 从侧边收藏进入
@property (nonatomic, assign) BOOL isCollect;   // 从新闻详情收藏进入
@property (nonatomic, assign) BOOL isComment;   // 从评论框进入

@end
