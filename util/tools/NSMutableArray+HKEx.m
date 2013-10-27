//
//  NSMutableArray+HKEx.m
//  hkutil-static
//
//  Created by akwei on 13-10-27.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "NSMutableArray+HKEx.h"

@implementation NSMutableArray (HKEx)

-(void)addInteger:(NSInteger)value{
    [self addObject:[NSNumber numberWithInteger:value]];
}

-(void)addUnsignedInteger:(NSUInteger)value{
    [self addObject:[NSNumber numberWithUnsignedInteger:value]];
}

-(void)addDouble:(double)value{
    [self addObject:[NSNumber numberWithDouble:value]];
}

-(void)addBool:(BOOL)value{
    [self addObject:[NSNumber numberWithBool:value]];
}

-(void)addLongLong:(long long)value{
    [self addObject:[NSNumber numberWithLongLong:value]];
}

-(void)addUnsignedLongLong:(unsigned long long)value{
    [self addObject:[NSNumber numberWithUnsignedLongLong:value]];
}

-(void)insertInteger:(NSInteger)value atIndex:(NSUInteger)index{
    [self insertObject:[NSNumber numberWithInteger:value] atIndex:index];
}

-(void)insertUnsignedInteger:(NSUInteger)value atIndex:(NSUInteger)index{
    [self insertObject:[NSNumber numberWithUnsignedInteger:value] atIndex:index];
}

-(void)insertDouble:(double)value atIndex:(NSUInteger)index{
    [self insertObject:[NSNumber numberWithDouble:value] atIndex:index];
}

-(void)insertBool:(BOOL)value atIndex:(NSUInteger)index{
    [self insertObject:[NSNumber numberWithBool:value] atIndex:index];
}

-(void)insertLongLong:(long long)value atIndex:(NSUInteger)index{
    [self insertObject:[NSNumber numberWithLongLong:value] atIndex:index];
}

-(void)insertUnsignedLongLong:(unsigned long long)value atIndex:(NSUInteger)index{
    [self insertObject:[NSNumber numberWithUnsignedLongLong:value] atIndex:index];
}

@end
