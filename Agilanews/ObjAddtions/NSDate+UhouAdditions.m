//
//  NSDate+UhouAdditions.m
//  Uhou_Framework
//
//  Created by Sunny on 16/1/20.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import "NSDate+UhouAdditions.h"

@implementation NSDate (UhouAdditions)

+ (NSString *) timeStringWithInterval:(NSTimeInterval)time
{
    
    int distance = [[NSDate date] timeIntervalSince1970] - time;
    NSString *string;
    if (distance < 1){//avoid 0 seconds
        string = @"刚刚";
    }
    else if (distance < 60) {
        string = [NSString stringWithFormat:@"%d秒前", (distance)];
    }
    else if (distance < 3600) {//60 * 60
        distance = distance / 60;
        string = [NSString stringWithFormat:@"%d分钟前", (distance)];
    }
    else if (distance < 86400) {//60 * 60 * 24
        distance = distance / 3600;
        string = [NSString stringWithFormat:@"%d小时前", (distance)];
    }
    else if (distance < 604800) {//60 * 60 * 24 * 7
        distance = distance / 86400;
        string = [NSString stringWithFormat:@"%d天前", (distance)];
    }
    else if (distance < 2419200) {//60 * 60 * 24 * 7 * 4
        distance = distance / 604800;
        string = [NSString stringWithFormat:@"%d周前", (distance)];
    }
    else {
        NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        }
        string = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(time)]];
        
    }
    return string;
}

- (NSString *)stringWithSeperator:(NSString *)seperator
{
    return [self stringWithSeperator:seperator includeYear:YES];
}

// Return the formated string by a given date and seperator.
+ (NSDate *)dateWithString:(NSString *)str formate:(NSString *)formate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formate];
    NSDate *date = [formatter dateFromString:str];
    return date;
}

- (NSString *)stringWithFormat:(NSString*)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *string = [formatter stringFromDate:self];
    return string;
}

+(NSDate*) convertDateFromString:(NSString*)uiDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSDate *date=[formatter dateFromString:uiDate];
    return date;
}

// Return the formated string by a given date and seperator, and specify whether want to include year.
- (NSString *)stringWithSeperator:(NSString *)seperator includeYear:(BOOL)includeYear
{
    if( seperator==nil ){
        seperator = @"-";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if( includeYear ){
        [formatter setDateFormat:[NSString stringWithFormat:@"yyyy%@MM%@dd",seperator,seperator]];
    }else{
        [formatter setDateFormat:[NSString stringWithFormat:@"MM%@dd",seperator]];
    }
    NSString *dateStr = [formatter stringFromDate:self];
    
    return dateStr;
}

// return the date by given the interval day by today. interval can be positive, negtive or zero.
+ (NSDate *)relativedDateWithInterval:(NSInteger)interval
{
    return [NSDate dateWithTimeIntervalSinceNow:(24*60*60*interval)];
}

// return the date by given the interval day by given day. interval can be positive, negtive or zero.
- (NSDate *)relativedDateWithInterval:(NSInteger)interval
{
    NSTimeInterval givenDateSecInterval = [self timeIntervalSinceDate:[NSDate relativedDateWithInterval:0]];
    return [NSDate dateWithTimeIntervalSinceNow:(24*60*60*interval+givenDateSecInterval)];
}

+ (NSString *)weekday
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now = [NSDate date];;
    NSDateComponents *comps = nil;
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    comps = [calendar components:unitFlags fromDate:now];
    NSString *weekdayStr = nil;
    NSInteger weekday = [comps weekday];

    if( weekday==1 ){
        weekdayStr = @"星期日";
    }else if( weekday==2 ){
        weekdayStr = @"星期一";
    }else if( weekday==3 ){
        weekdayStr = @"星期二";
    }else if( weekday==4 ){
        weekdayStr = @"星期三";
    }else if( weekday==5 ){
        weekdayStr = @"星期四";
    }else if( weekday==6 ){
        weekdayStr = @"星期五";
    }else if( weekday==7 ){
        weekdayStr = @"星期六";
    }
    return weekdayStr;
}
///12/03日期格式
+ (NSString *)stringWithData
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now = [NSDate date];;
    NSDateComponents *comps = nil;
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    comps = [calendar components:unitFlags fromDate:now];
    NSString *data = [NSString stringWithFormat:@"%ld/%ld",(long)[comps month],(long)[comps day]];
    return data;
}


+ (NSString *)getDeadLineTimeFromDieTime:(NSString *)dietimeString
{
    NSInteger dietime = dietimeString.intValue;
    NSString *dayString = [NSString stringWithFormat:@"%d",(int)dietime/(3600*24)];
    NSString *hourString = [NSString stringWithFormat:@"%d",(int)dietime%(3600*24)/3600];
    NSString *minuteString = [NSString stringWithFormat:@"%d",(int)dietime/60];
    if ([dietimeString isEqualToString:@"0"]) {
        dayString = @"";
        hourString = @"";
        minuteString = @"0分钟";
    } else {
        if (dayString.intValue == 0 && hourString.intValue == 0) {
            dayString = @"";
            if (minuteString.integerValue == 0) {
                minuteString = @"1分钟";
            } else if (minuteString.integerValue == 59) {
                hourString = @"1小时";
                minuteString = @"";
            } else {
                hourString = @"";
                minuteString = [NSString stringWithFormat:@"%@分钟",minuteString];
            }
        } else {
            if (dayString.integerValue == 0) {
                dayString = @"";
            } else {
                dayString = [NSString stringWithFormat:@"%@天",dayString];
            }
            if (hourString.integerValue == 0) {
                hourString = @"";
            } else if (hourString.integerValue == 23) {
                dayString = [NSString stringWithFormat:@"%d天",(int)dayString.integerValue + 1];
                hourString = @"";
            } else {
                hourString = [NSString stringWithFormat:@"%@小时",hourString];
            }
            minuteString = @"";
        }
    }
    return [NSString stringWithFormat:@"%@%@%@",dayString,hourString,minuteString];
}

+ (NSInteger)stringWithYear
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger year = [dateComponent year];
    return year;
}

#pragma mark - **************** 出生日期转化为年龄
- (NSInteger)ageWithDateOfBirth
{
    // 出生日期转换 年月日
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self];
    NSInteger brithDateYear  = [components1 year];
    NSInteger brithDateDay   = [components1 day];
    NSInteger brithDateMonth = [components1 month];
    
    // 获取系统当前 年月日
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger currentDateYear  = [components2 year];
    NSInteger currentDateDay   = [components2 day];
    NSInteger currentDateMonth = [components2 month];
    
    // 计算年龄
    if (brithDateYear == 2016) {
        NSInteger iAge = currentDateYear - brithDateYear;
        return iAge;
    }else{
        NSInteger iAge = currentDateYear - brithDateYear - 1;
        if ((currentDateMonth > brithDateMonth) || (currentDateMonth == brithDateMonth && currentDateDay >= brithDateDay)) {
            iAge++;
        }
        return iAge;
    }
}

@end
