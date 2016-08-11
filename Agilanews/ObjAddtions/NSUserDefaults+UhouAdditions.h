//
//  NSUserDefaults+UhouAdditions.h
//  Uhou_Framework
//
//  Created by Sunny on 16/2/29.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (UhouAdditions)

/**
 *  直接synchronize
 *
 *  @param obj 对象
 *  @param key 键
 */
- (void) synchronizeObject:(nullable id)obj forKey:(nonnull NSString *)key;

@end
