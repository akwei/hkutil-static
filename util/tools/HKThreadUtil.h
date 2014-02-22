//
//  HKThreadUtil.h
//  hkutil2
//
//  Created by akwei on 13-4-22.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

/*
 线程工具类，使用GCD解决异步多线程问题
 */

#import <Foundation/Foundation.h>

@interface HKThreadUtil : NSObject
@property(nonatomic,assign)dispatch_queue_t asyncQueue;

@property(nonatomic,assign)BOOL enableTestMode;
//单例
+(HKThreadUtil*)shareInstance;

/**
 开启单元测试模式，如果开启，将对程序中的异步都进行同步化处理。默认不开启
 @param enable YES:开启
 */
+(void)setEnableTestMode:(BOOL)enable;

/**
 是否开启了单元测试模式
 @returns YES:开启
 */
+(BOOL)isEnableTestMode;

/**
 异步提交到并发队列中
 */
-(void)async:(void (^)(void))block;

/**
 到主线程中执行
 */
-(void)toMain:(void(^)(void))block;

/**
 并发线程组的操作，当一组线程执行完毕，才能继续下面的操作
 @param block 要执行的block
 @param group 组
 */
-(void)async:(void (^)(void))block toGroup:(dispatch_group_t)group;

/**
 添加一组异步执行的blok到特定的组中，此方法为阻塞方法，只有执行完所有线程之后，才能继续运行
 @param blockArray 需要异步执行的block 形式: (NSString* (^)(void))block
 @param group 线程组
 */
-(void)asyncWithBlockArrayToGroup:(NSArray*)blockArray;

@end
