//
//  NSString+UhouAdditions.m
//  Uhou_Framework
//
//  Created by Sunny on 16/1/20.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import "NSString+UhouAdditions.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "UIFont+UhouAdditions.h"


#import <resolv.h>
#include <arpa/inet.h>


#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <net/if.h>

@implementation NSString (UhouAdditions)


//-----------------------------------------------------------------------------------
// 字符串 所占位置操作集合，包括
// 1)高度，宽度，大小
//-----------------------------------------------------------------------------------

//返回行数
//- (NSInteger)numberOfLinesWithFont:(UIFont*)font withLineWidth:(NSInteger)lineWidth
//{
//    CGSize size = [self sizeWithFont:font
//                   constrainedToSize:CGSizeMake(lineWidth, CGFLOAT_MAX)
//                       lineBreakMode:NSLineBreakByTruncatingTail];
//    NSInteger lines = size.height / [font ittLineHeight];
//    return lines;
//}

//计算字符串的宽度
-(CGFloat)widthWithFont:(UIFont *)font withLineHeight:(CGFloat)lineHeight
{
    CGSize beforeSize = CGSizeMake(CGFLOAT_MAX, lineHeight);
    
    CGSize nowSize = [self calculateSize:beforeSize font:font];
    return nowSize.width;
    
}

//计算文本的高度
- (CGFloat)heightWithFont:(UIFont*)font
            withLineWidth:(NSInteger)lineWidth{
    CGSize beforeSize = CGSizeMake(lineWidth, CGFLOAT_MAX);
    CGSize nowSize = [self calculateSize:beforeSize font:font];
    return nowSize.height;
    
}

//计算文本 占的size
- (CGSize)calculateSize:(CGSize)size font:(UIFont *)font {
    CGSize expectedLabelSize = CGSizeZero;
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
        
        expectedLabelSize = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }
    else {
        expectedLabelSize = [self sizeWithFont:font
                             constrainedToSize:size
                                 lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    return CGSizeMake(ceil(expectedLabelSize.width), ceil(expectedLabelSize.height));
}

//去掉前后的空格
-(NSString *)removeStringSpaceBlankEndAndStart
{
    if (self) {
        NSString *noSpaceStr = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        return noSpaceStr;
    }
    return nil;
    
}

//判断是否由某字符串开头
- (BOOL)isStartWithString:(NSString*)start
{
    BOOL result = FALSE;
    NSRange found = [self rangeOfString:start options:NSCaseInsensitiveSearch];
    if (found.location == 0)
    {
        result = TRUE;
    }
    return result;
}

//判断是否由某字符串结尾
- (BOOL)isEndWithString:(NSString*)end
{
    NSInteger endLen = [end length];
    NSInteger len = [self length];
    BOOL result = TRUE;
    if (endLen <= len) {
        NSInteger index = len - 1;
        for (NSInteger i = endLen - 1; i >= 0; i--) {
            if ([end characterAtIndex:i] != [self characterAtIndex:index]) {
                result = FALSE;
                break;
            }
            index--;
        }
    }
    else {
        result = FALSE;
    }
    return result;
}

//判断字符串是否为空
+(BOOL)checkStringIsValided:(NSString*)string
{
    if (!string) {
        return NO;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return NO;
    }
    if ([string isEqualToString:@""]) {
        return NO;
    }
    return YES;
}


//-----------------------------------------------------------------------------------
// 安全相关的字符串操作集合，包括
// 1) 3DES加密解密
// 2) Base64编码解码            ----------这是从别处copy过来的--by lisa
//-----------------------------------------------------------------------------------

#pragma mark--Private Method
/*!
 * base64编码用的查表
 */
static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short _base64DecodingTable[256] = {
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
    -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
    -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};


/*!
 * 对一个二进制数组进行3DES加密或者解密，使用key做为密钥，返回加密或者解密后的二进制结果
 * 3DES算法要求密钥是24字节长，这里要求一个24个字符的字符串做为参数
 */
+ (NSData *)doCipherWithData:(NSData*)data key:(NSString*)key operation:(CCOperation)encryptOrDecrypt
{
    const void * dataIn;
    size_t dataInLength;
    
    dataInLength = [data length];
    dataIn = [data bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t * dataOut = NULL;
    size_t dataOutAvailable = 0;
    size_t dataOutMoved = 0;
    // uint8_t ivkCCBlockSize3DES;
    
    dataOutAvailable = (dataInLength + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    
    dataOut = malloc(dataOutAvailable * sizeof(uint8_t));
    memset((void *)dataOut, 0x0, dataOutAvailable);
    
    uint8_t iv[kCCBlockSize3DES];
    memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    const void * vkey = (const void *)[key UTF8String];
    
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey, // 24字节的key
                       kCCKeySize3DES,
                       iv,
                       dataIn, //plainText,
                       dataInLength,
                       (void *)dataOut,
                       dataOutAvailable,
                       &dataOutMoved);
    
    if (ccStatus != kCCSuccess) NSLog(@"cryptor error: ccStatus=%d", ccStatus);
    
    return [NSData dataWithBytes:(const void *)dataOut length:(NSUInteger)dataOutMoved];
}

#pragma mark---Public Method
/*!
 * md5加密
 */
+ (NSString *)encryptPassword:(NSString *)str
{
    // MD5 加密密码
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString  stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12],result[13], result[14], result[15]
            ];
}

