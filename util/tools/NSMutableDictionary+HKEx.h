//
//  NSMutableDictionary+HKEx.h
//  hkutil-static
//
//  Created by akwei on 13-10-26.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (HKEx)
-(void)setInteger:(NSInteger)value forKey:(NSString *)key;
-(void)setUnsignedInteger:(NSUInteger)value forKey:(NSString *)key;
-(void)setLongLong:(long long)value forKey:(NSString *)key;
-(void)setUnsignedLongLong:(unsigned long long)value forKey:(NSString *)key;
-(void)setBool:(BOOL)value forKey:(NSString *)key;
-(void)setDouble:(double)value forKey:(NSString *)key;
@end
