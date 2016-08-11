//
//  SSHttpRequest.h
//  TenMinDemo
//
//  Created by apple开发 on 16/5/31.
//  Copyright © 2016年 CYXiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

typedef enum : NSUInteger {
    UrlencodedType,
    JsonType,
}ContentType;

@interface SSHttpRequest : AFHTTPSessionManager

@property (nonatomic, assign) ContentType contentType;
@property (nonatomic, strong) NSString *urlString;


/**
 *  返回单例
 *
 *  @return 网络单例
 */
+ (instancetype)sharedInstance;

/**
 *  发送一个GET请求
 *
 *  @param url     请求路径
 *  @param params  请求参数
 *  @param success 请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failure 请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
- (NSURLSessionDataTask *)get:(NSString *)url params:(NSMutableDictionary *)params contentType:(ContentType)contentType serverType:(NetServerType)serverType success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure isShowHUD:(BOOL)showHUD;

/**
 *  发送一个POST请求
 *
 *  @param url     请求路径
 *  @param params  请求参数
 *  @param success 请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failure 请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
- (void)post:(NSString *)url params:(NSMutableDictionary *)params contentType:(ContentType)contentType serverType:(NetServerType)serverType success:(void (^)(id responseObj))success failure:(void (^)(NSError *error))failure isShowHUD:(BOOL)showHUD;

/**
 *  发送一个DELETE请求
 *
 *  @param url         请求路径
 *  @param params      请求参数
 *  @param contentType 参数格式
 *  @param serverType  服务器类型
 *  @param success     请求成功后的回调
 *  @param failure     请求失败后的回调
 *  @param showHUD     是否显示HUD
 */
- (void)DELETE:(NSString *)url params:(NSMutableDictionary *)params contentType:(ContentType)contentType serverType:(NetServerType)serverType success:(void (^)(id))success failure:(void (^)(NSError *))failure isShowHUD:(BOOL)showHUD;

@end