+ (NSString *)md5:(NSString *)inPutText
{
//    const char *cStr = [inPutText UTF8String];
//    unsigned char result[CC_MD5_DIGEST_LENGTH];
//    CC_MD5(cStr,(CC_LONG)strlen(cStr),result);
//    
//    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
//             result[0], result[1], result[2], result[3],
//             result[4], result[5], result[6], result[7],
//             result[8], result[9], result[10], result[11],
//             result[12], result[13], result[14], result[15]
//             ] lowercaseString];
    
    const char *cStr = [inPutText UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
    return  output;
}

- (NSString *) stringFromMD5
{
    if(self == nil || [self length] == 0)
        return nil;
    NSString *tem = [NSString stringWithFormat:@"%@uhouuh_phone_code_md5salthx",self];
    const char *value = [tem UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (int)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++)
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    
    return outputString;
}



/*!
 * 对一个字符串进行加密，返回base64编码后的结果
 */
- (NSString *)encryptWithKey:(NSString*)key
{
    NSData * data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData * dataout = [NSString doCipherWithData:data key:key operation:kCCEncrypt];
    return [NSString encodeBase64WithData:dataout];
}

/*!
 * 对一个base64编码的字符串进行解密
 */
- (NSString *)decryptBase64WithKey:(NSString*)key
{
    NSData *datain = [NSString decodeBase64WithString:self];
    NSData *dataout = [NSString doCipherWithData:datain key:key operation:kCCDecrypt];
    return [[NSString alloc] initWithData:dataout encoding:NSUTF8StringEncoding];
}

/*!
 * 返回base64编码结果
 */
- (NSString *)base64String
{
    return [NSString encodeBase64WithData:[self dataUsingEncoding:NSUTF8StringEncoding]];
}

/*!
 * 对二进制数据进行base64编码
 */
+ (NSString *)encodeBase64WithData:(NSData *)objData
{
    const unsigned char * objRawData = [objData bytes];
    char * objPointer;
    char * strResult;
    
    // Get the Raw Data length and ensure we actually have data
    int intLength = (int)[objData length];
    if (intLength == 0) return nil;
    
    // Setup the String-based Result placeholder and pointer within that placeholder
    strResult = (char *)calloc(((intLength + 2) / 3) * 4 + 1, sizeof(char));
    objPointer = strResult;
    
    // Iterate through everything
    while (intLength > 2) { // keep going until we have less than 24 bits
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
        *objPointer++ = _base64EncodingTable[((objRawData[1] & 0x0f) << 2) + (objRawData[2] >> 6)];
        *objPointer++ = _base64EncodingTable[objRawData[2] & 0x3f];
        
        // we just handled 3 octets (24 bits) of data
        objRawData += 3;
        intLength -= 3;
    }
    
    // now deal with the tail end of things
    if (intLength != 0) {
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        if (intLength > 1) {
            *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
            *objPointer++ = _base64EncodingTable[(objRawData[1] & 0x0f) << 2];
            *objPointer++ = '=';
        } else {
            *objPointer++ = _base64EncodingTable[(objRawData[0] & 0x03) << 4];
            *objPointer++ = '=';
            *objPointer++ = '=';
        }
    }
    
    // Terminate the string-based result
    *objPointer = '\0';
    
    // Return the results as an NSString object
    NSString *result = @(strResult);
    free(strResult);
    return result;
}

/*!
 * 把base64字符串解码成二进制数据
 */
+ (NSData *)decodeBase64WithString:(NSString *)strBase64
{
    const char * objPointer = [strBase64 cStringUsingEncoding:NSASCIIStringEncoding];
    int intLength = (int)strlen(objPointer);
    int intCurrent;
    int i = 0, j = 0, k;
    
    unsigned char * objResult;
    objResult = calloc(intLength, sizeof(char));
    
    // Run through the whole string, converting as we go
    while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
        if (intCurrent == '=') {
            if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
                // the padding character is invalid at this point -- so this entire string is invalid
                free(objResult);
                return nil;
            }
            continue;
        }
        
        intCurrent = _base64DecodingTable[intCurrent];
        if (intCurrent == -1) {
            // we're at a whitespace -- simply skip over
            continue;
        } else if (intCurrent == -2) {
            // we're at an invalid character
            free(objResult);
            return nil;
        }
        
        switch (i % 4) {
            case 0:
                objResult[j] = intCurrent << 2;
                break;
                
            case 1:
                objResult[j++] |= intCurrent >> 4;
                objResult[j] = (intCurrent & 0x0f) << 4;
                break;
                
            case 2:
                objResult[j++] |= intCurrent >>2;
                objResult[j] = (intCurrent & 0x03) << 6;
                break;
                
            case 3:
                objResult[j++] |= intCurrent;
                break;
        }
        i++;
    }
    
    // mop things up if we ended on a boundary
    k = j;
    if (intCurrent == '=') {
        switch (i % 4) {
            case 1:
                // Invalid state
                free(objResult);
                return nil;
                
            case 2:
                k++;
                // flow through
            case 3:
                objResult[k] = 0;
        }
    }
    
    // Cleanup and setup the return NSData
    NSData * objData = [[NSData alloc] initWithBytes:objResult length:j];
    free(objResult);
    return objData;
}


