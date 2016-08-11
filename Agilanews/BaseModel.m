//
//  BaseModel.m
//
//  Created by zsm on 14-8-20.
//  Copyright (c) 2014年 zsm. All rights reserved.
//

#import "BaseModel.h"
#import <objc/runtime.h>


@interface BaseModel()

- (void)setAttributes:(NSDictionary*)dataDic;

@end


@implementation BaseModel

//自定义一个初始化方法
- (id)initWithContentsOfDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        //挨个的拿到字典里面的内容,通过映射关系,写入的指定的属性里面
        [self dicToObject:dic];
    }
    return self;
}

//创建映射关系
- (NSDictionary *)keyToAtt:(NSDictionary *)dic
{
    NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
    for (NSString *key in dic) {
        //attDic字典里面的
        //key:是传进来字典的key,
        //value:属性的名字
        [attDic setObject:key forKey:key];
    }
    return attDic;
}


//通过属性的名字获取set方法 name -> setName:
- (SEL)setingToSel:(NSString *)model_key
{
    //获取第一个字母并换换成大写
    NSString *first = [[model_key substringToIndex:1] uppercaseString];
    
    NSString *end = [model_key substringFromIndex:1];
    NSString *setSel = [NSString stringWithFormat:@"set%@%@:",first,end];
    return NSSelectorFromString(setSel);
}


//挨个的拿到字典里面的内容,通过映射关系,写入的指定的属性里面
- (void)dicToObject:(NSDictionary *)dic
{
    for (NSString *key in dic) {
        //[获取映射关系字典]通过key获取属性的名字
        NSString *model_key = [[self keyToAtt:dic] objectForKey:key];
        //做一个容错
        if (model_key) {
            //判断当前属性是否存(也就是说判断该属性的set方法是否存在)
            SEL action = [self setingToSel:model_key];
            //判断方法是否存在
            if ([self respondsToSelector:action]) {
                //属性存在,就可以把值写入到属性里面
                [self performSelector:action withObject:[dic objectForKey:key]];
            }
        }
    }
}

-(NSDictionary*)attributeMapDictionary
{
    //    SHOULDOVERRIDE(@"ITTBaseModelObject", NSStringFromClass([self class]));
    return nil;
}

- (NSString *)customDescription
{
    return nil;
}

- (NSData*)getArchivedData
{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

- (NSString *)description
{
    NSMutableString *attrsDesc = [NSMutableString stringWithCapacity:100];
    NSDictionary *attrMapDic = [self attributeMapDictionary];
    NSEnumerator *keyEnum = [attrMapDic keyEnumerator];
    id attributeName;
    while ((attributeName = [keyEnum nextObject])) {
        SEL getSel = NSSelectorFromString(attributeName);
        if ([self respondsToSelector:getSel]) {
            NSMethodSignature *signature = nil;
            signature = [self methodSignatureForSelector:getSel];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:self];
            [invocation setSelector:getSel];
            NSObject *__unsafe_unretained valueObj = nil;
            [invocation invoke];
            [invocation getReturnValue:&valueObj];
            if (valueObj) {
                [attrsDesc appendFormat:@" [%@=%@] ",attributeName,valueObj];
            }else {
                [attrsDesc appendFormat:@" [%@=nil] ",attributeName];
            }
        }
    }
    NSString *customDesc = [self customDescription];
    NSString *desc;
    if (customDesc && [customDesc length] > 0 ) {
        desc = [NSString stringWithFormat:@"%@:{%@,%@}",[self class],attrsDesc,customDesc];
    }
    else {
        desc = [NSString stringWithFormat:@"%@:{%@}",[self class],attrsDesc];
    }
    return desc;
}

