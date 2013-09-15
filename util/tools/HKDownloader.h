//
//  HKDownloader.h
//  hkutil2
//
//  Created by akwei on 13-4-22.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

/*
 多线程url数据加载,支持并发，支持block方式回调
 使用方式:
 HKDownloaderMgr *mgr = [[HKDownloaderMgr alloc] init];
 [mgr downloadWithUrl:(NSString*)url callbackHandler:(HKCallbackHandler*)callbackHandler timeout:(NSTimeInterval)timeout];
 */

#import <Foundation/Foundation.h>

@interface HKCallbackHandler : NSObject
@property(nonatomic,strong)void (^onFinishBlock)(NSString* url,NSData* data,NSInteger statusCode);
@property(nonatomic,strong)void (^onErrorBlock)(NSString* url,NSError* data,NSInteger statusCode);
@end


//数据下载器
@interface HKDownloader : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
@property(nonatomic,copy)NSString* url;
@property(nonatomic,strong)NSMutableData* data;
@property(nonatomic,strong)NSHTTPURLResponse* httpResponse;
@property(nonatomic,strong)void (^onFinishBlock)(NSData* url,NSInteger statusCode);
@property(nonatomic,strong)void (^onErrorBlock)(NSError* url,NSInteger statusCode);
@property(nonatomic,assign)NSTimeInterval timeout;

-(void)start;

@end

@interface HKDownloaderMgr : NSObject
-(void)downloadWithUrl:(NSString*)url callbackHandler:(HKCallbackHandler*)callbackHandler timeout:(NSTimeInterval)timeout;
@end



