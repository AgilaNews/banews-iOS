//
//  NSMutableArray+UhouAdditions.m
//  Uhou_Framework
//
//  Created by Sunny on 16/1/20.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import "NSMutableArray+UhouAdditions.h"

@implementation NSMutableArray (UhouAdditions)

-(void)safeString:(NSString*)string
{
    if (string) {
        if (![string isKindOfClass:[NSNull class]]) {
            [self addObject:string];
        }else
        {
            [self addObject:@""];
        }
    }else
    {
        [self addObject:@""];
    }
}
-(void)safeObject:(id)object
{
    if (object) {
        if (![object isKindOfClass:[NSNull class]]) {
            [self addObject:object];
        }
    }
}

-(id) objectAtIndexSafe:(NSInteger) index {
    
    if (index >= 0 && index <= self.count - 1) {
        return [self objectAtIndex:index];
    }
    return nil;
}


@end
