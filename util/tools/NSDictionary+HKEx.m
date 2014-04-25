//
//  NSDictionary+HKEx.m
//  hkutil-static
//
//  Created by akwei on 13-10-26.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "NSDictionary+HKEx.h"

@implementation NSDictionary (HKEx)

-(NSInteger)integerValueForKey:(NSString *)key{
    return [self integerValueForKey:key def:0];
}

-(NSInteger)integerValueForKey:(NSString *)key def:(NSInteger)defValue{
    id obj = [self valueForKey:key];
    if ([obj isKindOfClass:[NSNull class]]) {
        return defValue;
    }
    if (obj) {
        return [obj integerValue];
    }
    return defValue;
}

-(NSInteger)unsignedIntegerValueForKey:(NSString *)key{
    return [self unsignedIntegerValueForKey:key def:0];
}

-(NSInteger)unsignedIntegerValueForKey:(NSString *)key def:(NSUInteger)defValue{
    id obj = [self valueForKey:key];
    if ([obj isKindOfClass:[NSNull class]]) {
        return defValue;
    }
    if (obj) {
        return [obj integerValue];
    }
    return defValue;
}

-(long long)longLongValueForKey:(NSString *)key{
    return [self longLongValueForKey:key def:0];
}

-(long long)longLongValueForKey:(NSString *)key def:(long long)defValue{
    id obj = [self valueForKey:key];
    if ([obj isKindOfClass:[NSNull class]]) {
        return defValue;
    }
    if (obj) {
        return [obj longLongValue];
    }
    return defValue;
}

-(unsigned long long)unsignedLongLongValueForKey:(NSString *)key{
    return [self unsignedLongLongValueForKey:key def:0];
}

-(unsigned long long)unsignedLongLongValueForKey:(NSString *)key def:(unsigned long long)defValue{
    id obj = [self valueForKey:key];
    if ([obj isKindOfClass:[NSNull class]]) {
        return defValue;
    }
    if (obj) {
        return [obj unsignedLongLongValue];
    }
    return defValue;
}

-(BOOL)boolValueForKey:(NSString *)key{
    return [self boolValueForKey:key def:NO];
}

-(BOOL)boolValueForKey:(NSString *)key def:(BOOL)defValue{
    id obj = [self valueForKey:key];
    if ([obj isKindOfClass:[NSNull class]]) {
        return defValue;
    }
    if (obj) {
        return [obj boolValue];
    }
    return defValue;
}

-(double)doubleValueForKey:(NSString *)key{
    return [self doubleValueForKey:key def:0];
}

-(double)doubleValueForKey:(NSString *)key def:(double)defValue{
    id obj = [self valueForKey:key];
    if ([obj isKindOfClass:[NSNull class]]) {
        return defValue;
    }
    if (obj) {
        return [obj doubleValue];
    }
    return defValue;
}

@end
