//
//  VideoModel.h
//  Agilanews
//
//  Created by 张思思 on 16/9/20.
//  Copyright © 2016年 banews. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoModel : NSObject

@property (nonatomic, strong) NSNumber *height;         // 视频的高
@property (nonatomic, strong) NSNumber *width;          // 视频的宽
@property (nonatomic, strong) NSString *src;            // 视频url
@property (nonatomic, strong) NSNumber *duration;       // 播放时间
@property (nonatomic, strong) NSNumber *size;           // 视频大小
@property (nonatomic, strong) NSString *name;           // 视频名称
@property (nonatomic, strong) NSString *pattern;        // 视频占位图
@property (nonatomic, strong) NSString *video_pattern;  // 缓存占位图
@property (nonatomic, strong) NSString *youtube_id;     // 视频id

@end
