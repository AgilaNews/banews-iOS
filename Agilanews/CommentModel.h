//
//  CommentModel.h
//  Agilanews
//
//  Created by 张思思 on 16/7/19.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentModel : NSObject

@property (nonatomic, strong) NSString *commentID;          // 评论ID
@property (nonatomic, strong) NSNumber *time;               // 评论时间
@property (nonatomic, strong) NSString *comment;            // 评论详情
@property (nonatomic, strong) NSNumber *user_id;            // 用户ID
@property (nonatomic, strong) NSString *user_name;          // 用户名
@property (nonatomic, strong) NSString *user_portrait_url;  // 用户头像

@end
