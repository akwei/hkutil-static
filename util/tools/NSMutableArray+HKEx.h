//
//  NSMutableArray+HKEx.h
//  hkutil-static
//
//  Created by akwei on 13-10-27.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (HKEx)

-(void)addInteger:(NSInteger)value;
-(void)addUnsignedInteger:(NSUInteger)value;
-(void)addDouble:(double)value;
-(void)addBool:(BOOL)value;
-(void)addLongLong:(long long)value;
-(void)addUnsignedLongLong:(unsigned long long)value;
-(void)insertInteger:(NSInteger)value atIndex:(NSUInteger)index;
-(void)insertUnsignedInteger:(NSUInteger)value atIndex:(NSUInteger)index;
-(void)insertDouble:(double)value atIndex:(NSUInteger)index;
-(void)insertBool:(BOOL)value atIndex:(NSUInteger)index;
-(void)insertLongLong:(long long)value atIndex:(NSUInteger)index;
-(void)insertUnsignedLongLong:(unsigned long long)value atIndex:(NSUInteger)index;
@end
