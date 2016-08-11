//
//  NSMutableDictionary+UhouAdditions.h
//  Uhou_Framework
//
//  Created by Sunny on 16/1/20.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UNKEY   @"unkey"
#define SMALL   @"retSmallPicName"
#define MIDDLE  @"retMiddlePicName"
#define LARGE   @"retBigPicName"
#define ORIGION @"originalPicName"

@interface NSMutableDictionary (UhouAdditions)

-(void)safeString:(NSString*)string ForKey:(NSString*)key;
-(BOOL)isSuccessForRequest;
-(NSString*)errorInfo;
-(NSString*)errorCode;
+(NSString*)getPicURL:(NSDictionary*)picDic;
+(NSString *)getOrigionPicUrl:(NSDictionary *)dic;
+(NSString*)getTurnPicURL:(NSDictionary*)picDic;
+(NSString*)getKnowlegdePicURL:(NSDictionary*)picDic;

@end
