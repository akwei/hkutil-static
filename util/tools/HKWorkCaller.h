//
//  HKWorkCaller.h
//  hk_restaurant2
//
//  Created by akwei on 13-6-19.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKWorkCaller : NSObject
@property(nonatomic,strong)NSMutableDictionary* info;

/**
 异步执行任务
 @param block 异步调用的任务
 @param onErrorMainBlock 出现异常时在主线程中调用
 @param
 **/
-(void)workWithBlock:(BOOL(^)(void))block onErrorMainBlock:(void (^)(NSException* exception))onErrorMainBlock;

+(void)workWithBlock:(BOOL(^)(NSMutableDictionary* info))block onErrorMainBlock:(void (^)(NSMutableDictionary* info,NSException* exception))onErrorMainBlock;


@end
