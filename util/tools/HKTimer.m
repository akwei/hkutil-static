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
@property(nonatomic,assign)BOOL end;
@end

@implementation HKTimer{
    dispatch_queue_t _queue;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.stopFlag = YES;
        self.end = YES;
        self.repeat = NO;
        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return self;
}

-(void)dealloc{
    [self stop];
#if NEEDS_DISPATCH_RETAIN_RELEASE
	if (_queue) dispatch_release(_queue);
#endif
}

-(void)start{
    if (self.end == NO) {
        return;
    }
    self.end = NO;
    self.stopFlag = NO;
    [self addJobInQueue];
}

-(void)addJobInQueue{
    __weak HKTimer* me = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delay * NSEC_PER_SEC));
    dispatch_after(popTime, _queue, ^(void){
        @autoreleasepool {
            if (!me) {
                return ;
            }
            [me doJob];
        }
    });
}

-(void)doJob{
    if (self.stopFlag) {
        self.end = YES;
        return ;
    }
    self.jobBlock();
    if (self.stopFlag) {
        self.end = YES;
        return;
    }
    [self addJobInQueue];
}

-(void)stop{
    self.stopFlag = YES;
}

@end
