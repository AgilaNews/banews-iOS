//
//  NSTimer+UhouAdditions.h
//  Uhou_Framework
//
//  Created by Sunny on 16/1/20.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (UhouAdditions)


- (void)pauseTimer;
- (void)resumeTimer;
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;
@end
