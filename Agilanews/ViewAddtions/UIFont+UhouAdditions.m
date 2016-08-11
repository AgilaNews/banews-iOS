//
//  UIFont+UhouAdditions.m
//  Uhou_Framework
//
//  Created by Sunny on 16/1/20.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import "UIFont+UhouAdditions.h"

@implementation UIFont (UhouAdditions)

- (CGFloat)ittLineHeight {
    return (self.ascender - self.descender) + 1;
}


@end
