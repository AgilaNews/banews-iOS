//
//  NSArray+UhouAdditions.m
//  Uhou_Framework
//
//  Created by Sunny on 16/1/22.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import "NSArray+UhouAdditions.h"

@implementation NSArray (UhouAdditions)

-(id) objectAtIndexSafe:(NSInteger) index {
    
    if (index >= 0 && index <= self.count - 1) {
        return [self objectAtIndex:index];
    }
    return nil;
}

@end
