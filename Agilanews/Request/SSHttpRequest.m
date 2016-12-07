//
//  SSHttpRequest.m
//  TenMinDemo
//
//  Created by apple开发 on 16/5/31.
//  Copyright © 2016年 CYXiang. All rights reserved.
//

#import "SSHttpRequest.h"
#import "AFNetworking.h"
#import "Signature.h"
#import "AppDelegate.h"

@implementation SSHttpRequest

static SSHttpRequest *_manager = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [SSHttpRequest manager];
        // 申明返回的结果是text/html类型
        //        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"application/javascript", @"text/html", @"text/plain", @"application/ph", nil];
        // 设置安全性
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
        // 如果是需要验证自建证书，需要设置为YES
        securityPolicy.allowInvalidCertificates = YES;
        // validatesDomainName 是否需要验证域名，默认为YES；
        securityPolicy.validatesDomainName = NO;
        _manager.securityPolicy  = securityPolicy;
        // 设置请求头
        [_manager.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
        [_manager.requestSerializer setValue:@"en-PH;q=0.8,en-US;q=0.5,en;q=0.3" forHTTPHeaderField:@"Accept-Language"];
    });
    return _manager;
}


- (NSURLSessionDataTask *)get:(NSString *)url params:(NSMutableDictionary *)params contentType:(ContentType)contentType serverType:(NetServerType)serverType success:(void (^)(id))success failure:(void (^)(NSError *))failure isShowHUD:(BOOL)showHUD
{
    [self basicSetupWithHttpType:GET ContentType:contentType];
    
    // 接口拼接
    if (url.length < 1) {
#if DEBUG
        _urlString = @"http://api.agilanews.info/";
#else
        _urlString = @"http://api.agilanews.today/";
#endif
    } else {
        switch (serverType) {
            case NetServer_Home:
            {
                if (DEF_PERSISTENT_GET_OBJECT(Server_Home) != nil) {
                    _urlString = [NSString stringWithFormat:@"%@%@",DEF_PERSISTENT_GET_OBJECT(Server_Home),url];
                } else {
                    _urlString = [NSString stringWithFormat:@"%@%@",kHomeUrl,url];
                }
                break;
            }
            case NetServer_V3:
            {
                _urlString = [NSString stringWithFormat:@"%@%@",kV3Url,url];
                break;
            }
            case NetServer_Log:
            {
                if (DEF_PERSISTENT_GET_OBJECT(Server_Log) != nil) {
                    _urlString = [NSString stringWithFormat:@"%@%@",DEF_PERSISTENT_GET_OBJECT(Server_Log),url];
                } else {
                    _urlString = [NSString stringWithFormat:@"%@%@",kLogUrl,url];
                }
                break;
            }
            case NetServer_Mon:
            {
                if (DEF_PERSISTENT_GET_OBJECT(Server_Mon) != nil) {
                    _urlString = [NSString stringWithFormat:@"%@%@",DEF_PERSISTENT_GET_OBJECT(Server_Mon),url];
                } else {
                    _urlString = [NSString stringWithFormat:@"%@%@",kMonUrl,url];
                }
                break;
            }
            case NetServer_Referrer:
            {
                if (DEF_PERSISTENT_GET_OBJECT(Server_Referrer) != nil) {
                    _urlString = [NSString stringWithFormat:@"%@%@",DEF_PERSISTENT_GET_OBJECT(Server_Referrer),url];
                } else {
                    _urlString = [NSString stringWithFormat:@"%@%@",kReferrerUrl,url];
                }
                break;
            }
            case NetServer_Check:
            {
#if DEBUG
                _urlString = [NSString stringWithFormat:@"http://api.agilanews.info/%@",url];
#else
                _urlString = [NSString stringWithFormat:@"http://api.agilanews.today/%@",url];
#endif
                break;
            }
            default:
                break;
        }
    }
    // User-A
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *userA = nil;
    if (appDelegate.model) {
        userA = appDelegate.model.user_id;
    } else {
        userA = @"";
    }
    [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%dx%d;%d;l",(int)kScreenWidth_DP, (int)kScreenHeight_DP, iPhone6Plus ? 401 : 326] forHTTPHeaderField:@"X-DENSITY"];
    [_manager.requestSerializer setValue:userA forHTTPHeaderField:@"X-User-A"];
    [_manager.requestSerializer setValue:DEF_PERSISTENT_GET_OBJECT(@"UUID") forHTTPHeaderField:@"X-Session"];
    [_manager.requestSerializer setValue:DEF_PERSISTENT_GET_OBJECT(@"IDFA") forHTTPHeaderField:@"X-User-D"];
    // 请求时间
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ccc, d LLL YYYY hh:mm:ss zzz"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    dateString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)dateString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    [_manager.requestSerializer setValue:dateString forHTTPHeaderField:@"Date"];
    // 添加默认参数
    // 网络情况
    [params setObject:[NetType getNetType] forKey:@"net"];
    // 经纬度
    if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
        [params setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
        [params setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
    } else {
        [params setObject:@"" forKey:@"lng"];
        [params setObject:@"" forKey:@"lat"];
    }
    // 语言设置
    [params setObject:[[NSLocale preferredLanguages] firstObject] forKey:@"lang"];
    // 客户端版本号
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [params setObject:[NSString stringWithFormat:@"v%@",version] forKey:@"client_version"];
    // 设备ID
    if (DEF_PERSISTENT_GET_OBJECT(@"IDFA") != nil) {
        [params setObject:DEF_PERSISTENT_GET_OBJECT(@"IDFA") forKey:@"idfv"];
        [params setObject:DEF_PERSISTENT_GET_OBJECT(@"IDFA") forKey:@"idfa"];
    } else {
        [params setObject:@"" forKey:@"idfv"];
        [params setObject:@"" forKey:@"idfa"];
    }
    // 系统
    [params setObject:@"ios" forKey:@"os"];
    // 系统版本号
    [params setObject:[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemVersion]] forKey:@"os_version"];
    // X-开头的字段
    NSDictionary *headerDic = _manager.requestSerializer.HTTPRequestHeaders;
    NSMutableArray *headerStringArray = [NSMutableArray array];
    for (NSString *key in headerDic.allKeys) {
        if ([key hasPrefix:@"X-"]) {
            NSString *headerString = [NSString stringWithFormat:@"%@:%@\n",key,headerDic[key]];
            [headerStringArray addObject:headerString];
        }
    }
    NSArray * headerStrings = [headerStringArray sortedArrayUsingSelector:@selector(compare:)];
    NSString * signHeader = [NSString string];
    for (NSString *string in headerStrings) {
        signHeader = [signHeader stringByAppendingString:string];
    }
    // 签名所需参数
    NSMutableArray *paramArray = [NSMutableArray array];
    for (NSString *key in params.allKeys) {
        if (![key isEqualToString:@"Date"]) {
            NSString *paramString = [NSString stringWithFormat:@"%@:%@\n",key,params[key]];
            [paramArray addObject:paramString];
        }
    }
    // 排序
    NSArray * paramStrings = [paramArray sortedArrayUsingSelector:@selector(compare:)];
    NSString * signParam = [NSString string];
    for (NSString *string in paramStrings) {
        signParam = [signParam stringByAppendingString:string];
    }
    NSURL *homeUrl = [NSURL URLWithString:_urlString];
    // 签名算法
    NSString *string = [NSString stringWithFormat:@"GET\n\n%@\n%@%@\n%@",contentType == UrlencodedType ? @"APPLICATION/X-WWW-FORM-URLENCODED" : @"APPLICATION/JSON", [signHeader uppercaseString], [homeUrl.path uppercaseString], [signParam uppercaseString]];
    string = [string substringToIndex:string.length - 1];
    SSLog(@"签名字符串------%@",string);
    NSString *signString = [Signature hmacsha1:string key:@"7intJWbSmtjkrIrb"];
    [_manager.requestSerializer setValue:signString forHTTPHeaderField:@"Authorization"];
    
    // 设置超时时间
    [_manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    [_manager.requestSerializer setTimeoutInterval:8.0f];
    [_manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    // 打印请求参数
    SSLog(@"\n------打印请求地址------\n%@\n------打印请求参数------\n%@\n------打印请求头------\n%@",_urlString,params,string);
    
    NSURLSessionDataTask *dataTask = [_manager GET:_urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            SSLog(@"\n------网络请求结果------\n%@",responseObject);
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (showHUD) {
            SVProgressHUD.defaultStyle = SVProgressHUDStyleLight;
            if ([error code] == NSURLErrorCancelled)
            {
                [SVProgressHUD dismiss];
                SSLog(@"\n------网络请求取消------\n%@",error);
                return;
            }
            // 打点-页面进入-011001
            [Flurry logEvent:@"NetFailure_Enter"];
#if DEBUG
            [iConsole info:@"NetFailure_Enter",nil];
#endif
            if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
            {
                [SVProgressHUD showErrorWithStatus:@"Please check your network connection"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            } else {
                [SVProgressHUD showErrorWithStatus:@"Fetching failed, please try again"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            }
        }
        if (failure) {
            SSLog(@"\n------网络请求失败------\n%@",error.userInfo);
            failure(error);
        }
    }];
    
    return dataTask;
}

- (void)post:(NSString *)url params:(id)params contentType:(ContentType)contentType serverType:(NetServerType)serverType success:(void (^)(id))success failure:(void (^)(NSError *))failure isShowHUD:(BOOL)showHUD
{
    [self basicSetupWithHttpType:POST ContentType:contentType];
    
    NSMutableDictionary *baseParams = [NSMutableDictionary dictionary];
    // 添加默认参数
    // 网络情况
    [baseParams setObject:[NetType getNetType] forKey:@"net"];
    // 经纬度
    if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
        [baseParams setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
        [baseParams setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
    } else {
        [baseParams setObject:@"" forKey:@"lng"];
        [baseParams setObject:@"" forKey:@"lat"];
    }
    // 语言设置
    [baseParams setObject:[[NSLocale preferredLanguages] firstObject] forKey:@"lang"];
    // 客户端版本号
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [baseParams setObject:[NSString stringWithFormat:@"v%@",version] forKey:@"client_version"];
    // 设置IDFA（广告标识符）
    NSString *IDFA = DEF_PERSISTENT_GET_OBJECT(@"IDFA");
    if (!IDFA.length) {
        KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"IDFA" accessGroup:nil];
        IDFA = [keychain objectForKey:(id)kSecValueData];
        if (!IDFA.length) {
            IDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
            [keychain setObject:IDFA forKey:(__bridge id)kSecValueData];
        }
        DEF_PERSISTENT_SET_OBJECT(@"IDFA", IDFA);
    }
    // 设备ID
    if (DEF_PERSISTENT_GET_OBJECT(@"IDFA") != nil) {
        [baseParams setObject:DEF_PERSISTENT_GET_OBJECT(@"IDFA") forKey:@"idfv"];
        [baseParams setObject:DEF_PERSISTENT_GET_OBJECT(@"IDFA") forKey:@"idfa"];
    } else {
        [baseParams setObject:@"" forKey:@"idfv"];
        [baseParams setObject:@"" forKey:@"idfa"];
    }
    // 系统
    [baseParams setObject:@"ios" forKey:@"os"];
    // 系统版本号
    [baseParams setObject:[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemVersion]] forKey:@"os_version"];
    
    // 接口拼接
    switch (serverType) {
        case NetServer_Home:
        {
            if (DEF_PERSISTENT_GET_OBJECT(Server_Home) != nil) {
                _urlString = [NSString stringWithFormat:@"%@%@",DEF_PERSISTENT_GET_OBJECT(Server_Home),url];
            } else {
                _urlString = [NSString stringWithFormat:@"%@%@",kHomeUrl,url];
            }
        }
            break;
        case NetServer_Log:
        {
            if (DEF_PERSISTENT_GET_OBJECT(Server_Log) != nil) {
                _urlString = [NSString stringWithFormat:@"%@%@",DEF_PERSISTENT_GET_OBJECT(Server_Log),url];
            } else {
                _urlString = [NSString stringWithFormat:@"%@%@",kLogUrl,url];
            }
        }
            break;
        case NetServer_Mon:
        {
            if (DEF_PERSISTENT_GET_OBJECT(Server_Mon) != nil) {
                _urlString = [NSString stringWithFormat:@"%@%@",DEF_PERSISTENT_GET_OBJECT(Server_Mon),url];
            } else {
                _urlString = [NSString stringWithFormat:@"%@%@",kMonUrl,url];
            }
        }
            break;
        case NetServer_Referrer:
        {
            if (DEF_PERSISTENT_GET_OBJECT(Server_Referrer) != nil) {
                _urlString = [NSString stringWithFormat:@"%@%@",DEF_PERSISTENT_GET_OBJECT(Server_Referrer),url];
            } else {
                _urlString = [NSString stringWithFormat:@"%@%@",kReferrerUrl,url];
            }
        }
            break;
        default:
            break;
    }
    _urlString = [_urlString stringByAppendingString:@"?"];
    @autoreleasepool {
        for (NSString *key in baseParams.allKeys) {
            _urlString = [_urlString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,baseParams[key]]];
        }
    }
    _urlString = [_urlString substringToIndex:_urlString.length - 1];
    _urlString = [_urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    // User-A
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *userA = nil;
    if (appDelegate.model) {
        userA = appDelegate.model.user_id;
    } else {
        userA = @"";
    }
    [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%dx%d;%d;l",(int)kScreenWidth_DP, (int)kScreenHeight_DP, iPhone6Plus ? 401 : 326] forHTTPHeaderField:@"X-DENSITY"];
    [_manager.requestSerializer setValue:userA forHTTPHeaderField:@"X-User-A"];
    [_manager.requestSerializer setValue:DEF_PERSISTENT_GET_OBJECT(@"UUID") forHTTPHeaderField:@"X-Session"];
    [_manager.requestSerializer setValue:DEF_PERSISTENT_GET_OBJECT(@"IDFA") forHTTPHeaderField:@"X-User-D"];
    // 请求时间
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ccc, d LLL YYYY hh:mm:ss zzz"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    dateString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)dateString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    [_manager.requestSerializer setValue:dateString forHTTPHeaderField:@"Date"];
    // X-开头的字段
    NSDictionary *headerDic = _manager.requestSerializer.HTTPRequestHeaders;
    NSMutableArray *headerStringArray = [NSMutableArray array];
    for (NSString *key in headerDic.allKeys) {
        if ([key hasPrefix:@"X-"]) {
            NSString *headerString = [NSString stringWithFormat:@"%@:%@\n",key,headerDic[key]];
            [headerStringArray addObject:headerString];
        }
    }
    NSArray * headerStrings = [headerStringArray sortedArrayUsingSelector:@selector(compare:)];
    NSString * signHeader = [NSString string];
    for (NSString *string in headerStrings) {
        signHeader = [signHeader stringByAppendingString:string];
    }
    // 签名所需参数
    NSMutableArray *paramArray = [NSMutableArray array];
    for (NSString *key in baseParams.allKeys) {
        if (![key isEqualToString:@"Date"]) {
            NSString *paramString = [NSString stringWithFormat:@"%@:%@\n",key,baseParams[key]];
            [paramArray addObject:paramString];
        }
    }
    // 排序
    NSString * signParam = [NSString string];
    NSArray * paramStrings = [paramArray sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *string in paramStrings) {
        signParam = [signParam stringByAppendingString:string];
    }
    NSURL *homeUrl = [NSURL URLWithString:_urlString];
    // body-MD5加密
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *paramsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    paramsString = [paramsString stringByReplacingOccurrencesOfString:@" " withString:@""];
    paramsString = [paramsString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *md5String = [NSString md5:paramsString];
    // 签名算法
    NSString *string = [NSString stringWithFormat:@"POST\n%@\n%@\n%@%@\n%@", [md5String uppercaseString], contentType == UrlencodedType ? @"APPLICATION/X-WWW-FORM-URLENCODED" : @"APPLICATION/JSON", [signHeader uppercaseString], [homeUrl.path uppercaseString], [signParam uppercaseString]];
    string = [string substringToIndex:string.length - 1];
    SSLog(@"签名字符串------%@",string);
    NSString *signString = [Signature hmacsha1:string key:@"7intJWbSmtjkrIrb"];
    [_manager.requestSerializer setValue:signString forHTTPHeaderField:@"Authorization"];
    
    // 设置超时时间为5s
    [_manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    [_manager.requestSerializer setTimeoutInterval:8.0f];
    [_manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    // 打印请求参数
    SSLog(@"\n------打印请求地址------\n%@\n------打印请求参数------\n%@",_urlString,params);
    
    [_manager POST:_urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            SSLog(@"\n------网络请求结果------\n%@",responseObject);
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (showHUD) {
            SVProgressHUD.defaultStyle = SVProgressHUDStyleLight;
            if ([error code] == NSURLErrorCancelled)
            {
                [SVProgressHUD dismiss];
                SSLog(@"\n------网络请求取消------\n%@",error);
                return;
            }
            // 打点-页面进入-011001
            [Flurry logEvent:@"NetFailure_Enter"];
#if DEBUG
            [iConsole info:@"NetFailure_Enter",nil];
#endif
            if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
            {
                [SVProgressHUD showErrorWithStatus:@"Please check your network connection"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            } else {
                [SVProgressHUD showErrorWithStatus:@"Fetching failed, please try again"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            }
        }
        if (failure) {
            SSLog(@"\n------网络请求失败------\n%@",error.userInfo);
            failure(error);
        }
    }];
}

- (void)DELETE:(NSString *)url params:(NSMutableDictionary *)params contentType:(ContentType)contentType serverType:(NetServerType)serverType success:(void (^)(id))success failure:(void (^)(NSError *))failure isShowHUD:(BOOL)showHUD
{
    [self basicSetupWithHttpType:DELETE ContentType:contentType];
    
    // 接口拼接
    switch (serverType) {
        case NetServer_Home:
        {
            if (DEF_PERSISTENT_GET_OBJECT(Server_Home) != nil) {
                _urlString = [NSString stringWithFormat:@"%@%@",DEF_PERSISTENT_GET_OBJECT(Server_Home),url];
            } else {
                _urlString = [NSString stringWithFormat:@"%@%@",kHomeUrl,url];
            }
        }
            break;
        case NetServer_Log:
        {
            if (DEF_PERSISTENT_GET_OBJECT(Server_Log) != nil) {
                _urlString = [NSString stringWithFormat:@"%@%@",DEF_PERSISTENT_GET_OBJECT(Server_Log),url];
            } else {
                _urlString = [NSString stringWithFormat:@"%@%@",kLogUrl,url];
            }
        }
            break;
        case NetServer_Mon:
        {
            if (DEF_PERSISTENT_GET_OBJECT(Server_Mon) != nil) {
                _urlString = [NSString stringWithFormat:@"%@%@",DEF_PERSISTENT_GET_OBJECT(Server_Mon),url];
            } else {
                _urlString = [NSString stringWithFormat:@"%@%@",kMonUrl,url];
            }
        }
            break;
        case NetServer_Referrer:
        {
            if (DEF_PERSISTENT_GET_OBJECT(Server_Referrer) != nil) {
                _urlString = [NSString stringWithFormat:@"%@%@",DEF_PERSISTENT_GET_OBJECT(Server_Referrer),url];
            } else {
                _urlString = [NSString stringWithFormat:@"%@%@",kReferrerUrl,url];
            }
        }
            break;
        default:
            break;
    }
    // User-A
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *userA = nil;
    if (appDelegate.model) {
        userA = appDelegate.model.user_id;
    } else {
        userA = @"";
    }
    [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%dx%d;%d;l",(int)kScreenWidth_DP, (int)kScreenHeight_DP, iPhone6Plus ? 401 : 326] forHTTPHeaderField:@"X-DENSITY"];
    [_manager.requestSerializer setValue:userA forHTTPHeaderField:@"X-User-A"];
    [_manager.requestSerializer setValue:DEF_PERSISTENT_GET_OBJECT(@"UUID") forHTTPHeaderField:@"X-Session"];
    [_manager.requestSerializer setValue:DEF_PERSISTENT_GET_OBJECT(@"IDFA") forHTTPHeaderField:@"X-User-D"];
    // 请求时间
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ccc, d LLL YYYY hh:mm:ss zzz"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    dateString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)dateString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    [_manager.requestSerializer setValue:dateString forHTTPHeaderField:@"Date"];
    
    // 添加默认参数
    // 网络情况
    [params setObject:[NetType getNetType] forKey:@"net"];
    // 经纬度
    if (DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) != nil && DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) != nil) {
        [params setObject:DEF_PERSISTENT_GET_OBJECT(SS_LONGITUDE) forKey:@"lng"];
        [params setObject:DEF_PERSISTENT_GET_OBJECT(SS_LATITUDE) forKey:@"lat"];
    } else {
        [params setObject:@"" forKey:@"lng"];
        [params setObject:@"" forKey:@"lat"];
    }
    // 语言设置
    [params setObject:[[NSLocale preferredLanguages] firstObject] forKey:@"lang"];
    // 客户端版本号
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [params setObject:[NSString stringWithFormat:@"v%@",version] forKey:@"client_version"];
    // 设备ID
    if (DEF_PERSISTENT_GET_OBJECT(@"IDFA") != nil) {
        [params setObject:DEF_PERSISTENT_GET_OBJECT(@"IDFA") forKey:@"idfv"];
        [params setObject:DEF_PERSISTENT_GET_OBJECT(@"IDFA") forKey:@"idfa"];
    } else {
        [params setObject:@"" forKey:@"idfv"];
        [params setObject:@"" forKey:@"idfa"];
    }
    // 系统
    [params setObject:@"ios" forKey:@"os"];
    // 系统版本号
    [params setObject:[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemVersion]] forKey:@"os_version"];
    
    // X-开头的字段
    NSDictionary *headerDic = _manager.requestSerializer.HTTPRequestHeaders;
    NSMutableArray *headerStringArray = [NSMutableArray array];
    for (NSString *key in headerDic.allKeys) {
        if ([key hasPrefix:@"X-"]) {
            NSString *headerString = [NSString stringWithFormat:@"%@:%@\n",key,headerDic[key]];
            [headerStringArray addObject:headerString];
        }
    }
    NSArray * headerStrings = [headerStringArray sortedArrayUsingSelector:@selector(compare:)];
    NSString * signHeader = [NSString string];
    for (NSString *string in headerStrings) {
        signHeader = [signHeader stringByAppendingString:string];
    }
    // 签名所需参数
    NSMutableArray *paramArray = [NSMutableArray array];
    for (NSString *key in params.allKeys) {
        if (![key isEqualToString:@"Date"]) {
            NSString *paramString = [NSString stringWithFormat:@"%@:%@\n",key,params[key]];
            [paramArray addObject:paramString];
        }
    }
    // 排序
    NSArray * paramStrings = [paramArray sortedArrayUsingSelector:@selector(compare:)];
    NSString * signParam = [NSString string];
    for (NSString *string in paramStrings) {
        signParam = [signParam stringByAppendingString:string];
    }
    NSURL *homeUrl = [NSURL URLWithString:_urlString];
    // 签名算法
    NSString *string = [NSString stringWithFormat:@"GET\n\n%@\n%@%@\n%@",contentType == UrlencodedType ? @"APPLICATION/X-WWW-FORM-URLENCODED" : @"APPLICATION/JSON", [signHeader uppercaseString], [homeUrl.path uppercaseString], [signParam uppercaseString]];
    string = [string substringToIndex:string.length - 1];
    SSLog(@"签名字符串------%@",string);
    NSString *signString = [Signature hmacsha1:string key:@"7intJWbSmtjkrIrb"];
    [_manager.requestSerializer setValue:signString forHTTPHeaderField:@"Authorization"];
    
    _manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithArray:@[@"GET", @"HEAD"]];
    // 设置超时时间
    [_manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    [_manager.requestSerializer setTimeoutInterval:8.0f];
    [_manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    // 打印请求参数
    SSLog(@"\n------打印请求地址------\n%@\n------打印请求参数------\n%@",_urlString,params);
    [_manager DELETE:_urlString parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            SSLog(@"\n------网络请求结果------\n%@",responseObject);
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (showHUD) {
            SVProgressHUD.defaultStyle = SVProgressHUDStyleLight;
            if ([error code] == NSURLErrorCancelled)
            {
                [SVProgressHUD dismiss];
                SSLog(@"\n------网络请求取消------\n%@",error);
                return;
            }
            // 打点-页面进入-011001
            [Flurry logEvent:@"NetFailure_Enter"];
#if DEBUG
            [iConsole info:@"NetFailure_Enter",nil];
#endif
            if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
            {
                [SVProgressHUD showErrorWithStatus:@"Please check your network connection"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            } else {
                [SVProgressHUD showErrorWithStatus:@"Fetching failed, please try again"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            }
        }
        if (failure) {
            SSLog(@"\n------网络请求失败------\n%@",error.userInfo);
            failure(error);
        }
    }];
}

- (void)basicSetupWithHttpType:(HttpType)httpType ContentType:(ContentType)contentType
{
    if (httpType == GET) {
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    } else {
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    // 参数格式
    if (contentType == UrlencodedType) {
        [_manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    } else {
        [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
}

@end
