//
//  ArrayMap.h
//  hkutil-static
//
//  Created by akwei on 13-12-4.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKArrayMap : NSObject

/**
 获得数组
 @return 存储的数据数组，按照存储顺序排序
 */
-(NSArray*)getArray;

/**
 根据key获得值
 @param key 存储的键
 @return key对应的数据
 */
-(id)valueForKey:(NSString*)key;

/**
 存储key对应的值
 @param value 要存储的数据
 @param key 对于数据的key
 */
-(void)setValue:(id)value forKey:(NSString *)key;

/**
 删除所有存储的数据
 */
-(void)removeAllObjects;

/**
 根据key删除数据
 */
-(void)removeObjectForKey:(NSString*)key;

/**
 根据key数组删除多个数据
 */
-(void)removeObjectsForKeys:(NSArray*)keys;

@end
