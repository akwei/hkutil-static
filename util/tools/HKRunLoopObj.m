//
//  HKRunLoopObj.m
//  hkutil2
//
//  Created by akwei on 13-5-31.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKRunLoopObj.h"
#import "HKThreadUtil.h"

void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)
{
    NSLog(@"RunLoopSourceScheduleRoutine %@",[[NSThread currentThread] description]);
//    RunLoopSource* obj = (__bridge RunLoopSource*)info;
    
    //    AppDelegate*   del = [AppDelegate sharedAppDelegate];
//    RunLoopContext* theContext = [[RunLoopContext alloc] initWithSource:obj andLoop:rl];
    
    //    [del performSelectorOnMainThread:@selector(registerSource:)
    //                          withObject:theContext waitUntilDone:NO];
}

void RunLoopSourcePerformRoutine (void *info)
{
    NSLog(@"RunLoopSourcePerformRoutine %@",[[NSThread currentThread] description]);
    RunLoopSourceObj* obj = (__bridge RunLoopSourceObj*)info;
    [obj sourceFired];
}

void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)
{
    NSLog(@"RunLoopSourceCancelRoutine %@",[[NSThread currentThread] description]);
//    RunLoopSource* obj = (__bridge RunLoopSource*)info;
    //    AppDelegate* del = [AppDelegate sharedAppDelegate];
//    RunLoopContext* theContext = [[RunLoopContext alloc] initWithSource:obj andLoop:rl];
    
    //    [del performSelectorOnMainThread:@selector(removeSource:)
    //                          withObject:theContext waitUntilDone:YES];
}

@implementation HKRunLoopObj{
    RunLoopSourceObj* _rls;
}

-(void)doSth{
    NSLog(@"doSth %@",[[NSThread currentThread] description]);
    _rls = [[RunLoopSourceObj alloc] init];
    CFRunLoopRef runloopRef = [[NSRunLoop currentRunLoop] getCFRunLoop];
    [[HKThreadUtil shareInstance] asyncBlock:^{
        NSLog(@"doAsync begin %@",[[NSThread currentThread] description]);
        [NSThread sleepForTimeInterval:5];
        [_rls fireAllCommandsOnRunLoop:runloopRef];
        NSLog(@"doAsync end %@",[[NSThread currentThread] description]);
        CFRunLoopStop(runloopRef);
    }];
    BOOL done = NO;
    [_rls addToCurrentRunLoop];
    do
    {
        // Start the run loop but return after each source is handled.
        SInt32    result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, YES);
        
        // If a source explicitly stopped the run loop, or if there are no
        // sources or timers, go ahead and exit.
        if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished))
            done = YES;
        
        // Check for any other exit conditions here and set the
        // done variable as needed.
        if (_rls.done) {
            done = YES;
        }
    }
    while (!done);
    NSLog(@"end runloop %@",[[NSThread currentThread] description]);
    // Clean up code here. Be sure to release any allocated autorelease pools.
}

@end

@implementation RunLoopSourceObj

- (id)init
{
    self = [super init];
    if (self) {
        CFRunLoopSourceContext    context = {0, (__bridge void *)(self), NULL, NULL, NULL, NULL, NULL,
            &RunLoopSourceScheduleRoutine,
            &RunLoopSourceCancelRoutine,
            &RunLoopSourcePerformRoutine};
        
        runLoopSource = CFRunLoopSourceCreate(NULL, 0, &context);
        self.done = NO;
    }
    return self;
}

- (void)addToCurrentRunLoop
{
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
}

-(void)fireAllCommandsOnRunLoop:(CFRunLoopRef)runloop
{
    CFRunLoopSourceSignal(runLoopSource);
    CFRunLoopWakeUp(runloop);
}

-(void)sourceFired{
    NSLog(@"sourceFired %@",[[NSThread currentThread] description]);
    [NSThread sleepForTimeInterval:5];
    self.done = YES;
    NSLog(@"sourceFired end %@",[[NSThread currentThread] description]);
}

@end

@implementation RunLoopContext

-(id)initWithSource:(RunLoopSourceObj *)src andLoop:(CFRunLoopRef)loop{
    self = [super init];
    if (self) {
        _source = src;
        _runLoop = loop;
    }
    return self;
}

@end



