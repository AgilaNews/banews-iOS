//
//  LoginModel.h
//  Agilanews
//
//  Created by 张思思 on 16/7/19.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginModel : NSObject <NSCoding>

@property (nonatomic, strong) NSString *uid;            // 第三方账户ID
@property (nonatomic, strong) NSString *user_id;        // 后端生成ID
@property (nonatomic, strong) NSString *name;           // 用户名
@property (nonatomic, strong) NSNumber *gender;         // 性别：0未知，1男，2女
@property (nonatomic, strong) NSString *portrait;       // 头像url
@property (nonatomic, strong) NSString *email;          // 邮箱
@property (nonatomic, strong) NSNumber *create_time;    // 首次登录时间
@property (nonatomic, strong) NSString *source;         // 登录源

@end
