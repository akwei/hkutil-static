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
    id obj = [self valueForKey:key];
    if (obj) {
        return [obj integerValue];
    }
    return 0;
}

-(NSUInteger)unsignedIntegerValueForKey:(NSString *)key{
    id obj = [self valueForKey:key];
    if (obj) {
        return [obj unsignedIntegerValue];
    }
    return 0;
}

-(long long)longLongValueForKey:(NSString *)key{
    id obj = [self valueForKey:key];
    if (obj) {
        return [obj longLongValue];
    }
    return 0;
}

-(unsigned long long)unsignedLongLongValueForKey:(NSString *)key{
    id obj = [self valueForKey:key];
    if (obj) {
        return [obj unsignedLongLongValue];
    }
    return 0;
}

-(BOOL)boolValueForKey:(NSString *)key{
    id obj = [self valueForKey:key];
    if (obj) {
        return [obj boolValue];
    }
    return NO;
}

-(double)doubleValueForKey:(NSString *)key{
    id obj = [self valueForKey:key];
    if (obj) {
        return [obj doubleValue];
    }
    return 0;
}

@end
