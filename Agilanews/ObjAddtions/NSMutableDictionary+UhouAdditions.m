//
//  NSMutableDictionary+UhouAdditions.m
//  Uhou_Framework
//
//  Created by Sunny on 16/1/20.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import "NSMutableDictionary+UhouAdditions.h"

@implementation NSMutableDictionary (UhouAdditions)


-(void)safeString:(NSString*)string ForKey:(NSString*)key
{
    NSString * dicKey = key;
    if (!dicKey) {
        dicKey = UNKEY;
    }
    if ([string isKindOfClass:[NSString class]] ||[string isKindOfClass:[NSNull class]]) {
        if (!string) {
            [self setObject:@"" forKey:dicKey];
        }else
        {
            [self setObject:string forKey:dicKey];
        }
    }else
    {
        [self setObject:@"" forKey:dicKey];
    }
}

-(BOOL)isSuccessForRequest
{
    id result=[self objectForKey:@"result"];
    if ([result isKindOfClass:[NSString class]]) {
        if ([result isEqualToString:@"1"]) {
            return YES;
        }else
        {
            return NO;
        }
    }else if ([result isKindOfClass:[NSNumber class]])
    {
        if ([result doubleValue]==1||[result integerValue]==1) {
            return YES;
        }else
        {
            return NO;
        }
    }
    return NO;
}
-(NSString*)errorInfo
{
    return [self objectForKey:@"error_msg"];
}
-(NSString*)errorCode
{
    return [self objectForKey:@"error_no"];
}

+(NSString *)getOrigionPicUrl:(NSDictionary *)dic
{
    NSString * picUrl;
    NSDictionary * tempdic = [dic objectForKey:@"PICURL"];
    if ([tempdic isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    picUrl = [tempdic objectForKey:ORIGION]?[tempdic objectForKey:ORIGION]:@"";
    
    return picUrl;
    
}

+(NSString*)getPicURL:(NSDictionary*)picDic;
{
    if ([picDic isKindOfClass:[NSNull class]]) {
        return @"";
    }
    NSString * picUrl;
    NSDictionary * tempdic = [picDic objectForKey:@"LOGOPIC"];
    if ([tempdic isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    if(iPhone6)
    {
        picUrl = [tempdic objectForKey:MIDDLE]?[tempdic objectForKey:MIDDLE]:@"";
    }
    else if(iPhone6Plus)
    {
        picUrl = [tempdic objectForKey:LARGE]?[tempdic objectForKey:LARGE]:@"";
    }
    else
    {
        picUrl = [tempdic objectForKey:SMALL]?[tempdic objectForKey:SMALL]:@"";
    }
    return picUrl;
}
+(NSString*)getTurnPicURL:(NSDictionary*)picDic;
{
    NSString * picUrl;
    if ([picDic isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    NSDictionary * tempdic = [picDic objectForKey:@"PICURL"];
    if ([tempdic isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    if(iPhone6)
    {
        picUrl = [tempdic objectForKey:MIDDLE]?[tempdic objectForKey:MIDDLE]:@"";
    }
    else if(iPhone6Plus)
    {
        picUrl = [tempdic objectForKey:LARGE]?[tempdic objectForKey:LARGE]:@"";
    }
    else
    {
        picUrl = [tempdic objectForKey:SMALL]?[tempdic objectForKey:SMALL]:@"";
    }
    return picUrl;
}
+(NSString*)getKnowlegdePicURL:(NSDictionary*)picDic;
{
    NSString * picUrl;
    if ([picDic isKindOfClass:[NSNull class]]) {
        return @"";
    }
    NSDictionary * tempdic = [picDic objectForKey:@"picurlStringMap"];
    if ([tempdic isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    if(iPhone6)
    {
        picUrl = [tempdic objectForKey:MIDDLE]?[tempdic objectForKey:MIDDLE]:@"";
    }
    else if(iPhone6Plus)
    {
        picUrl = [tempdic objectForKey:LARGE]?[tempdic objectForKey:LARGE]:@"";
    }
    else
    {
        picUrl = [tempdic objectForKey:SMALL]?[tempdic objectForKey:SMALL]:@"";
    }
    return picUrl;
}


@end
