//
//  LSEmojiFly.h
//  EmojiFly
//
//  Created by ZhangPeng on 16/4/11.
//  Copyright © 2016年 Rising. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSEmojiFly : NSObject

+ (LSEmojiFly *)emojiFly;

- (void)startFlyWithEmojiImage:(UIImage *)image onView:(UIView *)view;

- (void)endFly;

@end
