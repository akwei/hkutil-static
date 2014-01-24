//
//  HKWorkCaller.m
//  hk_restaurant2
//
//  Created by akwei on 13-6-19.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKWorkCaller.h"
#import "HKThreadUtil.h"

@interface HKWorkCaller ()

@end

@implementation HKWorkCaller

-(id)init{
    self = [super init];
    if (self) {
        self.info = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)workWithBlock:(BOOL (^)(void))block onErrorMainBlock:(void (^)(NSException* exception))onErrorMainBlock{
    [self.info removeAllObjects];
    [[HKThreadUtil shareInstance] async:^{
        @try {
            if (block() && onErrorMainBlock) {
                [[HKThreadUtil shareInstance] toMain:^{
                    onErrorMainBlock(nil);
                }];
            }
        }
        @catch (NSException *exception) {
            if (onErrorMainBlock) {
                [[HKThreadUtil shareInstance] toMain:^{
                    onErrorMainBlock(exception);
                }];
            }
        }
    }];
}


+(void)workWithBlock:(BOOL (^)(NSMutableDictionary *))block onErrorMainBlock:(void (^)(NSMutableDictionary *, NSException *))onErrorMainBlock{
    __block NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
    [[HKThreadUtil shareInstance] async:^{
        @try {
            if (block(info) && onErrorMainBlock) {
                [[HKThreadUtil shareInstance] toMain:^{
                    onErrorMainBlock(info,nil);
                }];
            }
        }
        @catch (NSException *exception) {
            if (onErrorMainBlock) {
                [[HKThreadUtil shareInstance] toMain:^{
                    onErrorMainBlock(info,exception);
                }];
            }
        }
        @finally {
            info = nil;
        }
    }];
    info = nil;
}


@end
