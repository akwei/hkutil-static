//
//  NSData+HKEx.m
//  hkutil-static
//
//  Created by akwei on 13-12-4.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "NSData+HKEx.h"

@implementation NSData (HKEx)

-(char)getByte:(NSUInteger)byteIndex{
    const char* bytes = self.bytes;
    return bytes[byteIndex];
}

-(int)getByte:(NSUInteger)byteIndex bitIndex:(NSUInteger)bitIndex{
    const char* bytes = self.bytes;
    char byte = bytes[byteIndex];
    return (byte >> bitIndex) & 1;
}


@end
