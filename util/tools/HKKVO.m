//
//  HKKVO.m
//  hkutil-static
//
//  Created by akwei on 14-2-17.
//  Copyright (c) 2014年 huoku. All rights reserved.
//

#import "HKKVO.h"

static HKKVO* _sharedObj = nil;
static BOOL _sharedEnableTestMode = NO;

@interface HKKVO ()
@property(nonatomic,assign)dispatch_queue_t asyncQueue;
@end

@implementation HKKVO

+(void)setEnableTestMode:(BOOL)enable{
    _sharedEnableTestMode = enable;
}

+(BOOL)isEnableTestMode{
    return _sharedEnableTestMode;
}

-(id)init{
    self = [super init];
    if (self) {
        _asyncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        [self addObserver:self forKeyPath:@"result" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }
    return self;
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:@"result"];
#if NEEDS_DISPATCH_RETAIN_RELEASE
	if (_asyncQueue) dispatch_release(_asyncQueue);
#endif
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"result"]) {
        [self.hkKVODelegate hkKVOOnReceive:self];
    }
}

-(void)async:(NSString *(^)(void))block{
    if ([HKKVO isEnableTestMode]) {
        self.result = block();
        return;
    }
    __weak HKKVO* me = self;
    dispatch_async(_asyncQueue, ^{
        me.result = block();
    });
}

-(void)asyncWithBlockArrayToGroup:(NSArray *)blockArray{
    if ([HKKVO isEnableTestMode]) {
        for (NSString* (^block)(void)  in blockArray) {
            self.result = block();
        }
        return;
    }
    dispatch_group_t group = dispatch_group_create();
    __weak HKKVO* me = self;
    for (NSString* (^block)(void)  in blockArray) {
        self.result = block();
        dispatch_group_async(group, _asyncQueue, ^{
            me.result = block();
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

@end
