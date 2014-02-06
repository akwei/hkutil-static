//
//  HKCommonPrinter.m
//  hkutil-static
//
//  Created by akwei on 13-9-30.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKCommonPrinter.h"
#import "HKSocket.h"


@implementation HKCommonPrinter{
    HKSocket* _socket;
}

-(id)initWithHost:(NSString *)host port:(NSUInteger)port{
    self = [super init];
    if (self) {
        self.host = host;
        self.port = port;
        self.timeout = 5;
        _commandData = [[NSMutableData alloc] init];
    }
    return self;
}

-(void)addCommand:(NSData *)data{
    [self.commandData appendData:data];
}

-(void)addBytesCommand:(const void *)bytes length:(NSUInteger)length{
    [self.commandData appendBytes:bytes length:length];
}

-(void)addTextCommand:(NSString *)text{
    NSStringEncoding gbk=CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *textData = [text dataUsingEncoding:gbk];
    [self addCommand:textData];
}

-(void)connect{
    _socket = [[HKSocket alloc] initWithHost:self.host port:self.port timeout:self.timeout];
    @try {
        [_socket open];
    }
    @catch (HKSocketConnectionException* e) {
        [_socket close];
        _socket = nil;
        HKPrinterConnectException* ex = (HKPrinterConnectException*)[HKPrinterConnectException exceptionWithName:@"connect printer err" reason:e.reason userInfo:nil];
        @throw ex;
    }
}

-(void)send{
    [self sendWithBlockSize:16];
}

-(void)sendWithBlockSize:(NSUInteger)blockSize{
    @try {
        [_socket writeData:self.commandData blockSize:blockSize];
        _commandData = nil;
        _commandData = [[NSMutableData alloc] init];
    }
    @catch (HKSocketException* e) {
        HKPrinterException* ex = (HKPrinterException*)[HKPrinterException exceptionWithName:@"printer io err" reason:e.reason userInfo:nil];
        @throw ex;
    }
}

-(NSData *)read{
    @try {
        return [_socket readData];
    }
    @catch (HKSocketException *e) {
        HKPrinterException* ex = (HKPrinterException*)[HKPrinterException exceptionWithName:@"printer io err" reason:e.reason userInfo:nil];
        @throw ex;
    }
}

-(void)disconnect{
    [_socket close];
    [NSThread sleepForTimeInterval:.5];
    _socket = nil;
}

-(void)executeWithBlockSize:(NSUInteger)blockSize{
    @try {
        [self connect];
        [self sendWithBlockSize:blockSize];
    }
    @finally {
        [self disconnect];
    }
}

@end