-(id)initWithDataDic:(NSDictionary*)data
{
    if (self = [self init]) {
        [self setAttributes:data];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id object = [[self class] allocWithZone:zone];
    NSDictionary *attrMapDic = [self attributeMapDictionary];
    NSEnumerator *keyEnum = [attrMapDic keyEnumerator];
    id attributeName;
    while ((attributeName = [keyEnum nextObject])) {
        SEL getSel = NSSelectorFromString(attributeName);
        SEL sel = [object getSetterSelWithAttibuteName:attributeName];
        if ([self respondsToSelector:sel] &&
            [self respondsToSelector:getSel]) {
            
            NSMethodSignature *signature = nil;
            signature = [self methodSignatureForSelector:getSel];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:self];
            [invocation setSelector:getSel];
            NSObject * __unsafe_unretained valueObj = nil;
            [invocation invoke];
            [invocation getReturnValue:&valueObj];
            
            [object performSelectorOnMainThread:sel
                                     withObject:valueObj
                                  waitUntilDone:TRUE];
        }
    }
    return object;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if( self = [super init] ){
        NSDictionary *attrMapDic = [self attributeMapDictionary];
        if (attrMapDic == nil) {
            return self;
        }
        NSEnumerator *keyEnum = [attrMapDic keyEnumerator];
        id attributeName;
        while ((attributeName = [keyEnum nextObject])) {
            SEL sel = [self getSetterSelWithAttibuteName:attributeName];
            if ([self respondsToSelector:sel]) {
                id obj = [decoder decodeObjectForKey:attributeName];
                [self performSelectorOnMainThread:sel withObject:obj waitUntilDone:[NSThread isMainThread]];
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    NSDictionary *attrMapDic = [self attributeMapDictionary];
    if (attrMapDic == nil) {
        return;
    }
    NSEnumerator *keyEnum = [attrMapDic keyEnumerator];
    id attributeName;
    
    while ((attributeName = [keyEnum nextObject])) {
        
        SEL getSel = NSSelectorFromString(attributeName);
        
        if ([self respondsToSelector:getSel]) {
            
            NSMethodSignature *signature = nil;
            signature = [self methodSignatureForSelector:getSel];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:self];
            [invocation setSelector:getSel];
            NSObject * __unsafe_unretained valueObj = nil;
            [invocation invoke];
            [invocation getReturnValue:&valueObj];
            
            if (valueObj) {
                [encoder encodeObject:valueObj forKey:attributeName];
            }
        }
    }
}

#pragma mark - private methods
-(SEL)getSetterSelWithAttibuteName:(NSString*)attributeName
{
    NSString *capital = [[attributeName substringToIndex:1] uppercaseString];
    NSString *setterSelStr = [NSString stringWithFormat:@"set%@%@:",capital,[attributeName substringFromIndex:1]];
    return NSSelectorFromString(setterSelStr);
}

//User username, age
//dataDic = @{@"name":@"david", @"age":@"12"}
//attrMapDic = @{@"username":@"name", @"age":@"age"};

-(void)setAttributes:(NSDictionary*)dataDic
{
    NSDictionary *attrMapDic = [self attributeMapDictionary];
    if (attrMapDic == nil) {
        return;
    }
    NSEnumerator *keyEnum = [attrMapDic keyEnumerator];
    id attributeName;
    while ((attributeName = [keyEnum nextObject])) {
        SEL sel = [self getSetterSelWithAttibuteName:attributeName];
        if ([self respondsToSelector:sel]) {
            NSString *dataDicKey = attrMapDic[attributeName];
            NSString *value = nil;
            if ([[dataDic objectForKey:dataDicKey] isKindOfClass:[NSNumber class]]) {
                value = [[dataDic objectForKey:dataDicKey] stringValue];
            }
            else if([[dataDic objectForKey:dataDicKey] isKindOfClass:[NSNull class]]){
                value = nil;
            }
            else{
                value = [dataDic objectForKey:dataDicKey];
            }
            [self performSelectorOnMainThread:sel
                                   withObject:value
                                waitUntilDone:[NSThread isMainThread]];
        }
    }
}
/*!
 * get property names of object
 */
- (NSArray*)propertyNames
{
    NSMutableArray *propertyNames = [[NSMutableArray alloc] init];
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        [propertyNames addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);
    return propertyNames;
}

/*!
 *	\returns a dictionary Key-Value pair by property and corresponding value.
 */
- (NSDictionary*)propertiesAndValuesDictionary
{
    NSMutableDictionary *propertiesValuesDic = [NSMutableDictionary dictionary];
    NSArray *properties = [self propertyNames];
    for (NSString *property in properties) {
        SEL getSel = NSSelectorFromString(property);
        if ([self respondsToSelector:getSel]) {
            NSMethodSignature *signature = nil;
            signature = [self methodSignatureForSelector:getSel];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:self];
            [invocation setSelector:getSel];
            NSObject * __unsafe_unretained valueObj = nil;
            [invocation invoke];
            [invocation getReturnValue:&valueObj];
            //assign to @"" string
            if (!valueObj) {
                valueObj = @"";
            }
            propertiesValuesDic[property] = valueObj;
        }
    }
    return propertiesValuesDic;
}



@end
