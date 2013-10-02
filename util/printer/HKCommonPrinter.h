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
@property(nonatomic,assign)NSInteger timeoutMillis;//超时时间，单位:毫秒

-(id)initWithHost:(NSString*)host port:(NSUInteger)port;

//添加命令
-(void)addCommand:(NSData*)data;

//添加命令
- (void)addBytesCommand:(const void *)bytes length:(NSUInteger)length;

//添加文本命令
-(void)addTextCommand:(NSString*)text;

//连接打印机
-(void)connect;

//发送指令到打印机,blockSize 指定的每次发送的块大小，单位为字节
-(void)sendWithBlockSize:(NSUInteger)blockSize;

//与打印机断开连接
-(void)disconnect;

@end
