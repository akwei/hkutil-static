//
//  HKSocket.h
//  huoku_starprinter_arc
//  使用CGDAsyncSocket，改变为同步方式工作
//  Created by akwei on 13-6-30.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface HKSocketConnectionException : NSException
@end

@interface HKSocketException : NSException
@end

@interface HKSocketInterruptException : NSException
@end

@interface HKSocket : NSObject<GCDAsyncSocketDelegate>
@property(nonatomic,copy)NSString* host;
@property(nonatomic,assign)NSUInteger port;
@property(nonatomic,assign)NSTimeInterval timeout;//超时时间，单位:秒
@property(nonatomic,assign)NSTimeInterval writeTimeout;
@property(nonatomic,assign)NSTimeInterval readTimeout;
@property(nonatomic,assign)BOOL debug;

-(id)initWithHost:(NSString*)host port:(NSUInteger)port timeout:(NSTimeInterval)timeout;
-(void)open;

/*
 写入数据
 */
-(void)writeData:(NSData*)data;

/*
 写入数据
 */
-(void)writeData:(NSData*)data blockSize:(NSUInteger)blockSize;

/**
 读取数据
 @return 读到的数据
 */
-(NSData*)readData;

/**
 读取数据
 @param length 读取数据的长度
 @return 读到的数据
 */
-(NSData*)readDataWithLength:(NSUInteger)length;

/**
 读取一行数据
 @return 读到的数据
 */
-(NSData*)readLineData;

-(void)close;
@end
