//
//  HKCaller.h
//  hkutil-static
//
//  Created by akwei on 4/27/14.
//  Copyright (c) 2014 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HKCaller;

@protocol HKCallerDelegate <NSObject>
@required
-(void)callerOnReceive:(HKCaller*)caller;
@end

@interface HKCaller : NSObject
@property(nonatomic,copy)NSString* result;

/**
 开启单元测试模式，如果开启，将对程序中的异步都进行同步化处理。默认不开启
 @param enable YES:开启
 */
+(void)setEnableTestMode:(BOOL)enable;

/**
 是否开启了单元测试模式
 @returns YES:开启
 */
+(BOOL)isEnableTestMode;

+(id)createWithCallbackObj:(id)callbackObj;

+(id)async:(NSString* (^)(HKCaller* caller))block callbackObj:(id)callbackObj;

/**
 异步提交到并发队列中
 @param block 需要异步执行的block，返回一个字符串代表状态
 */
-(void)async:(NSString *(^)(HKCaller *))block;

/**
 终止操作，如果已经运行异步操作，就终止异步完成后的回调
 */
-(void)cancel;

-(id)valueForKey:(NSString *)key;
-(NSInteger)integerValueForKey:(NSString*)key;
-(NSUInteger)uintegerValueForKey:(NSString*)key;
-(double)doubleValueForKey:(NSString*)key;
-(BOOL)boolValueForKey:(NSString*)key;

-(void)setValue:(id)value forKey:(NSString *)key;
-(void)setInteger:(NSInteger)value forKey:(NSString*)key;
-(void)setUInteger:(NSInteger)value forKey:(NSString*)key;
-(void)setDouble:(double)value forKey:(NSString*)key;
-(void)setBool:(BOOL)value forKey:(NSString*)key;

@end
