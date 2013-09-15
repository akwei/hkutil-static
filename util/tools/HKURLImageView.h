//
//  HKURLImageView.h
//  hkutil2
//
//  Created by akwei on 13-4-22.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

/*
 从网络异步加载图片的View,支持并发加载.如果加载完成可以从缓存中重新加载
 使用方式:
 HKURLImageView* view = [[HKURLImageView alloc] init];
 view.timeout = 30;//超时时间
 [view loadFromUrl:(NSString *)url onErrorBlock:(void (^)(void))onErrorBlock];
 */

#import <UIKit/UIKit.h>

@class HKCache;

@interface HKURLImageView : UIImageView
@property(nonatomic,assign) BOOL isCanShowLoading;
@property(nonatomic,assign)UIActivityIndicatorViewStyle loadingStyle;
@property(nonatomic,assign)NSTimeInterval timeout;

+(void)setGlobalTimeout:(NSTimeInterval)t;
+(NSTimeInterval)getGlobalTimeout;

+(void)setCache:(HKCache*)cache;
/*
 显示图片
 @param url:图片地址
 @param onErrorBlock:当加载图片失败时的回调block
 */
-(void)loadFromUrl:(NSString *)url onErrorBlock:(void (^)(NSError *error))onErrorBlock;
//清除当前显示的图片
-(void)clear;
@end
