//
//  HKMVC.h
//  hkutil-static
//
//  Created by akwei on 14-2-18.
//  Copyright (c) 2014年 huoku. All rights reserved.
//


@class HKMVC;

@protocol HKMVCDelegate <NSObject>
@required
-(void)mvcOnReceive:(HKMVC*)hkMVC;
@end

@interface HKMVC : NSObject
@property(nonatomic,assign)id mvcDelegate;
@property(nonatomic,copy)NSString* result;

+(void)setInjectBlock:(void (^)(void))injectBlock;

-(id)initWithMvcDelegate:(id)mvcDelegate;


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

/**
 异步提交到并发队列中
 @param block 需要异步执行的block，返回一个字符串代表状态
 */
-(void)async:(NSString* (^)(void))block;

/**
 添加一组异步执行的blok到特定的组中，此方法为阻塞方法，只有执行完所有线程之后，才能继续运行
 @param blockArray 需要异步执行的block 形式: (NSString* (^)(void))block
 @param group 线程组
 */
-(void)asyncWithBlockArrayToGroup:(NSArray*)blockArray;

-(void)setInfoValue:(id)value forKey:(NSString*)key;
-(id)infoValueForKey:(NSString *)key;
-(void)noticeMvc;



@end
