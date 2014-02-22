//
//  HKMVC.m
//  hkutil-static
//
//  Created by akwei on 14-2-18.
//  Copyright (c) 2014年 huoku. All rights reserved.
//

#import "HKMVC.h"
#import <objc/message.h>

@interface HKMVC ()
@property(nonatomic,strong)NSMutableDictionary* info;
@end

@implementation HKMVC

- (id)init
{
    self = [super init];
    if (self) {
        self.hkKVODelegate = self;
        self.info = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(id)initWithMvcDelegate:(id)mvcDelegate{
    self = [super init];
    if (self) {
        self.hkKVODelegate = self;
        self.info = [[NSMutableDictionary alloc] init];
        self.mvcDelegate = mvcDelegate;
    }
    return self;
}

-(void)setInfoValue:(id)value forKey:(NSString *)key{
    [self.info setValue:value forKey:key];
}

-(id)infoValueForKey:(NSString *)key{
    return [self.info valueForKey:key];
}

-(void)async:(NSString *(^)(void))block{
    [self.info removeAllObjects];
    [super async:block];
}

-(void)asyncWithBlockArrayToGroup:(NSArray *)blockArray{
    [self.info removeAllObjects];
    [super asyncWithBlockArrayToGroup:blockArray];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"result"]) {
        __weak HKKVO* me = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [me.hkKVODelegate hkKVOOnReceive:me];
        });
    }
}

-(void)hkKVOOnReceive:(HKKVO *)hkKVO{
    SEL selector = NSSelectorFromString(self.result);
    if (!selector) {
        return;
    }
    if ([self.mvcDelegate respondsToSelector:selector]) {
        objc_msgSend(self.mvcDelegate, selector);
    }
}

@end
