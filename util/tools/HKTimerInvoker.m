//
//  HKTimerInvoker.m
//  hkutil2
//
//  Created by akwei on 13-4-23.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKTimerInvoker.h"
#import "HKThreadUtil.h"

#define TimerInvokeDebug 1

@interface HKTimerInvoker ()
@property(nonatomic,assign)BOOL running;
@end

@implementation HKTimerInvoker{
    HKThreadUtil* _threadUtil;
    BOOL stopFlag;
    NSCondition* condition;
    NSCondition* flgCondition;
}

-(id)init{
    self=[super init];
    if (self) {
        _threadUtil = [[HKThreadUtil alloc] init];
        condition=[[NSCondition alloc] init];
        flgCondition=[[NSCondition alloc] init];
        stopFlag=NO;
        self.running=NO;
    }
    return self;
}

-(void)dealloc{
    [self stop:NO];
}

-(void)stop:(BOOL)waitDone{
    [flgCondition lock];
    stopFlag=YES;
    [condition signal];
    if (waitDone) {
        while (self.running==YES) {
            [flgCondition wait];
        }
    }
    [flgCondition unlock];
}

-(void)sleep:(NSTimeInterval)t{
    NSDate* date=[[NSDate alloc] init];
    double ntime = [date timeIntervalSince1970] + t;
    NSDate* nDate = [[NSDate alloc] initWithTimeIntervalSince1970:ntime];
    [condition waitUntilDate:nDate];
}

-(void)startWithDelay:(NSTimeInterval)t{
    if (self.running) {
#if TimerInvokeDebug
        NSLog(@"timer already running");
#endif
        return;
    }
    self.running=YES;
    stopFlag=NO;
    __unsafe_unretained HKTimerInvoker* me = self;
    [_threadUtil asyncBlock:^{
        [condition lock];
        if (t>0) {
#if TimerInvokeDebug
            NSLog(@"sleep for delay %f",t);
#endif
            [me sleep:t];
        }
        if (!stopFlag) {
            [me methodInvoke];
            while (!stopFlag) {
                [me sleep:me.time];
                if (stopFlag) {
                    break;
                }
                [me methodInvoke];
            }
        }
        me.running=NO;
#if TimerInvokeDebug
        NSLog(@"timer stop running");
#endif
        [flgCondition signal];
        [condition unlock];
    }];
}

-(void)start{
    [self startWithDelay:0];
}

-(void)methodInvoke{
    if (!self.jobBlock) {
        return;
    }
    BOOL canCallback = self.jobBlock();
    if (canCallback) {
        if (self.callbackBlock) {
            __block __unsafe_unretained HKTimerInvoker* me = self;
            [_threadUtil syncBlockToMainThread:^{
                me.callbackBlock();
            }];
        }
    }
}

-(BOOL)isShouldStop{
    if (stopFlag) {
        return YES;
    }
    return NO;
}

-(void)invokeCallback{
    self.running=NO;
}

@end
