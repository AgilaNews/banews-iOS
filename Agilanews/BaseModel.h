//
//  BaseModel.h
//
//  Created by zsm on 14-8-20.
//  Copyright (c) 2014年 zsm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject <NSCoding, NSCopying>
{
}
//自定义一个初始化方法
- (id)initWithContentsOfDic:(NSDictionary *)dic;

//创建映射关系
- (NSDictionary *)keyToAtt:(NSDictionary *)dic;


- (id)initWithDataDic:(NSDictionary*)data;

/*!
 *	Subclass must override this method, otherwise app will crash if call this methods
 *	Key-Value pair by dictionary key name and property name.
 *	key:    property name
 *	value:  dictionary key name
 *	\returns a dictionary key-value pair by property name and key of data dictionary
 */
- (NSDictionary*)attributeMapDictionary;

/*!
 *	You can implement this. Default implementation nil is returned
 */
- (NSString*)customDescription;

- (NSString *)description;

- (NSData*)getArchivedData;

- (NSDictionary*)propertiesAndValuesDictionary;

@end
