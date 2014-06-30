//
//  HKNFCReader.m
//  hkutil-static
//
//  Created by akwei on 5/23/14.
//  Copyright (c) 2014 huoku. All rights reserved.
//

#import "HKNFCReader.h"
#import "HKSocket.h"
#import "HKAsyncSocket.h"
#import "HKDataUtil.h"

@interface HKNFCReader ()
@property(nonatomic,strong)HKSocket* socket;
@property(nonatomic,strong)HKAsyncSocket* asyncSocket;
@end

@implementation HKNFCReader

-(instancetype)initWithHost:(NSString*)host
                       port:(NSUInteger)port
                    timeout:(NSTimeInterval)timeout{
    self = [super init];
    if (self) {
        __weak HKNFCReader* me = self;
        self.socket = [[HKSocket alloc] initWithHost:host port:port timeout:timeout];
        self.socket.debug = YES;
        self.asyncSocket = [[HKAsyncSocket alloc] initWithHost:host port:port timeout:timeout];
        self.asyncSocket.debug = YES;
        self.readTimeout = -1;
        [self.asyncSocket setSuccessBlock:^(long tag, NSDictionary *info) {
            switch (tag) {
                case 0:
                    //open socket and can write command
                    if (me.openedBlock) {
                        me.openedBlock();
                    }
                    break;
                case 1:{
                    //close socket
                    if (me.closedBlock) {
                        me.closedBlock();
                    }
                    break;
                }
                case 2:{
                    //write
                    [me.asyncSocket readLineDataWithTag:3];
                    break;
                }
                case 3:{
                    //read
                    NSData* data = [info valueForKey:@"data"];
                    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSString* uid = nil;
                    //nfcuid:
                    if ([str length] > 7) {
                        uid = [HKDataUtil trim:[str substringFromIndex:7]];
                        NSInteger remain = 10 - [uid length];
                        NSMutableString* buf = [[NSMutableString alloc] init];
                        if (remain > 0) {
                            for (int i = 0; i < remain; i++) {
                                [buf appendString:@"0"];
                            }
                            [buf appendString:uid];
                            uid = [buf copy];
                        }
                    }
                    if (me.getNFCBlock) {
                        me.getNFCBlock(uid);
                    }
                    break;
                }
                default:
                    break;
            }
        }];
    }
    return self;
}

-(void)setFailBlock:(void (^)(NSError *))failBlock{
    _failBlock = failBlock;
    self.asyncSocket.failBlock = _failBlock;
}

-(void)setReadTimeout:(NSTimeInterval)readTimeout{
    _readTimeout = readTimeout;
    _asyncSocket.readTimeout = readTimeout;
    
}

-(void)setWriteTimeout:(NSTimeInterval)writeTimeout{
    _writeTimeout = writeTimeout;
    _asyncSocket.writeTimeout = writeTimeout;
}

-(BOOL)test{
    @try {
        [self.socket open];
        [self.socket close];
        return YES;
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally{
        [self.socket close];
    }
}

-(void)open{
    [self.asyncSocket open];
}

-(BOOL)isConnected{
    return [self.asyncSocket isConnected];
}

-(void)swipe{
    [self.asyncSocket writeData:[@"swipe\r\n" dataUsingEncoding:NSUTF8StringEncoding] tag:2];
}

-(void)stop{
    [self.asyncSocket close];
}

-(void)dealloc{
    [self.socket close];
    [self.asyncSocket close];
}

@end
