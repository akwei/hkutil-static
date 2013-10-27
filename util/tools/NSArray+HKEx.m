//
//  NSArray+HKEx.m
//  hkutil-static
//
//  Created by akwei on 13-10-27.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "NSArray+HKEx.h"

@implementation NSArray (HKEx)

-(NSInteger)integerAtIndex:(NSUInteger)index{
    return [[self objectAtIndex:index] integerValue];
}

-(NSUInteger)unsignedIntegerAtIndex:(NSUInteger)index{
    return [[self objectAtIndex:index] unsignedIntegerValue];
}

-(double)doubleAtIndex:(NSUInteger)index{
    return [[self objectAtIndex:index] doubleValue];
}

-(BOOL)boolAtIndex:(NSUInteger)index{
    return [[self objectAtIndex:index] boolValue];
}

-(long long)longLongAtIndex:(NSUInteger)index{
    return [[self objectAtIndex:index] longLongValue];
}

-(unsigned long long)unsignedLongLongAtIndex:(NSUInteger)index{
    return [[self objectAtIndex:index] unsignedLongLongValue];
}

@end
