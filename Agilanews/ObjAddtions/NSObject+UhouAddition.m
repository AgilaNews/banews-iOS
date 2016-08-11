//
//  NSObject+UhouAddition.m
//  Uhou_Framework
//
//  Created by Sunny on 16/5/18.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import "NSObject+UhouAddition.h"

@implementation NSObject (UhouAddition)

- (NSString *) confirmWithString{
    
    if (self == nil || [self isKindOfClass:[NSNull class]] || (NSNull *)self == [NSNull null] || [(NSString *)self isEqualToString:@"<null>"]) {
        return @"";
    }else {
        return (NSString *)self;
    }
}

@end
