//
//  TimeStampToString.h
//  uhou
//
//  Created by 思思 on 15/12/12.
//  Copyright © 2015年 uhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeStampToString : NSObject

+ (NSString *)getADStringWhitTimeStamp:(long long)timeStamp;

+ (NSString *)getMessageStringWithTimeStamp:(long long)timeStamp andType:(BOOL) isYYYY;

+ (NSString *)getDetailStringWhitTimeStamp:(long long)timeStamp;

+ (NSString *)getNewsStringWhitTimeStamp:(long long)timeStamp;

+ (NSString *)getRecommendedNewsStringWhitTimeStamp:(long long)timeStamp;

@end
