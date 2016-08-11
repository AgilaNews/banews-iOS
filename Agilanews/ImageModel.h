//
//  ImageModel.h
//  Agilanews
//
//  Created by 张思思 on 16/7/14.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageModel : NSObject

@property (nonatomic, copy) NSNumber *height;   // 图片的高
@property (nonatomic, copy) NSNumber *width;    // 图片的宽
@property (nonatomic, copy) NSString *name;     //
@property (nonatomic, copy) NSString *pattern;  // 图片url
@property (nonatomic, copy) NSString *src;      // 默认url

@end
