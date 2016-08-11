//
//  NSDate+UhouAdditions.h
//  Uhou_Framework
//
//  Created by Sunny on 16/1/20.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (UhouAdditions)

+ (NSDate *)dateWithString:(NSString *)str formate:(NSString *)formate;
+ (NSDate *)relativedDateWithInterval:(NSInteger)interval;
+ (NSString *)getDeadLineTimeFromDieTime:(NSString *)dietimeString;
+ (NSString *)timeStringWithInterval:(NSTimeInterval) time;
- (NSString *)stringWithSeperator:(NSString *)seperator;
- (NSString *)stringWithFormat:(NSString*)format;
- (NSString *)stringWithSeperator:(NSString *)seperator includeYear:(BOOL)includeYear;
+ (NSString *)weekday;
- (NSDate *)relativedDateWithInterval:(NSInteger)interval ;
///12/03日期格式
+ (NSString *)stringWithData;
/**
 *  年
 */
+ (NSInteger)stringWithYear;

+(NSDate*) convertDateFromString:(NSString*)uiDate;

/**
 *  出生日期转年龄
 *
 *  @param date
 *
 *  @return
 */
- (NSInteger)ageWithDateOfBirth;
@end
