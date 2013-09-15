//
//  HKThreadUtil.m
//  hkutil2
//
//  Created by akwei on 13-4-22.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKThreadUtil.h"

static HKThreadUtil* _sharedHKThreadUtil;
@implementation HKThreadUtil{
    dispatch_queue_t _asyncQueue;
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
        NSString* queueName = [[NSString alloc] initWithFormat:@"hkutil2.HKThreadUtil_asyncQueue_%@_%f",[self description],[[NSDate date] timeIntervalSince1970]];
        _asyncQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

-(void)dealloc{
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_6_0
    dispatch_release(_asyncQueue);
#endif
}

-(void)asyncBlock:(void (^)(void))block{
    dispatch_async(_asyncQueue, ^{
        @autoreleasepool {
            block();
        }
    });
}

-(void)asyncBlockToMainThread:(void (^)(void))block{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            block();
        }
    });
}

-(void)syncBlockToMainThread:(void (^)(void))block{
    dispatch_sync(dispatch_get_main_queue(),  ^{
        @autoreleasepool {
            block();
        }
    });
}

@end
