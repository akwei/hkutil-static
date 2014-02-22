//
//  HKThreadUtil.m
//  hkutil2
//
//  Created by akwei on 13-4-22.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKThreadUtil.h"
#import "CfgHeader.h"

static HKThreadUtil* _sharedHKThreadUtil = nil;
static BOOL _sharedenableTestMode = NO;
@implementation HKThreadUtil{
}

+(HKThreadUtil *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHKThreadUtil = [[HKThreadUtil alloc] init];
    });
    return _sharedHKThreadUtil;
}

+(void)setEnableTestMode:(BOOL)enable{
    _sharedenableTestMode = enable;
}

+(BOOL)isEnableTestMode{
    return _sharedenableTestMode;
}

-(id)init{
    self = [super init];
    if (self) {
//        NSString* queueName = [[NSString alloc] initWithFormat:@"hkutil2.HKThreadUtil_asyncQueue_%@_%f",[self description],[[NSDate date] timeIntervalSince1970]];
//        _asyncQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
        _asyncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.enableTestMode = NO;
    }
    return self;
}

-(void)dealloc{
#if NEEDS_DISPATCH_RETAIN_RELEASE
	if (_asyncQueue) dispatch_release(_asyncQueue);
#endif
}

-(void)async:(void (^)(void))block{
    if ([HKThreadUtil isEnableTestMode]) {
        block();
        return;
    }
    dispatch_async(_asyncQueue, ^{
        @autoreleasepool {
            block();
        }
    });
}

-(void)toMain:(void (^)(void))block{
    if ([HKThreadUtil isEnableTestMode]) {
        block();
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            block();
        }
    });
}

-(void)async:(void (^)(void))block toGroup:(dispatch_group_t)group{
    if ([HKThreadUtil isEnableTestMode]) {
        block();
        return;
    }
    dispatch_group_async(group, _asyncQueue, block);
}

-(void)asyncWithBlockArrayToGroup:(NSArray *)blockArray{
    if ([HKThreadUtil isEnableTestMode]) {
        for (NSString* (^block)(void)  in blockArray) {
            block();
        }
        return;
    }
    dispatch_group_t group = dispatch_group_create();
    for (NSString* (^block)(void)  in blockArray) {
        dispatch_group_async(group, _asyncQueue, ^{
            block();
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

@end
