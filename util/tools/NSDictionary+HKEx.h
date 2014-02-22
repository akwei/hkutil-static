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
-(NSInteger)integerValueForKey:(NSString*)key def:(NSInteger)defValue;
-(long long)longLongValueForKey:(NSString*)key;
-(long long)longLongValueForKey:(NSString*)key def:(long long)defValue;
-(unsigned long long)unsignedLongLongValueForKey:(NSString*)key;
-(unsigned long long)unsignedLongLongValueForKey:(NSString*)key def:(unsigned long long)defValue;
-(BOOL)boolValueForKey:(NSString*)key;
-(BOOL)boolValueForKey:(NSString*)key def:(BOOL)defValue;
-(double)doubleValueForKey:(NSString*)key;
-(double)doubleValueForKey:(NSString*)key def:(double)defValue;
@end
