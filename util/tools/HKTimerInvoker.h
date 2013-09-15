//
//  HKTimerInvoker.h
//  hkutil2
//
//  Created by akwei on 13-4-23.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKTimerInvoker : NSObject

@property(nonatomic,strong) BOOL (^jobBlock)(void);
@property(nonatomic,strong) void (^callbackBlock)(void);

/*
 任务间隔时间
 */
@property(nonatomic,assign)NSTimeInterval time;

/*
 任务调用，会启用新的线程进行调用，异步执行，不会在主线程中使用和当前线程
 */
-(void)start;

-(void)startWithDelay:(NSTimeInterval)t;

-(void)stop:(BOOL)waitDone;

@end