//-----------------------------------------------------------------------------------
// 字符串操作集合，包括
// 1)是否是手机号
// 2)是否是邮箱
// 3)手机号的类型
// 4)直接拨打电话
//-----------------------------------------------------------------------------------
#pragma mark - pravite method
/*
 是否有拨打电话功能
 @param       无
 @return      BOOL
 @exception   NO
 */
- (BOOL)isCallPhoneAvilable{
    return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://"]];
}



/**
 *  判断输入字符是否是邮箱格式
 *
 *  @param email 字符串
 *
 *  @return 是为YES  否为NO
 */
+ (BOOL) validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (NSString *)safeString {
    
    if (self == [NSNull class] || !self || [self isEqualToString:@"(null)"] || [self isEqualToString:@"<null>"]) {
        return @"";
    }else {
        return self;
    }
    
}


#pragma mark -  NSString,NSArray和NSDictionary to JSON标准格式字符串

+(NSString *) jsonStringWithString:(NSString *) string{
    return [NSString stringWithFormat:@"\"%@\"",
            [[string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""]
            ];
}
+(NSString *) jsonStringWithArray:(NSArray *)array{
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"["];
    NSMutableArray *values = [NSMutableArray array];
    for (id valueObj in array) {
        NSString *value = [NSString jsonStringWithObject:valueObj];
        if (value) {
            [values addObject:[NSString stringWithFormat:@"%@",value]];
        }
    }
    [reString appendFormat:@"%@",[values componentsJoinedByString:@","]];
    [reString appendString:@"]"];
    return reString;
}
+(NSString *) jsonStringWithDictionary:(NSDictionary *)dictionary{
    NSArray *keys = [dictionary allKeys];
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"{"];
    NSMutableArray *keyValues = [NSMutableArray array];
    for (int i=0; i<[keys count]; i++) {
        NSString *name = [keys objectAtIndex:i];
        id valueObj = [dictionary objectForKey:name];
        NSString *value = [NSString jsonStringWithObject:valueObj];
        if (value) {
            [keyValues addObject:[NSString stringWithFormat:@"\"%@\":%@",name,value]];
        }
    }
    [reString appendFormat:@"%@",[keyValues componentsJoinedByString:@","]];
    [reString appendString:@"}"];
    return reString;
}

