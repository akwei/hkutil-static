//
//  NSMutableDictionary+HKEx.m
//  hkutil-static
//
//  Created by akwei on 13-10-26.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "NSMutableDictionary+HKEx.h"

@implementation NSMutableDictionary (HKEx)

-(void)setInteger:(NSInteger)value forKey:(NSString *)key{
    [self setValue:[NSNumber numberWithInteger:value] forKey:key];
}

-(void)setUnsignedInteger:(NSUInteger)value forKey:(NSString *)key{
    [self setValue:[NSNumber numberWithUnsignedInteger:value] forKey:key];
}

-(void)setLongLong:(long long)value forKey:(NSString *)key{
    [self setValue:[NSNumber numberWithLongLong:value] forKey:key];
}

-(void)setUnsignedLongLong:(unsigned long long)value forKey:(NSString *)key{
    [self setValue:[NSNumber numberWithUnsignedLongLong:value] forKey:key];
}

-(void)setBool:(BOOL)value forKey:(NSString *)key{
    [self setValue:[NSNumber numberWithBool:value] forKey:key];
}

-(void)setDouble:(double)value forKey:(NSString *)key{
    [self setValue:[NSNumber numberWithDouble:value] forKey:key];
}

@end
