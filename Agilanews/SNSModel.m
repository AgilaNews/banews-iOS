//
//  SNSModel.m
//  Agilanews
//
//  Created by 张思思 on 17/1/10.
//  Copyright © 2017年 banews. All rights reserved.
//

#import "SNSModel.h"

@implementation SNSModel

MJCodingImplementation

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"sns_type":@"sns_type",
             @"sns_name":@"sns_name",
             @"sns_icon":@"sns_icon",
             @"sns_content":@"sns_content",
             @"src":@"src",
             @"pattern":@"pattern",
             @"width":@"width",
             @"height":@"height",
             @"name":@"name",
             };
}

@end
