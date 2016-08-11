//
//  TimeStampToString.m
//  uhou
//
//  Created by 思思 on 15/12/12.
//  Copyright © 2015年 uhou. All rights reserved.
//

#import "TimeStampToString.h"

@implementation TimeStampToString

+ (NSString *)getNewsStringWhitTimeStamp:(long long)timeStamp
{
    // 如果时间戳为空则返回空
    if (timeStamp == 0) {
        return nil;
    }
    // 如果为毫秒时间戳，则转换为秒单位时间戳
    if ([NSString stringWithFormat:@"%lld",timeStamp].length == 13) {
        timeStamp = timeStamp / 1000;
    }
    // 计算时间戳与当前时间的差
    long long time = [[NSDate date] timeIntervalSince1970] - timeStamp;
    // 判断时间
    if (time < 60) {
        // 一分钟之内
        return @"just now";
    } else if (time < 60 * 60) {
        // 一小时之内
        return [NSString stringWithFormat:@"%lldm",time / 60];
    } else if (time < 60 * 60 * 24) {
        // 一天之内
        return [NSString stringWithFormat:@"%lldh",time / (60 * 60)];
    } else if (time >= 60 * 60 * 24){
        // 一天之外
        return [NSString stringWithFormat:@"%lldd",time / (60 * 60 * 24)];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // 设置日期格式化类型
        [dateFormatter setDateFormat:@"yyyy-M-d"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
        NSString *dateString = [dateFormatter stringFromDate:date];
        return dateString;
    }
}

+ (NSString *)getRecommendedNewsStringWhitTimeStamp:(long long)timeStamp
{
    // 如果时间戳为空则返回空
    if (timeStamp == 0) {
        return nil;
    }
    // 如果为毫秒时间戳，则转换为秒单位时间戳
    if ([NSString stringWithFormat:@"%lld",timeStamp].length == 13) {
        timeStamp = timeStamp / 1000;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // 设置日期格式化类型
    [dateFormatter setDateFormat:@"yyyy-M-d"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+ (NSString *)getADStringWhitTimeStamp:(long long)timeStamp
{
    // 如果时间戳为空则返回空
    if (timeStamp == 0) {
        return nil;
    }
    // 如果为毫秒时间戳，则转换为秒单位时间戳
    if ([NSString stringWithFormat:@"%lld",timeStamp].length == 13) {
        timeStamp = timeStamp / 1000;
    }
    // 获取今年1月1日0点时间戳
    NSTimeInterval yearTimeStamp = [self getYearTimeStamp];
    // 计算时间戳与当前时间的差
    long long time = [[NSDate date] timeIntervalSince1970] - timeStamp;
    // 判断时间
    if (time < 60) {
        // 一分钟之内
        return @"1分钟前";
    } else if (time < 60 * 60) {
        // 一小时之内
        return [NSString stringWithFormat:@"%lld分钟前",time / 60];
    } else if (time < 60 * 60 * 24) {
        // 一天之内
        return [NSString stringWithFormat:@"%lld小时前",time / (60 * 60)];
    }
    //    else if (time < 60 * 60 * 24 * 7) {
    //        // 一周之内
    //        return [NSString stringWithFormat:@"%lld天前",time / (60 * 60 * 24)];
    //    }
    else if (timeStamp >= yearTimeStamp) {
        // 取到时间戳
        NSTimeInterval timeInterval = timeStamp;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // 设置日期格式化类型
        [dateFormatter setDateFormat:@"M月d日"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSString *dateString = [dateFormatter stringFromDate:date];
        return dateString;
    } else {
        // 取到时间戳
        NSTimeInterval timeInterval = timeStamp;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // 设置日期格式化类型
        [dateFormatter setDateFormat:@"yy年M月d日"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSString *dateString = [dateFormatter stringFromDate:date];
        return dateString;
    }
}


+ (NSString *)getDetailStringWhitTimeStamp:(long long)timeStamp
{
    // 如果时间戳为空则返回空
    if (timeStamp == 0) {
        return nil;
    }
    // 如果为毫秒时间戳，则转换为秒单位时间戳
    if ([NSString stringWithFormat:@"%lld",timeStamp].length == 13) {
        timeStamp = timeStamp / 1000;
    }
    // 获取今年1月1日0点时间戳
    NSTimeInterval yearTimeStamp = [self getYearTimeStamp];
    // 计算时间戳与当前时间的差
    long long time = [[NSDate date] timeIntervalSince1970] - timeStamp;
    // 判断时间
    if (time < 60) {
        // 一分钟之内
        return @"1分钟前";
    } else if (time < 60 * 60) {
        // 一小时之内
        return [NSString stringWithFormat:@"%lld分钟前",time / 60];
    } else if (time < 60 * 60 * 24) {
        // 一天之内
        return [NSString stringWithFormat:@"%lld小时前",time / (60 * 60)];
    }
    //    else if (time < 60 * 60 * 24 * 7) {
    //        // 一周之内
    //        return [NSString stringWithFormat:@"%lld天前",time / (60 * 60 * 24)];
    //    }
    else if (timeStamp >= yearTimeStamp) {
        // 取到时间戳
        NSTimeInterval timeInterval = timeStamp;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // 设置日期格式化类型
        [dateFormatter setDateFormat:@"M月d日 HH:mm"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSString *dateString = [dateFormatter stringFromDate:date];
        return dateString;
    } else {
        // 取到时间戳
        NSTimeInterval timeInterval = timeStamp;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // 设置日期格式化类型
        [dateFormatter setDateFormat:@"yyyy年M月d日 HH:mm"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSString *dateString = [dateFormatter stringFromDate:date];
        return dateString;
    }
}


+ (NSString *)getMessageStringWithTimeStamp:(long long)timeStamp andType:(BOOL) isYYYY
{
    // 如果时间戳为空则返回空
    if (timeStamp == 0) {
        return nil;
    }
    // 如果为毫秒时间戳，则转换为秒单位时间戳
    if ([NSString stringWithFormat:@"%lld",timeStamp].length == 13) {
        timeStamp = timeStamp / 1000;
    }
    // 获取今天0点时间戳
    NSTimeInterval todayTimeStamp = [self getTodayTimeStamp];
    // 获取今年1月1日0点时间戳
    //    NSTimeInterval yearTimeStamp = [self getYearTimeStamp];
    
    if (timeStamp >= todayTimeStamp) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // 设置日期格式化类型
        [dateFormatter setDateFormat:@"HH:mm"];
        NSTimeInterval timeInterval = timeStamp;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSString *dateString = [dateFormatter stringFromDate:date];
        return dateString;
    } else {
        // 取到时间戳
        NSTimeInterval timeInterval = timeStamp;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // 设置日期格式化类型
        if (isYYYY) {
            [dateFormatter setDateFormat:@"yyyy/M/d"];
        } else {
            [dateFormatter setDateFormat:@"yy/M/d"];
        }
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        NSString *dateString = [dateFormatter stringFromDate:date];
        return dateString;
    }
    //    else {
    //        // 取到时间戳
    //        NSTimeInterval timeInterval = timeStamp;
    //        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //        // 设置日期格式化类型
    //        [dateFormatter setDateFormat:@"yy/M/d"];
    //        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    //        NSString *dateString = [dateFormatter stringFromDate:date];
    //        return dateString;
    //    }
}

// 获取今天0点时间戳
+ (NSTimeInterval)getTodayTimeStamp
{
    // 获取当前时间
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // 设置日期格式化类型
    [dateFormatter setDateFormat:@"yyyy.MM.dd"];
    NSString *nowString = [dateFormatter stringFromDate:nowDate];
    NSDate *todayDate = [dateFormatter dateFromString:nowString];
    // 转换成今天0点时间戳
    NSTimeInterval todayTimeStamp = [todayDate timeIntervalSince1970];
    
    return todayTimeStamp;
}

// 获取今年1月1日0点时间戳
+ (NSTimeInterval)getYearTimeStamp
{
    // 获取当前时间
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // 设置日期格式化类型
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *nowString = [dateFormatter stringFromDate:nowDate];
    NSDate *todayDate = [dateFormatter dateFromString:nowString];
    // 转换成今年1月1日0点时间戳
    NSTimeInterval yearTimeStamp = [todayDate timeIntervalSince1970];
    
    return yearTimeStamp;
}

@end
