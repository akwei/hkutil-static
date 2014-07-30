//
//  HKAsyncSocket.m
//  hkutil-static
//
//  Created by akwei on 6/19/14.
//  Copyright (c) 2014 huoku. All rights reserved.
//

#import "HKAsyncSocket.h"
#import "GCDAsyncSocket.h"

@interface HKAsyncSocket ()
@property(nonatomic,strong)GCDAsyncSocket* socket;
@property(nonatomic,strong)NSError* error;
@property(nonatomic,strong)NSData* endData;
@end

@implementation HKAsyncSocket{
    dispatch_queue_t _queue;
}

-(id)initWithHost:(NSString *)host port:(NSUInteger)port timeout:(NSTimeInterval)timeout{
    self = [self initWithHost:host port:port timeout:timeout successBlock:nil failBlock:nil];
    return self;
}

-(id)initWithHost:(NSString *)host
             port:(NSUInteger)port
          timeout:(NSTimeInterval)timeout
     successBlock:(void (^)(long , NSDictionary *))successBlock
        failBlock:(void (^)(NSError *))failBlock{
    self = [super init];
    if (self) {
        self.host = host;
        self.port = port;
        self.timeout = timeout;
        NSString* queueName = [NSString stringWithFormat:@"HKAsyncSocket_queueName_%@",[self description]];
        _queue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
        self.writeTimeout = timeout;
        self.readTimeout = timeout;
        self.debug = NO;
        self.endData = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        self.successBlock = successBlock;
        self.failBlock = failBlock;
    }
    return self;
}

-(void)dealloc{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0 // iOS 5.X or earlier
    dispatch_release(_queue);
#endif
}

-(BOOL)open{
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_queue];
    NSError* err = nil;
    if (![self.socket connectToHost:self.host onPort:self.port withTimeout:self.timeout error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"connect to [%@:%llu] error:%@",self.host,(unsigned long long)self.port,err.description);
        return NO;
    }
    return YES;
}

-(BOOL)isConnected{
    return [self.socket isConnected];
}

-(void)readDataWithTag:(long)tag{
    NSMutableData* receivedData = [[NSMutableData alloc] init];
    [self.socket readDataWithTimeout:self.readTimeout buffer:receivedData bufferOffset:0 tag:tag];
}

-(void)readDataWithLength:(NSUInteger)length tag:(long)tag{
    NSMutableData* receivedData = [[NSMutableData alloc] init];
    [self.socket readDataToLength:length withTimeout:self.readTimeout buffer:receivedData bufferOffset:0 tag:tag];
}

-(void)readLineDataWithTag:(long)tag{
    NSMutableData* receivedData = [[NSMutableData alloc] init];
    [self.socket readDataToData:self.endData withTimeout:self.readTimeout buffer:receivedData bufferOffset:0 tag:tag];
}

-(void)writeData:(NSData *)data tag:(long)tag{
    [self.socket writeData:data withTimeout:self.writeTimeout tag:tag];
}

-(void)writeData:(NSData *)data blockSize:(NSUInteger)blockSize tag:(long)tag{
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
        [self.socket writeData:blockData withTimeout:self.writeTimeout tag:tag];
        if (remain == 0) {
            break;
        }
        offset = offset + writeSize;
    } while (true);
}

-(void)close{
    if (self.socket && ![self.socket isDisconnected]) {
        [self.socket disconnect];
    }
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
        NSLog(@"connect success to %@:%i",host,port);
    }
    if (self.successBlock) {
        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        self.successBlock(0,info);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    if (self.debug) {
        NSLog(@"data for tag %llu sent",(unsigned long long)tag);
    }
    if (self.successBlock) {
        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        self.successBlock(tag,info);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    if (self.debug) {
        NSLog(@"data for tag %llu didRead",(unsigned long long)tag);
    }
    if (self.successBlock) {
        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        [info setValue:data forKey:@"data"];
        self.successBlock(tag,info);
    }
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    if (self.debug) {
        if (err) {
            NSLog(@"socket disconnect ok:%@",[err description]);
        }
        else{
            NSLog(@"socket disconnect ok");
        }
    }
    self.error = err;
    if (self.error) {
        if (self.failBlock) {
            self.failBlock(self.error);
        }
    }
    else{
        if (self.successBlock) {
            NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
            self.successBlock(1,info);
        }
    }
}

@end
