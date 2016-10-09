//
//  CategoriesModel.h
//  Agilanews
//
//  Created by 张思思 on 16/7/13.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoriesModel : NSObject

@property (nonatomic, assign) BOOL fixed;           // 是否为固定位置
@property (nonatomic, strong) NSNumber *channelID;  // 频道ID
@property (nonatomic, strong) NSNumber *index;      // 频道位置
@property (nonatomic, strong) NSString *name;       // 频道名称
@property (nonatomic, assign) BOOL tag;             // 是否为热门频道
@property (nonatomic, assign) BOOL isNew;           // 是否为新频道

@end
