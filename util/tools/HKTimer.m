//
//  HKTimer.m
//  hkutil-static
//
//  Created by akwei on 14-2-23.
//  Copyright (c) 2014年 huoku. All rights reserved.
//

#import "HKTimer.h"

@implementation HKTimer{
    BOOL _stop;
    BOOL _jobFinish;
    dispatch_queue_t _queue;
}

- (id)init
{
    self = [super init];
    if (self) {
        _stop = NO;
        _jobFinish = NO;
        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    }
    return self;
}

-(void)dealloc{
#if NEEDS_DISPATCH_RETAIN_RELEASE
	if (_queue) dispatch_release(_queue);
#endif
}

-(void)addJobToTimer{
    if (_stop) {
        return;
    }
    __weak HKTimer* me = self;
    double delayInSeconds = me.delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, _queue, ^(void){
        _jobFinish = NO;
        me.jobBlock();
        _jobFinish = YES;
        if (!_stop) {
            [me schedue];
        }
    });
    BOOL done = NO;
    do{
        SInt32    result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, YES);
        if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished))
            done = YES;
        
        // Check for any other exit conditions here and set the
        // done variable as needed.
        if (_stop && _jobFinish) {
            done = YES;
        }
    }while (!done);
}

-(void)schedue{
    __weak HKTimer* me = self;
    dispatch_async(_queue, ^{
        [me addJobToTimer];
    });
}

-(void)stop{
    _stop = YES;
}

@end
