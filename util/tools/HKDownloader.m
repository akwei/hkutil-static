//
//  HKDownloader.m
//  hkutil2
//
//  Created by akwei on 13-4-22.
//  Copyright (c) 2013年 huoku. All rights reserved.
//


#import "HKDownloader.h"
#import "CfgHeader.h"

@implementation HKCallbackHandler
@end


//数据下载器
@implementation HKDownloader{
}

-(id)init{
    self=[super init];
    if (self) {
        self.data=[[NSMutableData alloc] initWithCapacity:10240];
        self.timeout = 10;
    }
    return self;
}

-(void)start{
    NSLog(@"download url [%@]",self.url);
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.timeout];
    NSError* error ;
    NSHTTPURLResponse* response;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        if (self.onErrorBlock) {
            self.onErrorBlock(error,response.statusCode);
        }
    }
    else{
        if (self.onFinishBlock) {
            self.onFinishBlock(data,response.statusCode);
        }
    }
}

@end

@implementation HKDownloaderMgr{
    NSMutableDictionary* _downloader_dic;//key:url value:HKDatadownloader
    NSMutableDictionary* _downloader_callbackHandlers_dic;//key:url value:array of callback
    dispatch_queue_t _syncQueue;
    dispatch_queue_t _asyncQueue;
}

-(id)init{
    if (self = [super init]) {
        _downloader_dic = [[NSMutableDictionary alloc] init];
        _downloader_callbackHandlers_dic = [[NSMutableDictionary alloc] init];
        _syncQueue = dispatch_queue_create("HKDataDownloaderMgr_syncQueue", DISPATCH_QUEUE_SERIAL);
        _asyncQueue = dispatch_queue_create("HKDataDownloaderMgr_asyncQueue", DISPATCH_QUEUE_CONCURRENT);
        return self;
    }
    return nil;
}

-(void)dealloc{
#if NEEDS_DISPATCH_RETAIN_RELEASE
	if (_syncQueue) dispatch_release(_syncQueue);
    if (_asyncQueue) dispatch_release(_asyncQueue);
#endif
}

-(void)downloadWithUrl:(NSString*)url callbackHandler:(HKCallbackHandler*)callbackHandler timeout:(NSTimeInterval)timeout{
    NSString* _url = [url copy];
    __weak HKDownloaderMgr* me = self;
    dispatch_sync(_syncQueue, ^{
        NSMutableArray* callbackHandlers = [_downloader_callbackHandlers_dic valueForKey:_url];
        if (!callbackHandlers) {
            callbackHandlers = [[NSMutableArray alloc] init];
            [_downloader_callbackHandlers_dic setValue:callbackHandlers forKey:_url];
        }
        [callbackHandlers addObject:callbackHandler];
        HKDownloader* _downloader = [_downloader_dic valueForKey:_url];
        if (!_downloader) {
            _downloader = [[HKDownloader alloc] init];
            _downloader.url = _url;
            _downloader.timeout = timeout;
            [_downloader setOnFinishBlock:^(NSData *data,NSInteger statusCode) {
                NSMutableArray* callbackHandlers = [_downloader_callbackHandlers_dic valueForKey:_url];
                if (callbackHandlers) {
                    for (HKCallbackHandler* handler in callbackHandlers) {
                        handler.onFinishBlock(_url,data,statusCode);
                    }
                }
                [me clearWithUrl:_url];
            }];
            [_downloader setOnErrorBlock:^(NSError *error,NSInteger statusCode) {
                NSMutableArray* callbackHandlers = [_downloader_callbackHandlers_dic valueForKey:_url];
                if (callbackHandlers) {
                    for (HKCallbackHandler* handler in callbackHandlers) {
                        handler.onErrorBlock(_url,error,statusCode);
                    }
                }
                [me clearWithUrl:_url];
            }];
            [_downloader_dic setValue:_downloader forKey:_url];
            [_downloader start];
        }
    });
}

-(void)clearWithUrl:(NSString*)url{
    [_downloader_callbackHandlers_dic removeObjectForKey:url];
    [_downloader_dic removeObjectForKey:url];
}

@end



