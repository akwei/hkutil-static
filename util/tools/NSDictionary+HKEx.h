//
//  NSDictionary+HKEx.h
//  hkutil-static
//
//  Created by akwei on 13-10-26.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 返回数字信息，如果不存在相应的key，就返回0,布尔类型返回NO
 */
@interface NSDictionary (HKEx)
-(NSInteger)integerValueForKey:(NSString*)key;
-(NSUInteger)unsignedIntegerValueForKey:(NSString*)key;
-(long long)longLongValueForKey:(NSString*)key;
-(unsigned long long)unsignedLongLongValueForKey:(NSString*)key;
-(BOOL)boolValueForKey:(NSString*)key;
-(double)doubleValueForKey:(NSString*)key;
@end
