//
//  HKCaller.m
//  hkutil-static
//
//  Created by akwei on 4/27/14.
//  Copyright (c) 2014 huoku. All rights reserved.
//

#import "HKCaller.h"
#import "NSDictionary+HKEx.h"
#import "NSMutableDictionary+HKEx.h"
#import <objc/message.h>

static HKCaller* _sharedCallerObj = nil;
static BOOL _sharedEnableTestMode = NO;

@interface HKCaller ()
@property(nonatomic,assign)id callbackObj;
@property(nonatomic,assign)BOOL stopFlag;
@property(nonatomic,strong)NSMutableDictionary* info;
@end

@implementation HKCaller{
    dispatch_queue_t _asyncQueue;
}

+(void)setEnableTestMode:(BOOL)enable{
    _sharedEnableTestMode = enable;
};

+(BOOL)isEnableTestMode{
    return _sharedEnableTestMode;
}

+(id)createWithCallbackObj:(id)callbackObj{
    HKCaller* caller = [[HKCaller alloc] initWithCallbackObj:callbackObj];
    return caller;
}

+(id)async:(NSString *(^)(HKCaller *))block callbackObj:(id)callbackObj{
    HKCaller* caller = [[HKCaller alloc] initWithCallbackObj:callbackObj];
    [caller async:block];
    return caller;
}

-(id)initWithCallbackObj:(id)callbackObj{
    self = [super init];
    if (self) {
        _asyncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _callbackObj = callbackObj;
        self.stopFlag = NO;
        self.result = nil;
        self.info = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:@"result"];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0 // iOS 5.X or earlier
    if (_asyncQueue) dispatch_release(_asyncQueue);
#endif
}

-(void)async:(NSString *(^)(HKCaller *))block{
    if (self.stopFlag) {
        return;
    }
    [self addObserver:self forKeyPath:@"result" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    __weak HKCaller* me = self;
    if ([HKCaller isEnableTestMode]) {
        self.result = block(me);
        return;
    }
    dispatch_async(_asyncQueue, ^{
        me.result = block(me);
    });
}

-(void)cancel{
    self.stopFlag = YES;
}

-(id)valueForKey:(NSString *)key{
    return [self.info valueForKey:key];
}

-(void)setValue:(id)value forKey:(NSString *)key{
    [self.info setValue:value forKey:key];
}

-(NSInteger)integerValueForKey:(NSString *)key{
    return [self.info integerValueForKey:key];
}

-(NSUInteger)uintegerValueForKey:(NSString *)key{
    return [self.info unsignedIntegerValueForKey:key];
}

-(double)doubleValueForKey:(NSString *)key{
    return [self.info doubleValueForKey:key];
}

-(BOOL)boolValueForKey:(NSString *)key{
    return [self.info boolValueForKey:key];
}

-(void)setInteger:(NSInteger)value forKey:(NSString *)key{
    [self.info setInteger:value forKey:key];
}

-(void)setUInteger:(NSInteger)value forKey:(NSString *)key{
    [self.info setUnsignedInteger:value forKey:key];
}

-(void)setDouble:(double)value forKey:(NSString *)key{
    [self.info setDouble:value forKey:key];
}

-(void)setBool:(BOOL)value forKey:(NSString *)key{
    [self.info setBool:value forKey:key];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (self.stopFlag) {
        return;
    }
    if (!self.result) {
        return;
    }
    __weak HKCaller* me = self;
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:",self.result]);
    if (!selector) {
        return;
    }
    if ([me.callbackObj respondsToSelector:selector]) {
        [me.callbackObj performSelectorOnMainThread:selector withObject:me waitUntilDone:YES];
    }
    else{
        NSString* className=[NSString stringWithCString:class_getName([me.callbackObj class]) encoding:NSUTF8StringEncoding];
        NSLog(@"can not find [%@ %@]",className,self.result);
    }
}

@end
