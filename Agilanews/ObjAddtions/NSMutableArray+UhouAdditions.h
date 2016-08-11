//
//  NSMutableArray+UhouAdditions.h
//  Uhou_Framework
//
//  Created by Sunny on 16/1/20.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (UhouAdditions)

-(void)safeString:(NSString*)string;
-(void)safeObject:(id)object;
-(id) objectAtIndexSafe:(NSInteger) index ;

@end
