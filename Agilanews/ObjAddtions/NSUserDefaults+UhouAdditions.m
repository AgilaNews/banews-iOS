//
//  NSUserDefaults+UhouAdditions.m
//  Uhou_Framework
//
//  Created by Sunny on 16/2/29.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import "NSUserDefaults+UhouAdditions.h"

@implementation NSUserDefaults (UhouAdditions)

- (void)synchronizeObject:(nullable id)obj forKey:(nonnull NSString *)key
{

    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault setObject:obj forKey:key];
    
    [userDefault synchronize];
}

@end
