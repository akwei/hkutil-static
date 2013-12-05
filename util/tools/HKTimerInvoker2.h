//
//  HKTimerInvoker2.h
//  hkutil-static
//
//  Created by akwei on 13-12-5.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKTimerInvoker2 : NSObject
@property(nonatomic,strong) void (^block)(void);

/*
 任务间隔时间
 */
@property(nonatomic,assign)NSTimeInterval time;

-(id)initWithTime:(NSTimeInterval)time block:(void(^)(void))block;

/**
 任务调用，会启用新的线程进行调用，异步执行，不会在主线程中使用和当前线程
 */
-(void)start;

-(void)startWithDelay:(NSTimeInterval)t;

-(void)stop:(BOOL)waitDone;

//是否设置了停止的信号
-(BOOL)isShouldStop;
@end
