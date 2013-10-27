//
//  NSArray+HKEx.h
//  hkutil-static
//
//  Created by akwei on 13-10-27.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (HKEx)

-(NSInteger)integerAtIndex:(NSUInteger)index;
-(NSUInteger)unsignedIntegerAtIndex:(NSUInteger)index;
-(double)doubleAtIndex:(NSUInteger)index;
-(BOOL)boolAtIndex:(NSUInteger)index;
-(long long)longLongAtIndex:(NSUInteger)index;
-(unsigned long long)unsignedLongLongAtIndex:(NSUInteger)index;

@end
