//
//  SNSModel.h
//  Agilanews
//
//  Created by 张思思 on 17/1/10.
//  Copyright © 2017年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSModel : NSObject

@property (nonatomic, strong) NSNumber *sns_type;
@property (nonatomic, strong) NSString *sns_name;
@property (nonatomic, strong) NSString *sns_icon;
@property (nonatomic, strong) NSString *sns_content;
@property (nonatomic, strong) NSString *src;
@property (nonatomic, strong) NSString *pattern;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSString *name;

@end
