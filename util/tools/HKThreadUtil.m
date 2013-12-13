//
//  HKThreadUtil.m
//  hkutil2
//
//  Created by akwei on 13-4-22.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKThreadUtil.h"
#import "CfgHeader.h"

static HKThreadUtil* _sharedHKThreadUtil;
@implementation HKThreadUtil{
}
+(HKThreadUtil *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHKThreadUtil = [[HKThreadUtil alloc] init];
    });
    return _sharedHKThreadUtil;
}

-(id)init{
    self = [super init];
    if (self) {
//        NSString* queueName = [[NSString alloc] initWithFormat:@"hkutil2.HKThreadUtil_asyncQueue_%@_%f",[self description],[[NSDate date] timeIntervalSince1970]];
//        _asyncQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
        _asyncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return self;
}

-(void)dealloc{
#if NEEDS_DISPATCH_RETAIN_RELEASE
	if (_asyncQueue) dispatch_release(_asyncQueue);
#endif
}

-(void)asyncBlock:(void (^)(void))block{
    dispatch_async(_asyncQueue, ^{
        @autoreleasepool {
            block();
        }
    });
}

-(void)async:(void (^)(void))block{
    [self asyncBlock:block];
}

-(void)asyncBlockToMainThread:(void (^)(void))block{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            block();
        }
    });
}

-(void)asyncToMainThread:(void (^)(void))block{
    [self asyncBlockToMainThread:block];
}

-(void)toMain:(void (^)(void))block{
    [self asyncBlockToMainThread:block];
}

-(void)asyncBlock:(void (^)(void))block toGroup:(dispatch_group_t)group{
    dispatch_group_async(group, _asyncQueue, block);
}

-(void)async:(void (^)(void))block toGroup:(dispatch_group_t)group{
    [self asyncBlock:block toGroup:group];
}

@end
