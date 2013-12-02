//
//  NSString+HKEx.m
//  hkutil-static
//
//  Created by akwei on 13-11-10.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "NSString+HKEx.h"

@implementation NSString (HKEx)

-(NSInteger)indexOf:(NSString *)str{
    NSRange range = [self rangeOfString:str];
    if (range.length > 0) {
        return range.location;
    }
    return -1;
}

@end