+(NSString *) jsonStringWithObject:(id) object{
    NSString *value = nil;
    if (!object) {
        return value;
    }
    if ([object isKindOfClass:[NSString class]]) {
        value = [NSString jsonStringWithString:object];
    }else if([object isKindOfClass:[NSDictionary class]]){
        value = [NSString jsonStringWithDictionary:object];
    }else if([object isKindOfClass:[NSArray class]]){
        value = [NSString jsonStringWithArray:object];
    }
    return value;
}


/**
 *  类方法计算size大小
 */
+ (CGSize)sizeWithString:(NSString *)str andFont:(UIFont *)font andMaxSize:(CGSize)size
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

/**
 *  对象方法计算size大小
 */
- (CGSize)sizeWithFont:(UIFont *)font andMaxSize:(CGSize)size;
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

/**
 *  判断是否为空字符串
 *
 *  @return Bool
 */
+ (BOOL)isBlankString:(id)string
{
    
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    if ([string isEqualToString:@"null"] || [string isEqualToString:@"(null)"])
    {
        return YES;
    }
    return NO;
}

- (NSString *) getLocalIP {

    
    const char *char_ip = [self cStringUsingEncoding:NSASCIIStringEncoding];
    
    //方法 1
    unsigned char auResult[512];
    int nBytesRead = 0;
    
    nBytesRead = res_query(char_ip, ns_c_in, ns_t_a, auResult, sizeof(auResult));
    
    ns_msg handle;
    ns_initparse(auResult, nBytesRead, &handle);
    
    NSMutableArray *ipList = nil;
    int msg_count = ns_msg_count(handle, ns_s_an);
    if (msg_count > 0) {
        ipList = [[NSMutableArray alloc] initWithCapacity:msg_count];
        for(int rrnum = 0; rrnum < msg_count; rrnum++) {
            ns_rr rr;
            if(ns_parserr(&handle, ns_s_an, rrnum, &rr) == 0) {
                char ip1[16];
                strcpy(ip1, inet_ntoa(*(struct in_addr *)ns_rr_rdata(rr)));
                NSString *ipString = [[NSString alloc] initWithCString:ip1 encoding:NSASCIIStringEncoding];
                if (![ipString isEqualToString:@""]) {
                    
                    //将提取到的IP地址放到数组中
                    [ipList addObject:ipString];
                }
            }
        }
    }
    
    //方法 2
    
    struct hostent *host = gethostbyname(char_ip);
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    NSString *result_ip = [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
    
    //方法 3
    Boolean result,bResolved;
    CFHostRef hostRef;
    CFArrayRef addresses = NULL;
    
    CFStringRef hostNameRef = CFStringCreateWithCString(kCFAllocatorDefault, char_ip, kCFStringEncodingASCII);
    
    hostRef = CFHostCreateWithName(kCFAllocatorDefault, hostNameRef);
    if (hostRef) {
        result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL);
        if (result == TRUE) {
            addresses = CFHostGetAddressing(hostRef, &result);
        }
    }
    bResolved = result == TRUE ? true : false;
    
    if(bResolved)
    {
        struct sockaddr_in* remoteAddr;
        for(int i = 0; i < CFArrayGetCount(addresses); i++)
        {
            CFDataRef saData = (CFDataRef)CFArrayGetValueAtIndex(addresses, i);
            remoteAddr = (struct sockaddr_in*)CFDataGetBytePtr(saData);
            
            if(remoteAddr != NULL)
            {
                //获取IP地址
                char ip[16];
                strcpy(ip, inet_ntoa(remoteAddr->sin_addr));
            }
        }
    }
    CFRelease(hostNameRef);
    CFRelease(hostRef);
    
    if (ipList.count > 0) {
        return [NSString stringWithFormat:@"http://%@",[ipList firstObject]];
    } else {
        if (result_ip) {
            return [NSString stringWithFormat:@"http://%@",result_ip];
        }else {
            return nil;
        }
    }
}

@end
