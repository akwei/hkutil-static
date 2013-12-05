//
//  NSData+HKEx.h
//  hkutil-static
//
//  Created by akwei on 13-12-4.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (HKEx)

/**
 获得指定下标的字节
 @param byteIndex 字节下标 >=0 and <=data.length
 */
-(char)getByte:(NSUInteger)byteIndex;

/**
 获得某个字节的固定位数据，结果用字节表示。
 @param byteIndex 第byten个字节。 byteIndex>=0 and byteIndex <= data.length - 1
 @param bitIndex 第bitIndex位。bitIndex>=0 and bitIndex<=7
 @return 数据字节表示。如果n超出长度范围，返回0
 */
-(int)getByte:(NSUInteger)byteIndex bitIndex:(NSUInteger)bitIndex;

@end
