//
//  HKRunLoopObj.h
//  hkutil2
//
//  Created by akwei on 13-5-31.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKRunLoopObj : NSObject

-(void)doSth;

@end

@interface RunLoopSourceObj : NSObject
{
    CFRunLoopSourceRef runLoopSource;
}

@property(nonatomic,assign)BOOL done;

- (void)addToCurrentRunLoop;

// Handler method
- (void)sourceFired;

- (void)fireAllCommandsOnRunLoop:(CFRunLoopRef)runloop;

@end

// These are the CFRunLoopSourceRef callback functions.
void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode);
void RunLoopSourcePerformRoutine (void *info);
void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode);

// RunLoopContext is a container object used during registration of the input source.
@interface RunLoopContext : NSObject

@property (nonatomic,readonly) CFRunLoopRef runLoop;
@property (nonatomic,readonly) RunLoopSourceObj* source;

- (id)initWithSource:(RunLoopSourceObj*)src andLoop:(CFRunLoopRef)loop;
@end


