//
//  ImageModel.m
//  Agilanews
//
//  Created by 张思思 on 16/7/14.
//  Copyright © 2016年 banews. All rights reserved.
//

#import "ImageModel.h"

@implementation ImageModel

MJCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"height":@"height",
             @"width":@"width",
             @"name":@"name",
             @"pattern":@"pattern",
             @"src":@"src"
             };
}

@end
