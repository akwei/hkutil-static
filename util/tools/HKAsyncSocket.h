//
//  HKAsyncSocket.h
//  hkutil-static
//
//  Created by akwei on 6/19/14.
//  Copyright (c) 2014 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKAsyncSocket : NSObject
@property(nonatomic,copy)NSString* host;
@property(nonatomic,assign)NSUInteger port;
@property(nonatomic,assign)NSTimeInterval timeout;//超时时间，单位:秒
@property(nonatomic,assign)NSTimeInterval writeTimeout;
@property(nonatomic,assign)NSTimeInterval readTimeout;
@property(nonatomic,assign)BOOL debug;
@property(nonatomic,strong)void (^successBlock) (long tag , NSDictionary* info);
@property(nonatomic,strong)void (^failBlock) (NSError* error);

-(id)initWithHost:(NSString*)host
             port:(NSUInteger)port
          timeout:(NSTimeInterval)timeout;

-(id)initWithHost:(NSString*)host
             port:(NSUInteger)port
          timeout:(NSTimeInterval)timeout
     successBlock:(void (^)(long tag , NSDictionary* info))successBlock
        failBlock:(void (^)(NSError* error))failBlock;

/**
 打开连接
 @param successBlock 连接成功的block
 @param failBlock 连接失败的block
 @return NO: error connect
 */
-(BOOL)open;

-(BOOL)isConnected;

/*
 写入数据
 @param data 数据
 @param successBlock 写入成功的block
 @param failBlock 写入失败的block
 */
-(void)writeData:(NSData*)data tag:(long)tag;
/*
 写入数据
 @param data 数据
 @param blockSize 每次发送的字节数量
 */
-(void)writeData:(NSData*)data blockSize:(NSUInteger)blockSize tag:(long)tag;

/**
 读取数据
 */
-(void)readDataWithTag:(long)tag;

/**
 读取制定长度的数据
 @param length 字节长度
 */
-(void)readDataWithLength:(NSUInteger)length tag:(long)tag;

/**
 读取数据
 @param blockSize 每次发送的字节数量
 */
-(void)readLineDataWithTag:(long)tag;

/**
 关闭连接
 @param successBlock 关闭成功的block
 @param failBlock 关闭失败的block
 */
-(void)close;
@end
