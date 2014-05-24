//
//  HKNFCReader.m
//  hkutil-static
//
//  Created by akwei on 5/23/14.
//  Copyright (c) 2014 huoku. All rights reserved.
//

#import "HKNFCReader.h"
#import "HKSocket.h"

@interface HKNFCReader ()
@property(nonatomic,strong)HKSocket* socket;
@property(nonatomic,strong)void (^beginSwipeBlock)(void);
@property(nonatomic,strong)void (^onGetData)(NSString* uid);
@end

@implementation HKNFCReader

-(instancetype)initWithHost:(NSString*)host
                       port:(NSUInteger)port
                    timeout:(NSTimeInterval)timeout
            beginSwipeBlock:(void (^)(void))beginSwipeBlock
                  onGetData:(void (^)(NSString* uid))onGetData{
    self = [super init];
    if (self) {
        self.socket = [[HKSocket alloc] initWithHost:host port:port timeout:timeout];
        self.socket.debug = YES;
        self.beginSwipeBlock = beginSwipeBlock;
        self.onGetData = onGetData;
    }
    return self;
}

-(void)setReadTimeout:(NSTimeInterval)readTimeout{
    _readTimeout = readTimeout;
    _socket.readTimeout = readTimeout;
}

-(void)setWriteTimeout:(NSTimeInterval)writeTimeout{
    _writeTimeout = writeTimeout;
    _socket.writeTimeout = writeTimeout;
}

-(void)open{
    [self.socket open];
}

-(void)swipe{
    NSString* cmd = @"swipe\r\n";
    [self.socket writeData:[cmd dataUsingEncoding:NSUTF8StringEncoding]];
    if (self.beginSwipeBlock) {
        self.beginSwipeBlock();
    }
    NSData* data = [self.socket readLineData];
    NSString* uid = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (self.onGetData) {
        self.onGetData(uid);
    }
}

-(void)close{
    [self.socket close];
}

@end