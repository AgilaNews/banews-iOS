//
//  ImageModel.h
//  Agilanews
//
//  Created by 张思思 on 16/7/14.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageModel : NSObject

@property (nonatomic, strong) NSNumber *height;   // 图片的高
@property (nonatomic, strong) NSNumber *width;    // 图片的宽
@property (nonatomic, strong) NSString *name;     //
@property (nonatomic, strong) NSString *pattern;  // 图片url
@property (nonatomic, strong) NSString *src;      // 默认url

@end
