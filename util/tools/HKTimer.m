//
//  HKTimer.m
//  hkutil-static
//
//  Created by akwei on 14-2-23.
//  Copyright (c) 2014年 huoku. All rights reserved.
//

#import "HKTimer.h"

@interface HKTimer ()
@property(nonatomic,assign)BOOL stopFlag;
@property(nonatomic,assign)BOOL doing;
@property(nonatomic,strong)NSCondition* cdn;
@end

@implementation HKTimer{
    dispatch_queue_t _queue;
}

//- (id)init
//{
//    self = [super init];
//    if (self) {
//        self.stopFlag = YES;
//        self.doing= NO;
//        self.repeat = NO;
//        self.cdn = [[NSCondition alloc] init];
//        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    }
//    return self;
//}
//
//-(void)dealloc{
//    [self stop];
//#if NEEDS_DISPATCH_RETAIN_RELEASE
//	if (_queue) dispatch_release(_queue);
//#endif
//}
//
//-(void)schedue{
//    if (self.doing) {
//        return;
//    }
//    self.doing = YES;
//    [self asyncDo];
//}
//
//-(void)asyncDo{
//    __weak HKTimer* me = self;
//    dispatch_async(_queue, ^{
//        [me asyncJob];
//        BOOL done = NO;
//        do{
//            SInt32    result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, YES);
//            if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished))
//                done = YES;
//            
//            // Check for any other exit conditions here and set the
//            // done variable as needed.
//            if (me.stopFlag) {
//                done = YES;
//            }
//        }while (!done);
//        self.doing = NO;
//    });
//}
//
//-(void)asyncJob{
//    __weak HKTimer* me = self;
//    double delayInSeconds = me.delay;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    void (^block)(void) = self.jobBlock;
//    dispatch_after(popTime, _queue, ^{
//        if (me.stopFlag) {
//            return ;
//        }
//        [me.cdn lock];
//        me.jobFinish = NO;
//        block();
//        me.jobFinish = YES;
//        [me.cdn signal];
//        [me.cdn unlock];
//        if (!me.stopFlag && me.repeat) {
//            [me asyncJob];
//        }
//        else{
//            me.stopFlag = YES;
//        }
//    });
//}
//
//-(void)stop{
//    [self.cdn lock];
//    self.stopFlag = YES;
//    while (!self.jobFinish) {
//        [self.cdn wait];
//    }
//    [self.cdn unlock];
//}

@end
