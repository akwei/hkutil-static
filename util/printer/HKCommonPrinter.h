//
//  HKCommonPrinter.h
//  hkutil-static
//
//  Created by akwei on 13-9-30.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKPrinterCfg.h"

@interface HKCommonPrinter : NSObject
@property(nonatomic,copy)NSString* host;
@property(nonatomic,assign)NSUInteger port;
@property(nonatomic,strong,readonly)NSMutableData* commandData;
@property(nonatomic,assign)NSInteger timeout;//超时时间，单位:毫秒

-(id)initWithHost:(NSString*)host port:(NSUInteger)port;

/**
 添加命令
 @param data 二进制数据
 */
-(void)addCommand:(NSData*)data;

/**
 添加命令
 @param bytes 字节数据
 @param 字节数据长度
 */
- (void)addBytesCommand:(const void *)bytes length:(NSUInteger)length;

/**
 添加文本命令
 @param text 字符数据
 */
-(void)addTextCommand:(NSString*)text;

/**
 连接打印机
 */
-(void)connect;

/**
 按照默认块大小发送数据
 */
-(void)send;

/**
 发送指令到打印机,blockSize 指定的每次发送的块大小，单位为字节
 @param blockSize 指定每次发送的块大小
 */
-(void)sendWithBlockSize:(NSUInteger)blockSize;

/**
 读取响应数据
 @return 响应数据
 */
-(NSData*)read;

/**
 与打印机断开连接
 */
-(void)disconnect;

/**
 直接发送现有的所有数据，自动打开连接和关闭连接.blockSize 指定的每次发送的块大小，单位为字节
 @param blockSize 指定每次发送的块大小
 */
-(void)executeWithBlockSize:(NSUInteger)blockSize;

@end
