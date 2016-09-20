//
//  VideoModel.h
//  Agilanews
//
//  Created by 张思思 on 16/9/20.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoModel : NSObject

@property (nonatomic, copy) NSNumber *height;   // 视频的高
@property (nonatomic, copy) NSNumber *width;    // 视频的宽
@property (nonatomic, copy) NSString *src;      // 视频url
@property (nonatomic, copy) NSNumber *duration; // 播放时间
@property (nonatomic, copy) NSNumber *size;     // 视频大小

@end
