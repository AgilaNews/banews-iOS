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

@end
