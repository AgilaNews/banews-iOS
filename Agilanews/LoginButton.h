//
//  LoginButton.h
//  Agilanews
//
//  Created by 张思思 on 16/7/20.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LoginType) {
    FacebookType = 0,
    TwitterType,
    GooglePulsType
};

@interface LoginButton : UIButton

@property (nonatomic, assign) LoginType loginType;
@property (nonatomic, strong) UIImageView *titleImageView;

@end
