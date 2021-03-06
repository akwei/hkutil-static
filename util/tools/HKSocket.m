//
//  HKSocket.m
//  huoku_starprinter_arc
//
//  Created by akwei on 13-6-30.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKSocket.h"
#import "GCDAsyncSocket.h"

@implementation HKSocketConnectionException
@end

@implementation HKSocketException
@end

@implementation HKSocketInterruptException
@end

@interface HKSocket ()
@property(nonatomic,strong)GCDAsyncSocket* socket;
@property(nonatomic,strong)NSCondition* cond;
@property(nonatomic,assign)BOOL done;
@property(nonatomic,strong)NSMutableData* receivedData;
@property(nonatomic,strong)NSError* error;
@property(nonatomic,assign)BOOL isReadTimeout;
@property(nonatomic,assign)BOOL isWriteTimeout;
@property(nonatomic,strong)NSData* endData;
@end

@implementation HKSocket{
    dispatch_queue_t _queue;
}

-(id)initWithHost:(NSString *)host port:(NSUInteger)port timeout:(NSTimeInterval)timeout{
    self = [super init];
    if (self) {
        self.host = host;
        self.port = port;
        self.timeout = timeout;
        NSString* queueName = [NSString stringWithFormat:@"HKSocket_queueName_%@",[self description]];
        _queue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
        self.done = NO;
        self.cond = [[NSCondition alloc] init];
        self.writeTimeout = timeout;
        self.readTimeout = timeout;
        self.debug = NO;
        self.endData = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

-(id)init{
    NSLog(@"Plase invoke -(id)initWithHost:(NSString *)host port:(NSUInteger)port");
    return nil;
}

-(void)workWithBlock:(void (^)(void))block{
    [self.cond lock];
    @try {
        self.error = nil;
        self.isWriteTimeout = NO;
        self.isReadTimeout = NO;
        self.done = NO;
        block();
        while (!self.done) {
            [self.cond wait];
        }
        [self checkException];
    }
    @finally {
        [self.cond unlock];
    }
}

-(void)checkException{
    if (self.isReadTimeout) {
        @throw [HKSocketException exceptionWithName:@"timeout" reason:@"read timeout" userInfo:nil];
    }
    else if (self.isWriteTimeout) {
        @throw [HKSocketException exceptionWithName:@"timeout" reason:@"write timeout" userInfo:nil];
    }
    if (self.error) {
        @throw [HKSocketException exceptionWithName:@"printer io err" reason:@"read/write err" userInfo:nil];
    }
}

-(void)writeData:(NSData*)data{
    HKSocket* me = self;
    [self workWithBlock:^{
        [me.socket writeData:data withTimeout:me.writeTimeout tag:1];
    }];
}

-(void)writeData:(NSData *)data blockSize:(NSUInteger)blockSize{
    HKSocket* me = self;
    [self workWithBlock:^{
        NSUInteger remain = [data length];
        NSUInteger offset = 0;
        do {
            NSUInteger writeSize = 0;
            if (blockSize <= remain) {
                writeSize = blockSize;
            }
            else{
                writeSize = remain;
            }
            remain = remain - writeSize;
            NSRange range = NSMakeRange(offset, writeSize);
            NSData* blockData = [data subdataWithRange:range];
            [me.socket writeData:blockData withTimeout:me.timeout tag:1];
            if (remain == 0) {
                break;
            }
            offset = offset + writeSize;
        } while (true);
    }];
}

-(NSData *)readData{
    HKSocket* me = self;
    me.receivedData = nil;
    me.receivedData = [[NSMutableData alloc] init];
    [me workWithBlock:^{
        [me.socket readDataWithTimeout:me.readTimeout buffer:me.receivedData bufferOffset:0 tag:2];
        
    }];
    return self.receivedData;
}

-(NSData *)readDataWithLength:(NSUInteger)length{
    HKSocket* me = self;
    me.receivedData = nil;
    me.receivedData = [[NSMutableData alloc] init];
    [me workWithBlock:^{
        [me.socket readDataToLength:length withTimeout:me.readTimeout buffer:me.receivedData bufferOffset:0 tag:2];
    }];
    return self.receivedData;
}

-(NSData *)readLineData{
    HKSocket* me = self;
    me.receivedData = nil;
    me.receivedData = [[NSMutableData alloc] init];
    [me workWithBlock:^{
        [me.socket readDataToData:me.endData withTimeout:me.readTimeout buffer:me.receivedData bufferOffset:0 tag:2];
        
    }];
    return self.receivedData;
}

-(void)afterResponse{
    [self.cond lock];
    self.error = nil;
    self.done = YES;
    [self.cond signal];
    [self.cond unlock];
}

#pragma mark - GCDAsyncSocket delegate

//-(NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length{
//    NSLog(@"shouldTimeoutReadWithTag %lx",tag);
//    return self.timeout;
//}
//
//-(NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length{
//    NSLog(@"shouldTimeoutWriteWithTag %lx",tag);
//    return self.timeout;
//}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port{
    if (self.debug) {
        NSLog(@"connect to %@:%i",host,port);
    }
    [self.cond lock];
    self.error = nil;
    self.done = YES;
    [self.cond signal];
    [self.cond unlock];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    if (self.debug) {
        NSLog(@"data for tag %llu sent",(unsigned long long)tag);
    }
    [self afterResponse];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    if (self.debug) {
        NSLog(@"data for tag %llu didRead",(unsigned long long)tag);
    }
    [self afterResponse];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    [self.cond lock];
    if (self.debug) {
        if (err) {
            NSLog(@"socket disconnect ok:%@",[err description]);
        }
        else{
            NSLog(@"socket disconnect ok");
        }
    }
    self.done = YES;
    self.error = err;
    [self.cond signal];
    [self.cond unlock];
}

#pragma mark - open and close

-(void)open{
    [self.cond lock];
    if (!self.host || self.port<=0) {
        @try {
            @throw [HKSocketConnectionException exceptionWithName:@"connect error" reason:@"must set host and port" userInfo:nil];
        }
        @finally {
            [self.cond unlock];
        }
    }
    self.done = NO;
    if (self.socket) {
        self.socket = nil;
    }
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_queue];
    NSError *err = nil;
    NSException* ex;
    @try {
        if (self.debug) {
            NSLog(@"try to connect to host:%@ port:%llu",self.host,(unsigned long long)self.port);
        }
        if (![self.socket connectToHost:self.host onPort:self.port withTimeout:self.timeout error:&err]) // Asynchronous!
        {
            // If there was an error, it's likely something like "already connected" or "no delegate set"
            NSString* name = [NSString stringWithFormat:@"connect to [%@:%llu] error",self.host,(unsigned long long)self.port];
            NSString* reason = [NSString stringWithFormat:@"%@ | %@",err.description,name];
            ex = [HKSocketConnectionException exceptionWithName:name reason:reason userInfo:nil];
            name = nil;
            reason = nil;
            @throw ex;
        }
        while (!self.done) {
            [self.cond wait];
        }
        if (self.error) {
            NSString* name = [NSString stringWithFormat:@"connect to [%@:%llu] error",self.host,(unsigned long long)self.port];
            NSString* reason = [NSString stringWithFormat:@"%@ | %@",self.error.description,name];
            ex = [HKSocketConnectionException exceptionWithName:name reason:reason userInfo:nil];
            name = nil;
            reason = nil;
            @throw ex;
        }
    }
    @catch (NSException* exception) {
        self.socket = nil;
        @throw exception;
    }
    @finally {
        [self.cond unlock];
    }
}

-(void)close{
    [self.cond lock];
    self.done = NO;
    if (self.socket && ![self.socket isDisconnected]) {
        [self.socket disconnect];
        while (!self.done) {
            [self.cond wait];
        }
    }
    self.socket = nil;
    [self.cond unlock];
}

-(void)dealloc{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0 // iOS 5.X or earlier
    dispatch_release(_queue);
#endif
}

@end
