//
//  HKMVC.m
//  hkutil-static
//
//  Created by akwei on 14-2-18.
//  Copyright (c) 2014年 huoku. All rights reserved.
//

#import "HKMVC.h"
#import <objc/message.h>

static HKMVC* _sharedObj = nil;
static BOOL _sharedEnableTestMode = NO;

@interface HKMVC ()
@property(nonatomic,strong)NSMutableDictionary* info;
@property(nonatomic,assign)dispatch_queue_t asyncQueue;
@end

@implementation HKMVC

+(void)setEnableTestMode:(BOOL)enable{
    _sharedEnableTestMode = enable;
}

+(BOOL)isEnableTestMode{
    return _sharedEnableTestMode;
}

-(id)initWithMvcDelegate:(id)mvcDelegate{
    self = [super init];
    if (self) {
        _asyncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.info = [[NSMutableDictionary alloc] init];
        self.mvcDelegate = mvcDelegate;
    }
    return self;
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:@"result"];
#if NEEDS_DISPATCH_RETAIN_RELEASE
	if (_asyncQueue) dispatch_release(_asyncQueue);
#endif
}

-(void)setInfoValue:(id)value forKey:(NSString *)key{
    [self.info setValue:value forKey:key];
}

-(id)infoValueForKey:(NSString *)key{
    return [self.info valueForKey:key];
}

-(void)async:(NSString *(^)(void))block{
    [self.info removeAllObjects];
    self.result = nil;
    [self addObserver:self forKeyPath:@"result" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    if ([HKMVC isEnableTestMode]) {
        self.result = block();
        return;
    }
    __weak HKMVC* me = self;
    dispatch_async(_asyncQueue, ^{
        me.result = block();
    });
}

-(void)asyncWithBlockArrayToGroup:(NSArray *)blockArray{
    [self.info removeAllObjects];
    self.result = nil;
    if ([HKMVC isEnableTestMode]) {
        for (void (^block)(void)  in blockArray) {
            block();
        }
        return;
    }
    dispatch_group_t group = dispatch_group_create();
    for (void (^block)(void)  in blockArray) {
        dispatch_group_async(group, _asyncQueue, ^{
            block();
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (!self.result) {
        return;
    }
    __weak HKMVC* me = self;
    SEL selector = NSSelectorFromString(self.result);
    if (!selector) {
        return;
    }
    if ([me.mvcDelegate respondsToSelector:selector]) {
        [me.mvcDelegate performSelectorOnMainThread:selector withObject:nil waitUntilDone:YES];
    }
    else{
        NSString* className=[NSString stringWithCString:class_getName([me.mvcDelegate class]) encoding:NSUTF8StringEncoding];
        NSLog(@"can not find [%@ %@]",className,self.result);
    }
}


@end
